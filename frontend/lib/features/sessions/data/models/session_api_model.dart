/// Backend `SessionResp` from the session microservice (snake_case JSON).
class SessionApiModel {
  final String id;
  final String? templateId;
  final String? ownerId;
  final String venueId;
  final String resourceId;
  final String name;
  final String? description;
  final String mode;
  final String sport;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime locksAt;
  final String timezone;
  final int minParticipants;
  final int maxParticipants;
  final int participantCount;
  final String pricingModel;
  final int? priceTotalMinor;
  final int? pricePerPersonMinor;
  final int? lockedPricePerPersonMinor;
  final String currency;
  final String visibility;
  final String status;
  final String? cancelReason;
  final int? priceRangeMinMinor;
  final int? priceRangeMaxMinor;
  final bool slotAvailable;
  final List<SessionOccupiedSlot> occupiedSlots;

  const SessionApiModel({
    required this.id,
    this.templateId,
    this.ownerId,
    required this.venueId,
    required this.resourceId,
    required this.name,
    this.description,
    required this.mode,
    required this.sport,
    required this.startsAt,
    required this.endsAt,
    required this.locksAt,
    required this.timezone,
    required this.minParticipants,
    required this.maxParticipants,
    required this.participantCount,
    required this.pricingModel,
    this.priceTotalMinor,
    this.pricePerPersonMinor,
    this.lockedPricePerPersonMinor,
    required this.currency,
    required this.visibility,
    required this.status,
    this.cancelReason,
    this.priceRangeMinMinor,
    this.priceRangeMaxMinor,
    this.slotAvailable = true,
    this.occupiedSlots = const [],
  });

  factory SessionApiModel.fromJson(Map<String, dynamic> json) {
    final priceRange = json['price_range'] as Map<String, dynamic>?;
    return SessionApiModel(
      id: json['id']?.toString() ?? '',
      templateId: json['template_id']?.toString(),
      ownerId: json['owner_id']?.toString(),
      venueId: json['venue_id']?.toString() ?? '',
      resourceId: json['resource_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      mode: json['mode']?.toString() ?? 'scheduled',
      sport: json['sport']?.toString() ?? 'other',
      startsAt: DateTime.parse(json['starts_at'] as String).toUtc(),
      endsAt: DateTime.parse(json['ends_at'] as String).toUtc(),
      locksAt: DateTime.parse(json['locks_at'] as String).toUtc(),
      timezone: json['timezone']?.toString() ?? 'UTC',
      minParticipants: _int(json['min_participants'], 2),
      maxParticipants: _int(json['max_participants'], 2),
      participantCount: _int(json['participant_count'], 0),
      pricingModel: json['pricing_model']?.toString() ?? 'per_person',
      priceTotalMinor: _nullableInt(json['price_total_minor']),
      pricePerPersonMinor: _nullableInt(json['price_per_person_minor']),
      lockedPricePerPersonMinor:
          _nullableInt(json['locked_price_per_person_minor']),
      currency: json['currency']?.toString() ?? 'KZT',
      visibility: json['visibility']?.toString() ?? 'public',
      status: json['status']?.toString() ?? 'open',
      cancelReason: json['cancel_reason']?.toString(),
      priceRangeMinMinor: priceRange != null
          ? _nullableInt(priceRange['min_minor'])
          : null,
      priceRangeMaxMinor: priceRange != null
          ? _nullableInt(priceRange['max_minor'])
          : null,
      slotAvailable: json['slot_available'] as bool? ?? true,
      occupiedSlots: (json['occupied_slots'] as List<dynamic>?)
              ?.map(
                (e) => SessionOccupiedSlot.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  bool get hasSlotConflict => !slotAvailable || occupiedSlots.isNotEmpty;

  bool get isOpen => status == 'open';
  bool get isFull => participantCount >= maxParticipants;
  bool get isJoinable {
    if (!isOpen) return false;
    if (isFull) return false;
    if (hasSlotConflict) return false;
    return locksAt.isAfter(DateTime.now().toUtc());
  }

  static int _int(dynamic v, int fallback) =>
      int.tryParse(v?.toString() ?? '') ?? fallback;

  static int? _nullableInt(dynamic v) {
    if (v == null) return null;
    return int.tryParse(v.toString());
  }
}

class SessionOccupiedSlot {
  final DateTime startAtUtc;
  final DateTime endAtUtc;
  final String? source;

  const SessionOccupiedSlot({
    required this.startAtUtc,
    required this.endAtUtc,
    this.source,
  });

  factory SessionOccupiedSlot.fromJson(Map<String, dynamic> json) {
    final start = json['start_at'] as String?;
    final end = json['end_at'] as String?;
    return SessionOccupiedSlot(
      startAtUtc: start != null
          ? DateTime.parse(start).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endAtUtc: end != null
          ? DateTime.parse(end).toUtc()
          : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      source: json['source']?.toString(),
    );
  }
}

class SessionListPageResult {
  final List<SessionApiModel> items;
  final int total;
  final int page;
  final int pageSize;

  const SessionListPageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => page * pageSize < total;
}

class SessionParticipantModel {
  final String id;
  final String sessionId;
  final String userId;
  final int quotedPriceMinor;
  final int? finalPriceMinor;
  final String currency;
  final String paymentStatus;
  final String status;
  final DateTime joinedAt;

  const SessionParticipantModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.quotedPriceMinor,
    this.finalPriceMinor,
    required this.currency,
    required this.paymentStatus,
    required this.status,
    required this.joinedAt,
  });

  factory SessionParticipantModel.fromJson(Map<String, dynamic> json) {
    return SessionParticipantModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      quotedPriceMinor: SessionApiModel._int(json['quoted_price_minor'], 0),
      finalPriceMinor: SessionApiModel._nullableInt(json['final_price_minor']),
      currency: json['currency']?.toString() ?? 'KZT',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      status: json['status']?.toString() ?? 'confirmed',
      joinedAt: DateTime.parse(json['joined_at'] as String).toUtc(),
    );
  }
}
