import 'resource_model.dart';
import 'pricing_rule_model.dart';

/// Backend: venueVenueScheduleResultRep — schedule result for a venue (resources + schedules + pricing + blackouts).
class VenueScheduleResultModel {
  final String venueId;
  final List<ScheduleResultGroup> groups;

  const VenueScheduleResultModel({
    required this.venueId,
    this.groups = const [],
  });

  factory VenueScheduleResultModel.fromJson(Map<String, dynamic> json) {
    final groupsList = json['groups'] as List<dynamic>?;
    return VenueScheduleResultModel(
      venueId: json['venue_id'] as String? ?? '',
      groups: groupsList
              ?.map((e) => ScheduleResultGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Weekly schedule row from API.
class ResourceScheduleEntryModel {
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? timezone;
  final String? status;

  const ResourceScheduleEntryModel({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.timezone,
    this.status,
  });

  factory ResourceScheduleEntryModel.fromJson(Map<String, dynamic> json) {
    return ResourceScheduleEntryModel(
      dayOfWeek: json['day_of_week'] as int? ?? 0,
      startTime: json['start_time'] as String? ?? '00:00:00',
      endTime: json['end_time'] as String? ?? '00:00:00',
      timezone: json['timezone'] as String?,
      status: json['status'] as String?,
    );
  }

  bool get isActive =>
      status == null || status!.toLowerCase() == 'active';
}

/// Maintenance / blackout interval (UTC from API).
class BlackoutModel {
  final DateTime startAtUtc;
  final DateTime endAtUtc;
  final String? status;

  const BlackoutModel({
    required this.startAtUtc,
    required this.endAtUtc,
    this.status,
  });

  factory BlackoutModel.fromJson(Map<String, dynamic> json) {
    final s = json['start_at'] as String?;
    final e = json['end_at'] as String?;
    return BlackoutModel(
      startAtUtc: s != null ? DateTime.parse(s).toUtc() : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endAtUtc: e != null ? DateTime.parse(e).toUtc() : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      status: json['status'] as String?,
    );
  }

  bool get isActive =>
      status == null || status!.toLowerCase() == 'active';
}

/// One resource with its schedules, pricing rules, and blackouts.
class ScheduleResultGroup {
  final String? resourceId;
  final ResourceModel? resource;
  final List<ResourceScheduleEntryModel> schedules;
  final List<PricingRuleModel> pricing;
  final List<BlackoutModel> blackouts;

  const ScheduleResultGroup({
    this.resourceId,
    this.resource,
    this.schedules = const [],
    this.pricing = const [],
    this.blackouts = const [],
  });

  factory ScheduleResultGroup.fromJson(Map<String, dynamic> json) {
    final resourceJson = json['resource'] as Map<String, dynamic>?;
    final pricingList = json['pricing'] as List<dynamic>?;
    final schedulesList = json['schedules'] as List<dynamic>?;
    final blackoutsList = json['blackouts'] as List<dynamic>?;
    return ScheduleResultGroup(
      resourceId: json['resource_id'] as String?,
      resource: resourceJson != null ? ResourceModel.fromJson(resourceJson) : null,
      schedules: schedulesList
              ?.map((e) => ResourceScheduleEntryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pricing: pricingList
              ?.map((e) => PricingRuleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      blackouts: blackoutsList
              ?.map((e) => BlackoutModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// At least one active weekly schedule row — required to book.
  bool get isBookable =>
      schedules.any((s) => s.isActive);

  /// Best display price: minimum price from rules, or null if none.
  int? get minPriceInt {
    if (pricing.isEmpty) return null;
    var min = pricing.first.priceInt;
    for (final p in pricing) {
      final v = p.priceInt;
      if (v > 0 && (min == 0 || v < min)) min = v;
    }
    return min == 0 ? null : min;
  }

  /// Lowest active price among rules for [apiDayOfWeek] (ignores time-of-day windows).
  /// For checkout totals, use [hourlyPricesForRange] in `booking_availability.dart` instead.
  int? priceForApiDay(int apiDayOfWeek) {
    final rules = pricing
        .where(
          (p) =>
              p.status == null || p.status!.toLowerCase() == 'active',
        )
        .toList();
    final dayRules =
        rules.where((p) => p.dayOfWeek == apiDayOfWeek).toList();
    if (dayRules.isEmpty) return minPriceInt;
    int? minV;
    for (final p in dayRules) {
      final v = p.priceInt;
      if (v > 0 && (minV == null || v < minV)) minV = v;
    }
    return minV ?? minPriceInt;
  }

  String? get currencyCode =>
      pricing.isNotEmpty ? pricing.first.currencyCode : null;
}
