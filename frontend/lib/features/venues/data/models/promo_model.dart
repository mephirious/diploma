import 'package:intl/intl.dart';

/// Promo discount type returned by the API.
enum PromoType { percentage, fixedAmount }

/// A promotional discount offered for a venue or specific resource.
class PromoModel {
  final String id;
  final String venueId;
  final String? resourceId; // null = applies to all resources of this venue
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String name;
  final String? description;

  /// null  → auto-applied (no code needed)
  /// non-null → user must enter this code to activate
  final String? code;

  final PromoType type;

  /// 1–100 for [PromoType.percentage]
  final int? discountPercent;

  /// Minor currency units (e.g. tenge×100) for [PromoType.fixedAmount]
  final int? discountMinor;

  final int? minDurationMinutes;
  final int? minBookingPriceMinor;

  final DateTime validFrom;
  final DateTime? validTo;

  final int? maxUses;
  final int usesCount;
  final int? maxUsesPerUser;

  /// 0=Sun…6=Sat; empty list = any day of week
  final List<int> applicableDays;

  final String currency;
  final String status;

  const PromoModel({
    required this.id,
    required this.venueId,
    this.resourceId,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.description,
    this.code,
    required this.type,
    this.discountPercent,
    this.discountMinor,
    this.minDurationMinutes,
    this.minBookingPriceMinor,
    required this.validFrom,
    this.validTo,
    this.maxUses,
    this.usesCount = 0,
    this.maxUsesPerUser,
    this.applicableDays = const [],
    required this.currency,
    required this.status,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String?) ?? 'percentage';
    final type =
        typeStr == 'fixed_amount' ? PromoType.fixedAmount : PromoType.percentage;

    return PromoModel(
      id: (json['id'] as String?) ?? '',
      venueId: (json['venue_id'] as String?) ?? '',
      resourceId: json['resource_id'] as String?,
      ownerId: (json['owner_id'] as String?) ?? '',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      code: json['code'] as String?,
      type: type,
      discountPercent: _parseInt(json['discount_percent']),
      discountMinor: _parseInt64(json['discount_minor']),
      minDurationMinutes: _parseInt(json['min_duration_minutes']),
      minBookingPriceMinor: _parseInt64(json['min_booking_price_minor']),
      validFrom: _parseDate(json['valid_from']),
      validTo: json['valid_to'] != null ? _parseDate(json['valid_to']) : null,
      maxUses: _parseInt(json['max_uses']),
      usesCount: _parseInt(json['uses_count']) ?? 0,
      maxUsesPerUser: _parseInt(json['max_uses_per_user']),
      applicableDays: (json['applicable_days'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      currency: (json['currency'] as String?) ?? 'KZT',
      status: (json['status'] as String?) ?? 'active',
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool get isAutoApplied => code == null || code!.isEmpty;

  bool get isActive => status == 'active';

  /// null/empty [applicableDays] → valid on any day of the week.
  bool get appliesAnyDay => applicableDays.isEmpty;

  /// API day-of-week: 0=Sun…6=Sat (Dart [DateTime.weekday] is 1=Mon…7=Sun).
  static int dayOfWeekFromDate(DateTime date) => date.weekday % 7;

  /// Whether this promo is allowed on [dayOfWeek] (0=Sun…6=Sat).
  bool isApplicableOnDay(int dayOfWeek) {
    if (appliesAnyDay) return true;
    return applicableDays.contains(dayOfWeek);
  }

  /// Whether this promo is allowed on the calendar day of [date].
  bool isApplicableOnDate(DateTime date) {
    return isApplicableOnDay(dayOfWeekFromDate(date));
  }

  /// Whether [date] falls within the promo validity window and day-of-week rules.
  bool isValidForBookingDate(DateTime date) {
    final bookingDay = DateTime(date.year, date.month, date.day);
    final fromDay =
        DateTime(validFrom.year, validFrom.month, validFrom.day);
    if (bookingDay.isBefore(fromDay)) return false;
    if (validTo != null) {
      final toDay = DateTime(validTo!.year, validTo!.month, validTo!.day);
      if (bookingDay.isAfter(toDay)) return false;
    }
    return isApplicableOnDate(date);
  }

  /// Human-readable applicable weekdays, e.g. "Mon, Wed, Fri".
  String applicableDaysLabel({String? locale}) {
    if (appliesAnyDay) return '';
    final sorted = [...applicableDays]..sort();
    final fmt = DateFormat.E(locale);
    // 2024-01-07 is a Sunday (API day 0).
    final base = DateTime(2024, 1, 7);
    return sorted
        .map((d) => fmt.format(base.add(Duration(days: d))))
        .join(', ');
  }

  /// Checks whether this promo is currently valid (date range + day of week).
  ///
  /// [dayOfWeek]: 0=Sun…6=Sat matching [applicableDays] API semantics.
  /// Prefer [isValidForBookingDate] when a specific booking date is known.
  bool isCurrentlyValid({required int dayOfWeek}) {
    final now = DateTime.now();
    if (now.isBefore(validFrom)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return isApplicableOnDay(dayOfWeek);
  }

  /// Whether the promo is fully applicable for a booking on [date].
  bool isEffectiveForBooking({
    required DateTime date,
    required int durationMinutes,
    required int bookingPriceMinor,
  }) {
    return isValidForBookingDate(date) &&
        meetsConditions(
          durationMinutes: durationMinutes,
          bookingPriceMinor: bookingPriceMinor,
        );
  }

  /// Whether the promo passes the booking-level conditions.
  ///
  /// [durationMinutes]: booked duration.
  /// [bookingPriceMinor]: undiscounted price in minor units.
  bool meetsConditions({
    required int durationMinutes,
    required int bookingPriceMinor,
  }) {
    if (minDurationMinutes != null &&
        durationMinutes < minDurationMinutes!) {
      return false;
    }
    if (minBookingPriceMinor != null &&
        bookingPriceMinor < minBookingPriceMinor!) {
      return false;
    }
    return true;
  }

  /// Returns the discounted price in minor units given [originalMinor].
  int applyTo(int originalMinor) {
    if (type == PromoType.percentage && discountPercent != null) {
      final discount = (originalMinor * discountPercent! / 100).round();
      return (originalMinor - discount).clamp(0, originalMinor);
    }
    if (type == PromoType.fixedAmount && discountMinor != null) {
      return (originalMinor - discountMinor!).clamp(0, originalMinor);
    }
    return originalMinor;
  }

  /// Human-readable discount label, e.g. "20% OFF" or "−500 ₸".
  String get discountLabel {
    if (type == PromoType.percentage && discountPercent != null) {
      return '$discountPercent% OFF';
    }
    if (type == PromoType.fixedAmount && discountMinor != null) {
      final formatted = (discountMinor! / 100).toStringAsFixed(0);
      return '−$formatted ${_currencySymbol(currency)}';
    }
    return 'OFF';
  }

  /// Short badge text for resource cards, e.g. "20%" or "−5 000".
  String get badgeText {
    if (type == PromoType.percentage && discountPercent != null) {
      return '$discountPercent%';
    }
    if (type == PromoType.fixedAmount && discountMinor != null) {
      final val = discountMinor! ~/ 100;
      return '−$val';
    }
    return 'OFF';
  }

  // ─── Private utilities ────────────────────────────────────────────────────

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    try {
      return DateTime.parse(raw as String).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static int? _parseInt64(dynamic raw) => _parseInt(raw);

  static String _currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'KZT':
        return '₸';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'RUB':
        return '₽';
      default:
        return code;
    }
  }
}
