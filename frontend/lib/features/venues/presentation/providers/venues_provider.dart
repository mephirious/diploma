import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/venue_model.dart';
import 'venue_provider.dart';

// ---------------------------------------------------------------------------
// Favorite venues list (backed by real API via favoriteIdsProvider)
// ---------------------------------------------------------------------------

/// Returns the subset of items from [paginatedVenuesProvider] that are
/// currently in the user's favorites set.
final favoriteVenuesProvider = Provider<List<VenueModel>>((ref) {
  final favIds = ref.watch(favoriteIdsProvider);
  final allVenues = ref.watch(paginatedVenuesProvider).items;
  return allVenues.where((v) => favIds.contains(v.id)).toList();
});

// ---------------------------------------------------------------------------
// Category / search filters (still used by home page)
// ---------------------------------------------------------------------------

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredVenuesProvider = Provider<List<VenueModel>>((ref) {
  final venues = ref.watch(paginatedVenuesProvider).items;
  final category = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var filtered = venues;

  if (category != 'all') {
    filtered = filtered.where((v) => v.category == category).toList();
  }

  if (searchQuery.isNotEmpty) {
    final q = searchQuery.toLowerCase();
    filtered = filtered.where((v) {
      return v.name.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q);
    }).toList();
  }

  return filtered;
});

final popularVenuesProvider = Provider<List<VenueModel>>((ref) {
  final venues = ref.watch(paginatedVenuesProvider).items;
  final sorted = List<VenueModel>.from(venues);
  sorted.sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.take(4).toList();
});
