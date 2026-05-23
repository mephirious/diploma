import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

const int _kBookingsPageSize = 30;
const String _kBookingsSort = '-end_at';

/// Current instant in UTC for booking list `from` / `to` filters (not start-of-day).
DateTime utcNowForBookingListFilter() => DateTime.now().toUtc();

/// Shared guard/retry for tab panes — avoids skipping load when `loadingInitial` is stuck.
Future<void> ensureBookingsTabLoaded({
  required PaginatedBookingsState Function() getState,
  required Future<void> Function() loadFromScratch,
  bool onTabVisible = false,
}) async {
  var s = getState();
  if (s.items.isNotEmpty) return;
  if (s.loadingMore) return;

  if (onTabVisible) {
    if (s.loadingInitial) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      s = getState();
      if (s.items.isNotEmpty) return;
      if (!s.loadingInitial && !s.loadingMore) {
        if (s.error != null && s.error!.isNotEmpty) {
          await loadFromScratch();
        }
        return;
      }
      if (s.loadingMore) return;
      // Still loadingInitial with no items — prior load likely stalled.
    }
    await loadFromScratch();
    return;
  }

  if (s.loadingInitial) return;
  if (s.error != null && s.error!.isNotEmpty) return;
  await loadFromScratch();
}

class PaginatedBookingsState {
  final List<BookingModel> items;
  final int nextPageToFetch;
  final bool loadingInitial;
  final bool loadingMore;
  final bool hasMore;
  final String? error;

  const PaginatedBookingsState({
    required this.items,
    required this.nextPageToFetch,
    required this.loadingInitial,
    required this.loadingMore,
    required this.hasMore,
    this.error,
  });

  factory PaginatedBookingsState.initial() => const PaginatedBookingsState(
        items: [],
        nextPageToFetch: 0,
        loadingInitial: false,
        loadingMore: false,
        hasMore: true,
        error: null,
      );

