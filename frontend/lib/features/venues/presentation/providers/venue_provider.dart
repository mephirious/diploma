import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/venue_model.dart';
import '../../data/repositories/venue_repository.dart';

final venuesProvider = FutureProvider<List<VenueModel>>((ref) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getVenues();
});

final venueByIdProvider = FutureProvider.family<VenueModel, String>((ref, id) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getVenueById(id);
});

