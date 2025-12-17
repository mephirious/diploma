import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String id,
    required String reservationId,
    required String hostId,
    required String sportType,
    String? skillLevel,
    required int maxParticipants,
    int? minParticipants,
    required int currentParticipants,
    required double pricePerParticipant,
    required String visibility,
    required String status,
    String? description,
  }) = _SessionModel;

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);
}

