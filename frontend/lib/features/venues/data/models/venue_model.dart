/// Contact entry from API (`phone`, `email`, or `link`).
class VenueContact {
  final String label;
  final String? phone;
  final String? email;
  final String? link;

  const VenueContact({
    required this.label,
    this.phone,
    this.email,
    this.link,
  });

  static String? _opt(String? raw) {
    final t = raw?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }

  factory VenueContact.fromApiJson(Map<String, dynamic> json) {
    return VenueContact(
      label: (json['description'] as String?)?.trim() ?? '',
      phone: _opt(json['phone'] as String?),
      email: _opt(json['email'] as String?),
      link: _opt(json['link'] as String?),
    );
  }

  bool get hasPhone => phone != null;
  bool get hasEmail => email != null;
  bool get hasLink => link != null;
}

class VenueModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String address;
  /// Street line from API (`address_line1`); used for map/directions links.
  final String addressLine1;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> amenities;
  final String openingHours;
  final bool isOpen;
  bool isFavorite;
  final double distance;
  final List<VenueContact> contacts;
  /// IANA timezone from API (e.g. Asia/Almaty), used for booking requests.
  final String? timezone;
  /// Venue owner user id (for in-app messaging).
  final String? ownerId;

  VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    this.addressLine1 = '',
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.amenities,
    required this.openingHours,
    required this.isOpen,
    this.isFavorite = false,
    this.distance = 0.0,
    this.contacts = const [],
    this.timezone,
    this.ownerId,
  });

  VenueModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? address,
    String? addressLine1,
    double? latitude,
    double? longitude,
    double? pricePerHour,
    double? rating,
    int? reviewCount,
    List<String>? images,
    List<String>? amenities,
    String? openingHours,
    bool? isOpen,
    bool? isFavorite,
    double? distance,
    List<VenueContact>? contacts,
    String? timezone,
    String? ownerId,
  }) {
    return VenueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      addressLine1: addressLine1 ?? this.addressLine1,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      openingHours: openingHours ?? this.openingHours,
      isOpen: isOpen ?? this.isOpen,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
      contacts: contacts ?? this.contacts,
      timezone: timezone ?? this.timezone,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      addressLine1: (json['addressLine1'] as String?)?.trim() ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      images: List<String>.from(json['images'] as List),
      amenities: List<String>.from(json['amenities'] as List),
      openingHours: json['openingHours'] as String,
      isOpen: json['isOpen'] as bool,
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      distance: (json['distance'] as num? ?? 0.0).toDouble(),
      contacts: const [],
      timezone: json['timezone'] as String?,
      ownerId: null,
    );
  }

  /// Factory for mapping backend `/venues` API responses (`venueVenueMain`).
  ///
  /// The backend model does not provide some UI fields (price, rating, etc.),
  /// so we use safe defaults for them to keep the UI functional.
  factory VenueModel.fromApiJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final sports = (json['sports'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    final addressLine1 = (json['address_line1'] as String?) ?? '';
    final addressLine2 = (json['address_line2'] as String?) ?? '';
    final city = (json['city'] as String?) ?? '';
    final country = (json['country'] as String?) ?? '';

    final parts = <String>[
      addressLine1,
      addressLine2,
      city,
      country,
    ].where((p) => p.trim().isNotEmpty).toList();

    final fullAddress = parts.join(', ');

    final contactsRaw = json['contacts'] as List<dynamic>? ?? const [];
    final contacts = contactsRaw
        .map((e) => VenueContact.fromApiJson(e as Map<String, dynamic>))
        .where((c) => c.hasPhone || c.hasEmail || c.hasLink)
        .toList();

    final tzRaw =
        (json['timezone'] ?? json['time_zone']) as String?;
    final timezone =
        tzRaw != null && tzRaw.trim().isNotEmpty ? tzRaw.trim() : null;

    final ownerRaw = (json['owner_id'] ?? json['ownerId'])?.toString().trim();
    final ownerId =
        ownerRaw != null && ownerRaw.isNotEmpty ? ownerRaw : null;

    return VenueModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: sports.isNotEmpty ? sports.first : 'other',
      address: fullAddress,
      addressLine1: addressLine1.trim(),
      latitude: (location?['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location?['lng'] as num?)?.toDouble() ?? 0.0,
      // Backend does not currently provide these; keep neutral defaults.
      pricePerHour: 0.0,
      rating: 0.0,
      reviewCount: 0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      amenities: const <String>[],
      openingHours: '',
      isOpen: true,
      isFavorite: (json['is_favorite'] as bool?) ?? false,
      distance: 0.0,
      contacts: contacts,
      timezone: timezone,
      ownerId: ownerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'address': address,
      'addressLine1': addressLine1,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerHour': pricePerHour,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'amenities': amenities,
      'openingHours': openingHours,
      'isOpen': isOpen,
      'isFavorite': isFavorite,
      'distance': distance,
      'contacts': contacts
          .map(
            (c) => <String, dynamic>{
              'description': c.label,
              if (c.phone != null) 'phone': c.phone,
              if (c.email != null) 'email': c.email,
              if (c.link != null) 'link': c.link,
            },
          )
          .toList(),
      if (timezone != null) 'timezone': timezone,
      if (ownerId != null) 'owner_id': ownerId,
    };
  }
}
