import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_model_simple.dart';
import '../../../../core/data/mock_data.dart';

// All sessions
final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, List<SessionModelSimple>>(
  (ref) => SessionsNotifier(),
);

class SessionsNotifier extends StateNotifier<List<SessionModelSimple>> {
  SessionsNotifier() : super(MockData.sessions);

  void joinSession(String sessionId) {
    state = state.map((session) {
      if (session.id == sessionId && !session.isFull) {
        return session.copyWith(
          currentPlayers: session.currentPlayers + 1,
        );
      }
      return session;
    }).toList();
  }

  void leaveSession(String sessionId) {
    state = state.map((session) {
      if (session.id == sessionId && session.currentPlayers > 0) {
        return session.copyWith(
          currentPlayers: session.currentPlayers - 1,
        );
      }
      return session;
    }).toList();
  }

  SessionModelSimple? getSessionById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

// Selected sport filter
final selectedSportFilterProvider = StateProvider<String>((ref) => 'all');

// Selected time filter: 'now', 'today', 'date'
final selectedTimeFilterProvider = StateProvider<String>((ref) => 'today');

// Selected skill level filter
final selectedSkillFilterProvider = StateProvider<String>((ref) => 'all');

// Filtered sessions
final filteredSessionsProvider = Provider<List<SessionModelSimple>>((ref) {
  final sessions = ref.watch(sessionsProvider);
  final sport = ref.watch(selectedSportFilterProvider);
  final time = ref.watch(selectedTimeFilterProvider);
  final skill = ref.watch(selectedSkillFilterProvider);

  var filtered = sessions;

  // Filter by sport
  if (sport != 'all') {
    filtered = filtered.where((s) => s.sportType == sport).toList();
  }

  // Filter by skill level
  if (skill != 'all') {
    filtered = filtered.where((s) => s.skillLevel == skill).toList();
  }

  // Filter by time
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (time) {
    case 'now':
      filtered = filtered.where((s) => s.isLive).toList();
      break;
    case 'today':
      filtered = filtered.where((s) {
        final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
        return sessionDate.isAtSameMomentAs(today);
      }).toList();
      break;
    default:
      break;
  }

  return filtered;
});