  PaginatedBookingsState copyWith({
    List<BookingModel>? items,
    int? nextPageToFetch,
    bool? loadingInitial,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return PaginatedBookingsState(
      items: items ?? this.items,
      nextPageToFetch: nextPageToFetch ?? this.nextPageToFetch,
      loadingInitial: loadingInitial ?? this.loadingInitial,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Upcoming: `from` = now (UTC), `end_at >= from`, sort `-end_at`, pages from 0.
final upcomingBookingsPagedProvider =
    NotifierProvider<UpcomingBookingsPagedNotifier, PaginatedBookingsState>(
  UpcomingBookingsPagedNotifier.new,
);

class UpcomingBookingsPagedNotifier extends Notifier<PaginatedBookingsState> {
  @override
  PaginatedBookingsState build() => PaginatedBookingsState.initial();

  Future<void> reset() => _loadFromScratch();

  Future<void> ensureInitial() => ensureBookingsTabLoaded(
        getState: () => state,
        loadFromScratch: _loadFromScratch,
      );

  Future<void> ensureVisible() => ensureBookingsTabLoaded(
        getState: () => state,
        loadFromScratch: _loadFromScratch,
        onTabVisible: true,
      );

  Future<void> loadMore() async {
    final s = state;
    if (!s.hasMore || s.loadingMore || s.loadingInitial) return;
    state = s.copyWith(loadingMore: true, clearError: true);
    await _fetchPage(s.nextPageToFetch, append: true);
  }

  Future<void> _loadFromScratch() async {
    state = PaginatedBookingsState.initial().copyWith(loadingInitial: true);
    await _fetchPage(0, append: false);
  }

  Future<void> _fetchPage(int page, {required bool append}) async {
    final auth = ref.read(authProvider);
    final userId = auth.authUser?.sub ?? auth.user?.id;
    if (userId == null || userId.isEmpty) {
      state = PaginatedBookingsState.initial().copyWith(
        loadingInitial: false,
        loadingMore: false,
        hasMore: false,
        error: 'not_logged_in',
      );
      return;
    }

    final boundary = utcNowForBookingListFilter();
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.listBookingsPaged(
        userId: userId,
        page: page,
        pageSize: _kBookingsPageSize,
        listSort: _kBookingsSort,
        from: boundary,
        to: null,
      );

      final merged = append ? [...state.items, ...result.results] : result.results;
      final stop = result.results.isEmpty ||
          result.results.length < _kBookingsPageSize;
      state = PaginatedBookingsState(
        items: merged,
        nextPageToFetch: page + 1,
        loadingInitial: false,
        loadingMore: false,
        hasMore: !stop,
        error: null,
      );
    } catch (e) {
      state = PaginatedBookingsState(
        items: state.items,
        nextPageToFetch: state.nextPageToFetch,
        loadingInitial: false,
        loadingMore: false,
        hasMore: state.hasMore,
        error: e.toString(),
      );
    }
  }
}

/// Past: `to` = now (UTC), `start_at <= to`, sort `-end_at`, pages from 0.
final pastBookingsPagedProvider =
    NotifierProvider<PastBookingsPagedNotifier, PaginatedBookingsState>(
  PastBookingsPagedNotifier.new,
);

class PastBookingsPagedNotifier extends Notifier<PaginatedBookingsState> {
  @override
  PaginatedBookingsState build() => PaginatedBookingsState.initial();

  Future<void> reset() => _loadFromScratch();

  Future<void> ensureInitial() => ensureBookingsTabLoaded(
        getState: () => state,
        loadFromScratch: _loadFromScratch,
      );

  Future<void> ensureVisible() => ensureBookingsTabLoaded(
        getState: () => state,
        loadFromScratch: _loadFromScratch,
        onTabVisible: true,
      );

  Future<void> loadMore() async {
    final s = state;
    if (!s.hasMore || s.loadingMore || s.loadingInitial) return;
    state = s.copyWith(loadingMore: true, clearError: true);
    await _fetchPage(s.nextPageToFetch, append: true);
  }

  Future<void> _loadFromScratch() async {
    state = PaginatedBookingsState.initial().copyWith(loadingInitial: true);
    await _fetchPage(0, append: false);
  }

  Future<void> _fetchPage(int page, {required bool append}) async {
    final auth = ref.read(authProvider);
    final userId = auth.authUser?.sub ?? auth.user?.id;
    if (userId == null || userId.isEmpty) {
      state = PaginatedBookingsState.initial().copyWith(
        loadingInitial: false,
        loadingMore: false,
        hasMore: false,
        error: 'not_logged_in',
      );
      return;
    }

    final boundary = utcNowForBookingListFilter();
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final result = await repo.listBookingsPaged(
        userId: userId,
        page: page,
        pageSize: _kBookingsPageSize,
        listSort: _kBookingsSort,
        from: null,
        to: boundary,
      );

      final merged = append ? [...state.items, ...result.results] : result.results;
      final stop = result.results.isEmpty ||
          result.results.length < _kBookingsPageSize;
      state = PaginatedBookingsState(
        items: merged,
        nextPageToFetch: page + 1,
        loadingInitial: false,
        loadingMore: false,
        hasMore: !stop,
        error: null,
      );
    } catch (e) {
      state = PaginatedBookingsState(
        items: state.items,
        nextPageToFetch: state.nextPageToFetch,
        loadingInitial: false,
        loadingMore: false,
        hasMore: state.hasMore,
        error: e.toString(),
      );
    }
  }
}

/// Refetch bookings when opening the tab or after a new booking.
/// Past list loads when the Past tab is opened (`ensureVisible`), not eagerly here.
void resetGuestBookingLists(WidgetRef ref) {
  unawaited(ref.read(upcomingBookingsPagedProvider.notifier).reset());
  final tab = ref.read(selectedReservationTabProvider);
  if (tab == 1) {
    unawaited(ref.read(pastBookingsPagedProvider.notifier).reset());
  }
}

/// Single booking by id (for detail screen).
final bookingByIdProvider =
    FutureProvider.family<BookingModel?, String>((ref, id) async {
  final repo = ref.read(bookingRepositoryProvider);
  try {
    return await repo.getBooking(id);
  } catch (_) {
    return null;
  }
});

/// Cancel booking and reload both paged lists.
final cancelBookingProvider =
    FutureProvider.family<void, String>((ref, bookingId) async {
  final repo = ref.read(bookingRepositoryProvider);
  await repo.cancelBooking(
    bookingId,
    const BookingCancelRequest(reason: 'user_cancelled'),
  );
  await ref.read(upcomingBookingsPagedProvider.notifier).reset();
  await ref.read(pastBookingsPagedProvider.notifier).reset();
});

// Selected reservation tab (Upcoming / Past).
final selectedReservationTabProvider = StateProvider<int>((ref) => 0);
