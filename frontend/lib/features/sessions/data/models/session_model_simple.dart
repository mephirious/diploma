/// UI-facing session row used by list cards and detail screens.
class SessionModelSimple {
  final String id;
  final String sportType;
  final String skillLevel;
  /// Session or resource title shown on cards and detail hero.
  final String sessionTitle;
  /// Bookable resource name (court, field, etc.).
  final String resourceName;
  final String venueName;
  final String venueAddress;
  /// Venue photo (payment / venue block), not the session hero image.
  final String venueImage;
  /// Resource photo for session card and detail hero.
  final String coverImage;
  final String hostName;
  final String hostAvatar;
  final int maxPlayers;
  final int currentPlayers;
  final double pricePerPlayer;
  final List<String> timeSlots;
  final DateTime date;
  final bool isLive;
  final double distance;
  final String description;

  // API-backed fields for join/leave rules
  final String status;
  final String? cancelReason;
  final String mode;
  final DateTime locksAt;
  final String? ownerId;
  final int minParticipants;
  final String pricingModel;
  final String currency;
  final int? priceTotalMinor;
  final int? pricePerPersonMinor;
  final int? priceRangeMinMinor;
  final int? priceRangeMaxMinor;
  final String venueId;
  final String resourceId;
  final bool isJoined;
  final bool slotAvailable;

  String get displayTitle {
    if (sessionTitle.trim().isNotEmpty) return sessionTitle.trim();
    if (resourceName.trim().isNotEmpty) return resourceName.trim();
    return venueName;
  }

  bool get hasVenueInfo =>
      venueName.trim().isNotEmpty || venueAddress.trim().isNotEmpty;

  SessionModelSimple({
    required this.id,
    required this.sportType,
    required this.skillLevel,
    this.sessionTitle = '',
    this.resourceName = '',
    required this.venueName,
    required this.venueAddress,
    required this.venueImage,
    this.coverImage = '',
    required this.hostName,
    required this.hostAvatar,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.pricePerPlayer,
    required this.timeSlots,
    required this.date,
    this.isLive = false,
    required this.distance,
    this.description = '',
    this.status = 'open',
    this.cancelReason,
    this.mode = 'scheduled',
    DateTime? locksAt,
    this.ownerId,
    this.minParticipants = 2,
    this.pricingModel = 'per_person',
    this.currency = 'KZT',
    this.priceTotalMinor,
    this.pricePerPersonMinor,
    this.priceRangeMinMinor,
    this.priceRangeMaxMinor,
    this.venueId = '',
    this.resourceId = '',
    this.isJoined = false,
    this.slotAvailable = true,
  }) : locksAt = locksAt ?? DateTime.now().toUtc().add(const Duration(hours: 1));

  int get spotsLeft => maxPlayers - currentPlayers;
  bool get isFull => spotsLeft <= 0;
  bool get isCancelled => status == 'cancelled';

  bool get canJoin {
    if (isJoined) return false;
    if (status != 'open') return false;
    if (isFull) return false;
    if (!slotAvailable) return false;
    return locksAt.isAfter(DateTime.now().toUtc());
  }

  bool get canLeave {
    if (!isJoined) return false;
    return status == 'open';
  }

  SessionModelSimple copyWith({
    String? id,
    String? sportType,
    String? skillLevel,
    String? sessionTitle,
    String? resourceName,
    String? venueName,
    String? venueAddress,
    String? venueImage,
    String? coverImage,
    String? hostName,
    String? hostAvatar,
    int? maxPlayers,
    int? currentPlayers,
    double? pricePerPlayer,
    List<String>? timeSlots,
    DateTime? date,
    bool? isLive,
    double? distance,
    String? description,
    String? status,
    String? cancelReason,
    String? mode,
    DateTime? locksAt,
    String? ownerId,
    int? minParticipants,
    String? pricingModel,
    String? currency,
    int? priceTotalMinor,
    int? pricePerPersonMinor,
    int? priceRangeMinMinor,
    int? priceRangeMaxMinor,
    String? venueId,
    String? resourceId,
    bool? isJoined,
    bool? slotAvailable,
  }) {
    return SessionModelSimple(
      id: id ?? this.id,
      sportType: sportType ?? this.sportType,
      skillLevel: skillLevel ?? this.skillLevel,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      resourceName: resourceName ?? this.resourceName,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      venueImage: venueImage ?? this.venueImage,
      coverImage: coverImage ?? this.coverImage,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      pricePerPlayer: pricePerPlayer ?? this.pricePerPlayer,
      timeSlots: timeSlots ?? this.timeSlots,
      date: date ?? this.date,
      isLive: isLive ?? this.isLive,
      distance: distance ?? this.distance,
      description: description ?? this.description,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
      mode: mode ?? this.mode,
      locksAt: locksAt ?? this.locksAt,
      ownerId: ownerId ?? this.ownerId,
      minParticipants: minParticipants ?? this.minParticipants,
      pricingModel: pricingModel ?? this.pricingModel,
      currency: currency ?? this.currency,
      priceTotalMinor: priceTotalMinor ?? this.priceTotalMinor,
      pricePerPersonMinor: pricePerPersonMinor ?? this.pricePerPersonMinor,
      priceRangeMinMinor: priceRangeMinMinor ?? this.priceRangeMinMinor,
      priceRangeMaxMinor: priceRangeMaxMinor ?? this.priceRangeMaxMinor,
      venueId: venueId ?? this.venueId,
      resourceId: resourceId ?? this.resourceId,
      isJoined: isJoined ?? this.isJoined,
      slotAvailable: slotAvailable ?? this.slotAvailable,
    );
  }
}
