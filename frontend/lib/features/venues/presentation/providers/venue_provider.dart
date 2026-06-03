import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/venue_model.dart';
import '../../data/models/resource_model.dart';
import '../../data/models/venue_schedule_result_model.dart';
import '../../data/models/promo_model.dart';
import '../../data/repositories/venue_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final venuesProvider = FutureProvider<List<VenueModel>>((ref) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getVenues();
});

final venueByIdProvider =
    FutureProvider.autoDispose.family<VenueModel?, String>((ref, id) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getVenueById(id);
});

/// GET /venue/v1/resources/{id} — bookable resource (use for booking cards & detail hero).
final resourceByIdProvider =
    FutureProvider.autoDispose.family<ResourceModel?, String>((ref, id) async {
  if (id.isEmpty) return null;
  final repository = ref.watch(venueRepositoryProvider);
  try {
    return await repository.getResourceById(id);
  } catch (_) {
    return null;
  }
});

/// Resources for a venue (GET /venues/{id}/resources).
final venueResourcesProvider =
    FutureProvider.autoDispose.family<List<ResourceModel>, String>((ref, venueId) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getResources(venueId);
});

/// Schedule result for a venue: resources with pricing (GET /venues/{id}/schedule-result).
final venueScheduleResultProvider =
    FutureProvider.autoDispose.family<VenueScheduleResultModel, String>((ref, venueId) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getScheduleResult(venueId);
});

/// All active promos for a venue (GET /venues/{id}/promos?status=active).
final venuePromosProvider =
    FutureProvider.autoDispose.family<List<PromoModel>, String>((ref, venueId) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getPromos(venueId);
});

/// Active promos scoped to a specific resource.
/// Family key is "$venueId|$resourceId".
final resourcePromosProvider =
    FutureProvider.autoDispose.family<List<PromoModel>, String>((ref, key) async {
  final parts = key.split('|');
  if (parts.length < 2) return [];
  final venueId = parts[0];
  final resourceId = parts[1];
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getPromos(venueId, resourceId: resourceId);
});

class PaginatedVenuesState {
  final List<VenueModel> items;
  final bool isLoadingInitial;
  /// True while refetching page 0 but still showing previous items (avoids scroll jump).
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int page;
  final int pageSize;
  /// Last requested `sport` query value; null means all categories.
  final String? sportFilter;
  /// Last requested `search` query string.
  final String searchQuery;

  const PaginatedVenuesState({
    required this.items,
    required this.isLoadingInitial,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.hasMore,
    required this.page,
    required this.pageSize,
    this.error,
    this.sportFilter,
    this.searchQuery = '',
  });

