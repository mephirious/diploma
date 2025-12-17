import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_model.freezed.dart';
part 'reservation_model.g.dart';

@freezed
class ReservationModel with _$ReservationModel {
  const factory ReservationModel({
    required String id,
    required String userId,
    required String apartmentId,
    required String status,
    String? comment,
    DateTime? reservedAt,
  }) = _ReservationModel;

  factory ReservationModel.fromJson(Map<String, dynamic> json) =>
      _$ReservationModelFromJson(json);
}

