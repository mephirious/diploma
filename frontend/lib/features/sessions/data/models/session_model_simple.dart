class SessionModelSimple {
  final String id;
  final String sportType;
  final String skillLevel;
  final String venueName;
  final String venueAddress;
  final String venueImage;
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

  SessionModelSimple({
    required this.id,
    required this.sportType,
    required this.skillLevel,
    required this.venueName,
    required this.venueAddress,
    required this.venueImage,
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
  });

  int get spotsLeft => maxPlayers - currentPlayers;
  bool get isFull => spotsLeft <= 0;

  SessionModelSimple copyWith({
    String? id,
    String? sportType,
    String? skillLevel,
    String? venueName,
    String? venueAddress,
    String? venueImage,
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
  }) {
    return SessionModelSimple(
      id: id ?? this.id,
      sportType: sportType ?? this.sportType,
      skillLevel: skillLevel ?? this.skillLevel,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      venueImage: venueImage ?? this.venueImage,
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
    );
  }
}
