import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repository.dart';

final openSessionsProvider = FutureProvider<List<SessionModel>>((ref) async {
  final repository = ref.watch(sessionRepositoryProvider);
  return await repository.getOpenSessions();
});

final sessionByIdProvider = FutureProvider.family<SessionModel, String>((ref, id) async {
  final repository = ref.watch(sessionRepositoryProvider);
  return await repository.getSessionById(id);
});

