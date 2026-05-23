import 'package:timezone/timezone.dart' as tz;

import 'models/pricing_rule_model.dart';
import 'models/venue_schedule_result_model.dart';

/// Opening window in venue-local hours (same semantics as API: [startHour, endHour) for slot starts).
class OpeningWindow {
  final int startHour;
  /// Last slot may end at this hour (e.g. 22 means booking can end at 22:00).
  final int endHour;
  final tz.Location location;

  const OpeningWindow({
    required this.startHour,
    required this.endHour,
    required this.location,
  });
}

int _parseHourFromTime(String? t) {
  if (t == null || t.isEmpty) return 0;
  final parts = t.split(':');
  return int.tryParse(parts[0]) ?? 0;
}

int _dartWeekdayToApi(int weekday) {
  return weekday == DateTime.sunday ? 0 : weekday;
}

tz.Location resolveVenueLocation(ScheduleResultGroup group) {
  final iana = group.schedules.isNotEmpty
      ? group.schedules.first.timezone
      : null;
  if (iana != null && iana.isNotEmpty) {
    try {
      return tz.getLocation(iana);
    } catch (_) {}
  }
  try {
    return tz.getLocation('Asia/Almaty');
  } catch (_) {
    return tz.UTC;
  }
}

/// IANA timezone for API booking body: venue field, then schedule rows, then Kazakhstan default.
String resolveBookingTimezoneIana({
  String? venueTimezone,
  ScheduleResultGroup? scheduleGroup,
}) {
  final v = venueTimezone?.trim();
  if (v != null && v.isNotEmpty) return v;
  if (scheduleGroup != null) {
    for (final s in scheduleGroup.schedules) {
      final t = s.timezone?.trim();
      if (t != null && t.isNotEmpty) return t;
    }
  }
  return 'Asia/Almaty';
}

/// Active weekly schedule for [year]-[month]-[day] in venue timezone, or null if closed.
OpeningWindow? openingForCalendarDay(
  ScheduleResultGroup group,
  int year,
  int month,
  int day,
) {
  if (group.schedules.isEmpty) return null;
  final loc = resolveVenueLocation(group);
  final midday = tz.TZDateTime(loc, year, month, day, 12);
  final dow = _dartWeekdayToApi(midday.weekday);
  ResourceScheduleEntryModel? chosen;
  for (final s in group.schedules) {
    if (!s.isActive) continue;
    if (s.dayOfWeek == dow) {
      chosen = s;
      break;
    }
  }
  if (chosen == null) return null;
  final sh = _parseHourFromTime(chosen.startTime);
  final eh = _parseHourFromTime(chosen.endTime);
  if (eh <= sh) return null;
  return OpeningWindow(startHour: sh, endHour: eh, location: loc);
}

/// Venue-local start hours on [year]-[month]-[day] that are in the past or begin in
/// less than [minLeadTime] from [now] (defaults to venue-local "now"). Empty when the
/// calendar day is not today in [location].
Set<int> pastOrTooSoonStartHours(
  tz.Location location,
  int year,
  int month,
  int day, {
  Duration minLeadTime = const Duration(minutes: 15),
  tz.TZDateTime? now,
}) {
  final current = now ?? tz.TZDateTime.now(location);
  if (current.year != year ||
      current.month != month ||
      current.day != day) {
    return {};
  }
  final out = <int>{};
  for (var h = 0; h < 24; h++) {
    final slotStart = tz.TZDateTime(location, year, month, day, h, 0);
    if (!slotStart.isAfter(current)) {
      out.add(h);
      continue;
    }
    if (slotStart.difference(current) < minLeadTime) {
      out.add(h);
    }
  }
  return out;
}

/// Venue-local hour indices [0–23] that overlap an active blackout on this calendar day.
Set<int> blockedLocalHoursForDay(
  ScheduleResultGroup group,
  int year,
  int month,
  int day,
  tz.Location location,
) {
  final blocked = <int>{};
  for (final b in group.blackouts) {
    if (!b.isActive) continue;
    final startUtc = b.startAtUtc.toUtc();
    final endUtc = b.endAtUtc.toUtc();
    final bStart = tz.TZDateTime.from(startUtc, location);
    final bEnd = tz.TZDateTime.from(endUtc, location);
    for (var h = 0; h < 24; h++) {
      final slotStart = tz.TZDateTime(location, year, month, day, h, 0);
      final slotEnd = slotStart.add(const Duration(hours: 1));
      if (slotEnd.isAfter(bStart) && slotStart.isBefore(bEnd)) {
        blocked.add(h);
      }
    }
  }
  return blocked;
}

List<String> availableStartSlots(OpeningWindow? opening, Set<int> blocked) {
  if (opening == null) return [];
  final out = <String>[];
  for (var h = opening.startHour; h < opening.endHour; h++) {
    if (!blocked.contains(h)) {
      out.add('${h.toString().padLeft(2, '0')}:00');
    }
  }
  return out;
}

/// End times (exclusive boundary) so that every hour in [start, end) is inside opening and not blocked.
List<String> validEndSlotsForStart(
  String start,
  OpeningWindow? opening,
  Set<int> blocked,
) {
  if (opening == null) return [];
  final sh = int.tryParse(start.split(':').first) ?? 0;
  final ends = <String>[];
  for (var e = sh + 1; e <= opening.endHour; e++) {
    var ok = true;
    for (var h = sh; h < e; h++) {
      if (blocked.contains(h)) {
        ok = false;
        break;
      }
    }
    if (ok) {
      ends.add('${e.toString().padLeft(2, '0')}:00');
    }
  }
  return ends;
}