  PaginatedVenuesState copyWith({
    List<VenueModel>? items,
    bool? isLoadingInitial,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    int? page,
    int? pageSize,
    String? sportFilter,
    String? searchQuery,
  }) {
    return PaginatedVenuesState(
      items: items ?? this.items,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      error: error,
      sportFilter: sportFilter ?? this.sportFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  factory PaginatedVenuesState.initial() {
    return const PaginatedVenuesState(
      items: [],
      isLoadingInitial: true,
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: true,
      page: 0,
      pageSize: 40,
      error: null,
      sportFilter: null,
      searchQuery: '',
    );
  }
}

class PaginatedVenuesNotifier extends StateNotifier<PaginatedVenuesState> {
  final VenueRepository _repository;

  PaginatedVenuesNotifier(this._repository)
      : super(PaginatedVenuesState.initial()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage({
    String? sport,
    String search = '',
  }) async {
    final pageSize = state.pageSize;
    final staleItems = state.items;
    final keepStale = staleItems.isNotEmpty;
    try {
      state = PaginatedVenuesState(
        items: keepStale ? staleItems : const [],
        isLoadingInitial: !keepStale,
        isRefreshing: keepStale,
        isLoadingMore: false,
        hasMore: true,
        page: 0,
        pageSize: pageSize,
        error: null,
        sportFilter: sport,
        searchQuery: search,
      );
      final resp = await _repository.getVenuesPage(
        page: 0,
        pageSize: pageSize,
        search: search.isEmpty ? null : search,
        sport: sport,
      );
      state = state.copyWith(
        items: resp.venues,
        isLoadingInitial: false,
        isRefreshing: false,
        hasMore: resp.hasMore,
        page: resp.page,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInitial: false,
        isRefreshing: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true);
      final nextPage = state.page + 1;
      final q = state.searchQuery;
      final resp = await _repository.getVenuesPage(
        page: nextPage,
        pageSize: state.pageSize,
        search: q.isEmpty ? null : q,
        sport: state.sportFilter,
      );
      final merged = List<VenueModel>.from(state.items)..addAll(resp.venues);
      state = state.copyWith(
        items: merged,
        isLoadingMore: false,
        hasMore: resp.hasMore,
        page: resp.page,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }
}

final paginatedVenuesProvider =
    StateNotifierProvider<PaginatedVenuesNotifier, PaginatedVenuesState>(
  (ref) {
    final repo = ref.watch(venueRepositoryProvider);
    return PaginatedVenuesNotifier(repo);
  },
);

// ---------------------------------------------------------------------------
// Favorites
// ---------------------------------------------------------------------------

/// Holds the set of venue IDs that the current user has favorited.
/// Re-created when auth state changes (login / logout).
class FavoriteNotifier extends StateNotifier<Set<String>> {
  final VenueRepository _repo;

  FavoriteNotifier(this._repo) : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    try {
      final resp = await _repo.getFavoritesPage(page: 0, pageSize: 1000);
      state = resp.venues.map((v) => v.id).toSet();
    } catch (_) {
      // Not authenticated or network error — silently keep empty set.
    }
  }

  bool isFavorite(String venueId) => state.contains(venueId);

  Future<void> toggle(String venueId) async {
    final wasFav = state.contains(venueId);
    // Optimistic update.
    state = wasFav ? ({...state}..remove(venueId)) : {...state, venueId};
    try {
      if (wasFav) {
        await _repo.removeFavorite(venueId);
      } else {
        await _repo.addFavorite(venueId);
      }
    } catch (_) {
      // Revert on error.
      state = wasFav ? {...state, venueId} : ({...state}..remove(venueId));
    }
  }

  Future<void> refresh() => _load();
}

/// Provider that re-creates [FavoriteNotifier] whenever auth status changes
/// so favorites load fresh on login and clear on logout.
final favoriteIdsProvider =
    StateNotifierProvider<FavoriteNotifier, Set<String>>((ref) {
  // Watch auth so we rebuild when logged in/out.
  ref.watch(isLoggedInProvider);
  final repo = ref.watch(venueRepositoryProvider);
  return FavoriteNotifier(repo);
});

/// Notifier for a paginated list of favorited venues (for the Favorites page).
class FavoritesListNotifier extends StateNotifier<PaginatedVenuesState> {
  final VenueRepository _repo;

  FavoritesListNotifier(this._repo) : super(PaginatedVenuesState.initial()) {
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    state = PaginatedVenuesState(
      items: const [],
      isLoadingInitial: true,
      isRefreshing: false,
      isLoadingMore: false,
      hasMore: true,
      page: 0,
      pageSize: state.pageSize,
    );
    try {
      final resp = await _repo.getFavoritesPage(
        page: 0,
        pageSize: state.pageSize,
      );
      state = state.copyWith(
        items: resp.venues,
        isLoadingInitial: false,
        hasMore: resp.hasMore,
        page: resp.page,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingInitial: false,
        hasMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final resp = await _repo.getFavoritesPage(
        page: state.page + 1,
        pageSize: state.pageSize,
      );
      state = state.copyWith(
        items: [...state.items, ...resp.venues],
        isLoadingMore: false,
        hasMore: resp.hasMore,
        page: resp.page,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

/// Provider for the Favorites page list. Re-created on auth change.
final favoritesListProvider =
    StateNotifierProvider<FavoritesListNotifier, PaginatedVenuesState>((ref) {
  ref.watch(isLoggedInProvider);
  final repo = ref.watch(venueRepositoryProvider);
  return FavoritesListNotifier(repo);
});

