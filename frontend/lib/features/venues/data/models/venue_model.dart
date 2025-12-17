import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue_model.freezed.dart';
part 'venue_model.g.dart';

@freezed
class VenueModel with _$VenueModel {
  const factory VenueModel({
    required String id,
    required String name,
    required String description,
    required String city,
    required String address,
    double? latitude,
    double? longitude,
    @Default([]) List<ResourceModel> resources,
  }) = _VenueModel;

  factory VenueModel.fromJson(Map<String, dynamic> json) =>
      _$VenueModelFromJson(json);
}

@freezed
class ResourceModel with _$ResourceModel {
  const factory ResourceModel({
    required String id,
    required String venueId,
    required String name,
    required String sportType,
    int? capacity,
    String? surfaceType,
    @Default(true) bool isActive,
  }) = _ResourceModel;

  factory ResourceModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceModelFromJson(json);
}