// ── Pricing (per-hour, time-of-day windows + effective range) ───────────────

int? _secondsFromMidnight(String? t) {
  if (t == null || t.trim().isEmpty) return null;
  final parts = t.trim().split(':');
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  final secRaw = parts.length > 2 ? parts[2] : '0';
  final s = int.tryParse(secRaw.split('.').first) ?? 0;
  return h * 3600 + m * 60 + s;
}

bool _ruleTimeMatchesMinute(PricingRuleModel p, int slotStartSecond) {
  final st = _secondsFromMidnight(p.startTime);
  final et = _secondsFromMidnight(p.endTime);
  if (st == null && et == null) return true;
  final lo = st ?? 0;
  final hi = et ?? (24 * 3600 - 1);
  return slotStartSecond >= lo && slotStartSecond <= hi;
}

bool _ruleEffectiveOverlapsSlotUtc(
  PricingRuleModel p,
  DateTime slotStartUtc,
  DateTime slotEndUtc,
) {
  final effStart =
      p.effectiveFrom?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  if (!slotEndUtc.isAfter(effStart)) return false;
  final effEnd = p.effectiveTo?.toUtc();
  if (effEnd != null && !slotStartUtc.isBefore(effEnd)) return false;
  return true;
}

bool _sportMatches(PricingRuleModel p, ScheduleResultGroup group) {
  final rs = p.sport?.trim();
  if (rs == null || rs.isEmpty) return true;
  final resSport = group.resource?.sport?.trim();
  if (resSport == null || resSport.isEmpty) return false;
  return resSport.toLowerCase() == rs.toLowerCase();
}

int _timeWindowSpecificity(PricingRuleModel p) {
  final st = _secondsFromMidnight(p.startTime);
  final et = _secondsFromMidnight(p.endTime);
  if (st == null && et == null) return 86400;
  final lo = st ?? 0;
  final hi = et ?? (24 * 3600 - 1);
  final w = hi - lo;
  return w < 0 ? 0 : w;
}

/// Best matching active price for one clock hour on the venue-local calendar day.
int? bestPriceForLocalHour(
  ScheduleResultGroup group,
  tz.Location location,
  int year,
  int month,
  int day,
  int hour,
) {
  final dayStart = tz.TZDateTime(location, year, month, day, 0, 0, 0);
  final slotLocal = tz.TZDateTime(location, year, month, day, hour, 0);
  final apiDow = slotLocal.weekday == DateTime.sunday ? 0 : slotLocal.weekday;
  final slotStartUtc = slotLocal.toUtc();
  final slotEndUtc = slotLocal.add(const Duration(hours: 1)).toUtc();
  final slotStartSecond = slotLocal.difference(dayStart).inSeconds;

  final candidates = <PricingRuleModel>[];
  for (final p in group.pricing) {
    if (p.status != null && p.status!.toLowerCase() != 'active') continue;
    if (p.dayOfWeek != null && p.dayOfWeek != apiDow) continue;
    if (!_sportMatches(p, group)) continue;
    if (!_ruleEffectiveOverlapsSlotUtc(p, slotStartUtc, slotEndUtc)) continue;
    if (!_ruleTimeMatchesMinute(p, slotStartSecond)) continue;
    final v = p.priceInt;
    if (v <= 0) continue;
    candidates.add(p);
  }
  if (candidates.isEmpty) return null;

  candidates.sort((a, b) {
    final pa = a.priority ?? 0;
    final pb = b.priority ?? 0;
    if (pa != pb) return pb.compareTo(pa);
    final sa = _timeWindowSpecificity(a);
    final sb = _timeWindowSpecificity(b);
    if (sa != sb) return sa.compareTo(sb);
    final fa = a.effectiveFrom ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final fb = b.effectiveFrom ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    final c = fb.compareTo(fa);
    if (c != 0) return c;
    return b.id.compareTo(a.id);
  });
  return candidates.first.priceInt;
}

/// One entry per booked hour from [startHour] inclusive to [endHour] exclusive (venue-local).
List<int> hourlyPricesForRange(
  ScheduleResultGroup group,
  tz.Location location,
  int year,
  int month,
  int day,
  int startHourInclusive,
  int endHourExclusive,
) {
  final out = <int>[];
  final fallback = group.minPriceInt ?? 0;
  for (var h = startHourInclusive; h < endHourExclusive; h++) {
    out.add(bestPriceForLocalHour(group, location, year, month, day, h) ?? fallback);
  }
  return out;
}

/// Collapse [hourlyPrices] into consecutive runs of the same rate (for UI breakdown).
List<(int rate, int hours)> mergeAdjacentHourPrices(List<int> hourlyPrices) {
  if (hourlyPrices.isEmpty) return const [];
  final out = <(int, int)>[];
  var cur = hourlyPrices.first;
  var n = 1;
  for (var i = 1; i < hourlyPrices.length; i++) {
    final p = hourlyPrices[i];
    if (p == cur) {
      n++;
    } else {
      out.add((cur, n));
      cur = p;
      n = 1;
    }
  }
  out.add((cur, n));
  return out;
}
