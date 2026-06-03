import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../venues/data/repositories/venue_repository.dart';
import '../../../venues/data/models/resource_model.dart';
import '../../../venues/data/models/venue_model.dart';
import '../../data/models/session_api_model.dart';
import '../../data/models/session_model_simple.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/session_mapper.dart';
import '../../data/session_service_exception.dart';

class SessionsListState {
  final List<SessionModelSimple> items;
  final bool loading;
  final bool refreshing;
  final String? error;
  final Set<String> actionInProgress;

  const SessionsListState({
    this.items = const [],
    this.loading = false,
    this.refreshing = false,
    this.error,
    this.actionInProgress = const {},
  });

  SessionsListState copyWith({
    List<SessionModelSimple>? items,
    bool? loading,
    bool? refreshing,
    String? error,
    Set<String>? actionInProgress,
    bool clearError = false,
  }) {
    return SessionsListState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      error: clearError ? null : (error ?? this.error),
      actionInProgress: actionInProgress ?? this.actionInProgress,
    );
  }
}

final sessionsListProvider =
    NotifierProvider<SessionsListNotifier, SessionsListState>(
  SessionsListNotifier.new,
);

class SessionsListNotifier extends Notifier<SessionsListState> {
  @override
  SessionsListState build() => const SessionsListState();

