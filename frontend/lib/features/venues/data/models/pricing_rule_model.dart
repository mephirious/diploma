/// Backend: venuePricingRuleMain — price rule for a resource (e.g. per hour, by day).
class PricingRuleModel {
  final String id;
  final String venueId;
  final String? resourceId;
  final String price; // int64 as string
  final String? currency;
  final int? dayOfWeek; // 0-6, optional
  final String? startTime;
  final String? endTime;
  final String? sport;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final int? priority;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PricingRuleModel({
    required this.id,
    required this.venueId,
    this.resourceId,
    required this.price,
    this.currency,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.sport,
    this.effectiveFrom,
    this.effectiveTo,
    this.priority,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PricingRuleModel.fromJson(Map<String, dynamic> json) {
    return PricingRuleModel(
      id: json['id'] as String? ?? '',
      venueId: json['venue_id'] as String? ?? '',
      resourceId: json['resource_id'] as String?,
      price: json['price']?.toString() ?? '0',
      currency: json['currency'] as String?,
      dayOfWeek: json['day_of_week'] as int?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      sport: json['sport'] as String?,
      effectiveFrom: _parseDateTime(json['effective_from']),
      effectiveTo: _parseDateTime(json['effective_to']),
      priority: json['priority'] as int?,
      status: json['status'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  int get priceInt => int.tryParse(price) ?? 0;
  String get currencyCode => currency?.trim().isNotEmpty == true ? currency! : 'KZT';
}
