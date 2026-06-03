import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import 'models/chat_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

class ChatRepository {
  final ApiClient _api;

  ChatRepository(this._api);

  Future<Map<String, dynamic>> getOrCreateDirect(
    String targetUserId, {
    String? callerDisplayName,
    String? targetDisplayName,
  }) async {
    // Chat HTTP gateway uses proto JSON names (snake_case), see chat grpc_gateway.go UseProtoNames.
    final data = <String, dynamic>{'target_user_id': targetUserId};
    final c = callerDisplayName?.trim();
    final t = targetDisplayName?.trim();
    if (c != null && c.isNotEmpty) data['caller_display_name'] = c;
    if (t != null && t.isNotEmpty) data['target_display_name'] = t;
    final response = await _api.post(
      ApiEndpoints.chatConversationsDirect,
      data: data,
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> listConversations({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _api.get(
      ApiEndpoints.chatConversations,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> listMessages(
    String conversationId, {
    int pageSize = 50,
    String? before,
  }) async {
    final qp = <String, dynamic>{'page_size': pageSize};
    if (before != null && before.isNotEmpty) qp['before'] = before;
    final response = await _api.get(
      ApiEndpoints.chatMessages(conversationId),
      queryParameters: qp,
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> sendTextMessage(
    String conversationId,
    String content, {
    String? senderDisplayName,
    String? peerDisplayName,
  }) async {
    final body = <String, dynamic>{
      'type': 'MESSAGE_TYPE_TEXT',
      'content': content,
    };
    final s = senderDisplayName?.trim();
    final p = peerDisplayName?.trim();
    if (s != null && s.isNotEmpty) body['sender_display_name'] = s;
    if (p != null && p.isNotEmpty) body['peer_display_name'] = p;
    final response = await _api.post(
      ApiEndpoints.chatMessages(conversationId),
      data: body,
    );
    return _asMap(response.data);
  }

  Future<void> markRead(String conversationId) async {
    try {
      await _api.post(ApiEndpoints.chatMarkRead(conversationId), data: {});
    } on DioException catch (_) {
      // Non-fatal for UI
    }
  }

  Future<List<ChatUserSearchResult>> searchUsers(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoints.chatUsersSearch,
        queryParameters: {
          'query': query,
          'page': page,
          'page_size': pageSize,
        },
      );
      final map = _asMap(response.data);
      final raw = map['users'] ?? map['Users'];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => ChatUserSearchResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException {
      return const [];
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
