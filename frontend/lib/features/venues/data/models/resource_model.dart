/// Backend: venueResourceMain — a bookable resource (court, field, etc.) at a venue.
class ResourceModel {
  final String id;
  final String venueId;
  final String? name;
  final String? description;
  final String? type;
  final String? sport;
  final int? capacity;
  final String? status;
  final String? surface;
  final List<String> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ResourceModel({
    required this.id,
    required this.venueId,
    this.name,
    this.description,
    this.type,
    this.sport,
    this.capacity,
    this.status,
    this.surface,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as String? ?? '',
      venueId: json['venue_id'] as String? ?? '',
      name: json['name'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      sport: json['sport'] as String?,
      capacity: json['capacity'] as int?,
      status: json['status'] as String?,
      surface: json['surface'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  String get displayName => name?.trim().isNotEmpty == true ? name! : 'Resource $id';
  bool get isActive => status?.toLowerCase() == 'active' || status == null;
}