  Future<void> ensureLoaded() async {
    if (state.items.isNotEmpty || state.loading) return;
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      loading: state.items.isEmpty,
      refreshing: true,
      clearError: true,
    );
    try {
      final sport = ref.read(selectedSportFilterProvider);
      final time = ref.read(selectedTimeFilterProvider);
      final pickedDate = ref.read(selectedSessionDateProvider);

      final now = DateTime.now();
      DateTime? dateFrom;
      DateTime? dateTo;
      String? status;

      switch (time) {
        case 'now':
          dateFrom = now.toUtc();
          status = 'open';
          break;
        case 'today':
          final start = DateTime(now.year, now.month, now.day);
          dateFrom = start.toUtc();
          dateTo = start
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1))
              .toUtc();
          break;
        case 'date':
          if (pickedDate != null) {
            final start =
                DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
            dateFrom = start.toUtc();
            dateTo = start
                .add(const Duration(days: 1))
                .subtract(const Duration(milliseconds: 1))
                .toUtc();
          }
          break;
        default:
          dateFrom = now.toUtc();
      }

      final repo = ref.read(sessionRepositoryProvider);
      final page = await repo.listSessions(
        sport: sport == 'all' ? null : sport,
        status: status ?? 'open',
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      var apiItems = page.items;
      if (time == 'now') {
        final utcNow = DateTime.now().toUtc();
        apiItems = apiItems
            .where(
              (s) =>
                  s.startsAt.isBefore(utcNow.add(const Duration(hours: 2))) &&
                  s.endsAt.isAfter(utcNow),
            )
            .toList();
      }

      final enriched = await _enrich(apiItems);
      state = state.copyWith(
        items: enriched,
        loading: false,
        refreshing: false,
        clearError: true,
      );
    } on SessionServiceException catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        refreshing: false,
        error: e.toString(),
      );
    }
  }

  Future<List<SessionModelSimple>> _enrich(
      List<SessionApiModel> apiItems) async {
    if (apiItems.isEmpty) return const [];

    final venueRepo = ref.read(venueRepositoryProvider);
    final isLoggedIn = ref.read(isLoggedInProvider);
    final userId = ref.read(authProvider).authUser?.sub;

    final venueCache = <String, VenueModel?>{};
    final resourceCache = <String, ResourceModel?>{};

    Future<void> loadVenue(String id) async {
      if (venueCache.containsKey(id)) return;
      venueCache[id] = await venueRepo.getVenueById(id);
    }

    Future<void> loadResource(String id) async {
      if (resourceCache.containsKey(id)) return;
      resourceCache[id] = await venueRepo.getResourceById(id);
    }

    await Future.wait([
      ...apiItems.map((s) => loadVenue(s.venueId)),
      ...apiItems.map((s) => loadResource(s.resourceId)),
    ]);

    final repo = ref.read(sessionRepositoryProvider);
    final joinedChecks = isLoggedIn
        ? await Future.wait(
            apiItems.map((s) => repo.isCurrentUserParticipant(s.id)),
          )
        : List<bool>.filled(apiItems.length, false);

    return List.generate(apiItems.length, (i) {
      final s = apiItems[i];
      var isJoined = joinedChecks[i];
      if (userId != null && s.ownerId == userId) {
        isJoined = false;
      }
      return SessionMapper.toDisplay(
        s,
        venue: venueCache[s.venueId],
        resource: resourceCache[s.resourceId],
        isJoined: isJoined,
      );
    });
  }

  Future<String?> joinSession(String sessionId) async {
    if (!ref.read(isLoggedInProvider)) return 'login_required';

    state = state.copyWith(
      actionInProgress: {...state.actionInProgress, sessionId},
    );

    try {
      await ref.read(sessionRepositoryProvider).joinSession(sessionId);
      state = state.copyWith(
        items: state.items.map((s) {
          if (s.id != sessionId) return s;
          return s.copyWith(
            isJoined: true,
            currentPlayers: (s.currentPlayers + 1).clamp(0, s.maxPlayers),
          );
        }).toList(),
        actionInProgress: {...state.actionInProgress}..remove(sessionId),
      );
      return null;
    } on SessionServiceException catch (e) {
      state = state.copyWith(
        actionInProgress: {...state.actionInProgress}..remove(sessionId),
      );
      if (e.isAlreadyJoined) {
        _markJoined(sessionId);
        return 'already_joined';
      }
      return e.message;
    } catch (e) {
      state = state.copyWith(
        actionInProgress: {...state.actionInProgress}..remove(sessionId),
      );
      return e.toString();
    }
  }

  Future<String?> leaveSession(String sessionId) async {
    if (!ref.read(isLoggedInProvider)) return 'login_required';

    state = state.copyWith(
      actionInProgress: {...state.actionInProgress, sessionId},
    );

    try {
      await ref.read(sessionRepositoryProvider).leaveSession(sessionId);
      state = state.copyWith(
        items: state.items.map((s) {
          if (s.id != sessionId) return s;
          return s.copyWith(
            isJoined: false,
            currentPlayers: (s.currentPlayers - 1).clamp(0, s.maxPlayers),
          );
        }).toList(),
        actionInProgress: {...state.actionInProgress}..remove(sessionId),
      );
      return null;
    } on SessionServiceException catch (e) {
      state = state.copyWith(
        actionInProgress: {...state.actionInProgress}..remove(sessionId),
      );
      return e.message;
    } catch (e) {
      state = state.copyWith(
        actionInProgress: {...state.actionInProgress}..remove(sessionId),
      );
      return e.toString();
    }
  }

  void _markJoined(String sessionId) {
    state = state.copyWith(
      items: state.items
          .map((s) => s.id == sessionId ? s.copyWith(isJoined: true) : s)
          .toList(),
    );
  }

  SessionModelSimple? findById(String id) {
    for (final s in state.items) {
      if (s.id == id) return s;
    }
    return null;
  }
}

final sessionDetailProvider = FutureProvider.autoDispose
    .family<SessionModelSimple, String>((ref, id) async {
  final repo = ref.read(sessionRepositoryProvider);
  final api = await repo.getSessionById(id);

  final venueRepo = ref.read(venueRepositoryProvider);
  final venue = await venueRepo.getVenueById(api.venueId);
  final resource = await venueRepo.getResourceById(api.resourceId);

  var isJoined = false;
  if (ref.read(isLoggedInProvider)) {
    isJoined = await repo.isCurrentUserParticipant(id);
    final userId = ref.read(authProvider).authUser?.sub;
    if (userId != null && api.ownerId == userId) {
      isJoined = false;
    }
  }

  return SessionMapper.toDisplay(
    api,
    venue: venue,
    resource: resource,
    isJoined: isJoined,
  );
});

final selectedSportFilterProvider = StateProvider<String>((ref) => 'all');
final selectedTimeFilterProvider = StateProvider<String>((ref) => 'today');
final selectedSessionDateProvider = StateProvider<DateTime?>((ref) => null);
