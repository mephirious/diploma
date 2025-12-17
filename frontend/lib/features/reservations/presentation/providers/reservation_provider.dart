import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reservation_model.dart';
import '../../data/repositories/reservation_repository.dart';

final myReservationsProvider = FutureProvider<List<ReservationModel>>((ref) async {
  final repository = ref.watch(reservationRepositoryProvider);
  return await repository.getMyReservations();
});

