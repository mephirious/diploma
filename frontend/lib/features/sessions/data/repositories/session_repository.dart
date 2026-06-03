import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_client.dart';
import '../models/session_api_model.dart';
import '../session_service_exception.dart';

class SessionRepository {
  final DioClient _publicClient;
  final ApiClient _authClient;

  SessionRepository(this._publicClient, this._authClient);

  /// Public discovery feed — only `visibility=public` sessions from backend.
  Future<SessionListPageResult> listSessions({
    String? sport,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 50,
  }) async {
    final query = <String, dynamic>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (sport != null && sport.isNotEmpty && sport != 'all') 'sport': sport,
      if (status != null && status.isNotEmpty) 'status': status,
      if (dateFrom != null) 'date_from': dateFrom.toUtc().toIso8601String(),
      if (dateTo != null) 'date_to': dateTo.toUtc().toIso8601String(),
    };

    dynamic data;
    try {
      final response = await _authClient.get(
        ApiEndpoints.sessions,
        queryParameters: query,
        options: Options(extra: {'skipAuthRefresh': false}),
      );
      data = response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        data = await _publicClient.get(
          ApiEndpoints.sessions,
          queryParameters: query,
        );
      } else {
        throw SessionServiceException.fromDio(e);
      }
    }

    return _parseListPage(data, page, pageSize);
  }

  /// Detail — pass auth when available so link-only sessions work for participants.
  Future<SessionApiModel> getSessionById(String id) async {
    try {
      final response = await _authClient.get(ApiEndpoints.sessionById(id));
      return SessionApiModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final data = await _publicClient.get(ApiEndpoints.sessionById(id));
        if (data is Map<String, dynamic>) {
          return SessionApiModel.fromJson(data);
        }
        throw SessionServiceException('Session not found', statusCode: 404);
      }
      throw SessionServiceException.fromDio(e);
    }
  }

  Future<SessionParticipantModel> joinSession(String sessionId) async {
    try {
      final response = await _authClient.post(
        ApiEndpoints.joinSession(sessionId),
        data: const <String, dynamic>{},
      );
      return SessionParticipantModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw SessionServiceException.fromDio(e);
    }
  }

  Future<void> leaveSession(String sessionId) async {
    try {
      await _authClient.delete(ApiEndpoints.leaveSession(sessionId));
    } on DioException catch (e) {
      throw SessionServiceException.fromDio(e);
    }
  }

  /// Returns true if the current user is a confirmed participant (or session owner).
  /// Uses GET /participants — 403 means not a member.
  Future<bool> isCurrentUserParticipant(String sessionId) async {
    try {
      await _authClient.get(ApiEndpoints.sessionParticipants(sessionId));
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) return false;
      if (e.response?.statusCode == 401) return false;
      throw SessionServiceException.fromDio(e);
    }
  }

  SessionListPageResult _parseListPage(
    dynamic data,
    int page,
    int pageSize,
  ) {
    if (data is! Map<String, dynamic>) {
      return SessionListPageResult(
        items: const [],
        total: 0,
        page: page,
        pageSize: pageSize,
      );
    }
    final rawItems = data['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .map((e) => SessionApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return SessionListPageResult(
      items: items,
      total: int.tryParse(data['total']?.toString() ?? '') ?? items.length,
      page: int.tryParse(data['page']?.toString() ?? '') ?? page,
      pageSize: int.tryParse(data['page_size']?.toString() ?? '') ??
          pageSize,
    );
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    ref.watch(dioClientProvider),
    ref.watch(apiClientProvider),
  );
});
