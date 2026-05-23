import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/chat_repository.dart';
import '../../data/models/chat_model.dart';

/// Conversation open in [ChatDetailPage]; avoids unread increment for that thread.
final openChatConversationIdProvider = StateProvider<String?>((ref) => null);

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatUiState>((ref) {
  return ChatController(ref);
});

class ChatUiState {
  final List<ChatConversation> conversations;
  final Map<String, List<ChatMessage>> messagesByConversationId;
  final bool isBootstrapping;
  final bool wsConnected;
  final String? error;

  const ChatUiState({
    this.conversations = const [],
    this.messagesByConversationId = const {},
    this.isBootstrapping = false,
    this.wsConnected = false,
    this.error,
  });

  ChatUiState copyWith({
    List<ChatConversation>? conversations,
    Map<String, List<ChatMessage>>? messagesByConversationId,
    bool? isBootstrapping,
    bool? wsConnected,
    String? error,
    bool clearError = false,
  }) {
    return ChatUiState(
      conversations: conversations ?? this.conversations,
      messagesByConversationId:
          messagesByConversationId ?? this.messagesByConversationId,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      wsConnected: wsConnected ?? this.wsConnected,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatController extends StateNotifier<ChatUiState> {
  ChatController(this._ref) : super(const ChatUiState());

  final Ref _ref;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _wsSub;
  Timer? _pollTimer;

  ChatRepository get _repo => _ref.read(chatRepositoryProvider);

  String? get _myId => _ref.read(authProvider).authUser?.sub;

  /// Profile [UserModel.fullName] first (account API), then JWT-based [AuthUser.chatDisplayName].
  /// Matches owner web `getMyDisplayName` using loaded profile instead of token claims alone.
  String _myChatDisplayName() {
    final auth = _ref.read(authProvider);
    final profileName = auth.user?.fullName.trim();
    if (profileName != null && profileName.isNotEmpty) {
      return profileName;
    }
    return auth.authUser?.chatDisplayName ?? 'user';
  }

  void onUserAuthenticated() {
    unawaited(bootstrap());
  }

  void onLogout() {
    _pollTimer?.cancel();
    _pollTimer = null;
    unawaited(_wsSub?.cancel());
    _wsSub = null;
    final ch = _channel;
    _channel = null;
    if (ch != null) {
      unawaited(ch.sink.close());
    }
    state = const ChatUiState();
  }

  Future<void> bootstrap() async {
    final myId = _myId;
    if (myId == null || myId.isEmpty) return;
    state = state.copyWith(isBootstrapping: true, clearError: true);
    try {
      await refreshConversations();
      await _connectWebSocket();
      _subscribeAllConversationChannels();
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        unawaited(refreshConversations(silent: true));
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isBootstrapping: false);
    }
  }

  /// Replace conversation list from API (recent first).
  Future<void> refreshConversations({bool silent = false}) async {
    final myId = _myId;
    if (myId == null || myId.isEmpty) return;

    try {
      final body = await _repo.listConversations(page: 1, pageSize: 50);
      final list = body['conversations'] as List<dynamic>? ?? const [];
      final msgsCache = state.messagesByConversationId;
      final next = <ChatConversation>[];
      for (final raw in list) {
        ChatConversation conv;
        if (raw is Map<String, dynamic>) {
          conv = _conversationFromApi(raw, myId);
        } else if (raw is Map) {
          conv = _conversationFromApi(Map<String, dynamic>.from(raw), myId);
        } else {
          continue;
        }
        next.add(_enrichConversationFromMessageCache(conv, msgsCache));
      }
      next.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      state = state.copyWith(conversations: next);
      if (state.wsConnected) {
        _subscribeAllConversationChannels();
      }
    } catch (e) {
      if (!silent) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<void> loadMessages(String conversationId) async {
    final myId = _myId;
    if (myId == null || conversationId.isEmpty) return;

    final body = await _repo.listMessages(conversationId, pageSize: 50);
    final list = body['messages'] as List<dynamic>? ?? const [];
    final parsed = <ChatMessage>[];
    for (final raw in list) {
      if (raw is Map<String, dynamic>) {
        parsed.add(_messageFromApi(raw, myId));
      } else if (raw is Map) {
        parsed.add(_messageFromApi(Map<String, dynamic>.from(raw), myId));
      }
    }
    parsed.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final map = Map<String, List<ChatMessage>>.from(state.messagesByConversationId);
    map[conversationId] = parsed;
    state = state.copyWith(messagesByConversationId: map);
  }

  Future<String> getOrCreateDirect(
    String targetUserId, {
    String? callerDisplayName,
    String? targetDisplayName,
  }) async {
    final myId = _myId;
    if (myId == null) throw StateError('Not authenticated');

    final body = await _repo.getOrCreateDirect(
      targetUserId,
      callerDisplayName: () {
        final c = callerDisplayName?.trim();
        if (c != null && c.isNotEmpty) return c;
        return _myChatDisplayName();
      }(),
      targetDisplayName: targetDisplayName,
    );
    final conv = _conversationFromApi(body, myId);
    _upsertConversation(conv);
    if (state.wsConnected) {
      _subscribeAllConversationChannels();
    }
    return conv.id;
  }

  /// When [conversationId] is null, creates direct chat with [peerUserId] first.
  Future<String> sendText({
    String? conversationId,
    String? peerUserId,
    String? peerDisplayName,
    required String text,
  }) async {
    final myId = _myId;
    if (myId == null) throw StateError('Not authenticated');

    var cid = conversationId?.trim() ?? '';
    if (cid.isEmpty) {
      final peer = peerUserId?.trim() ?? '';
      if (peer.isEmpty) {
        throw StateError('Missing peer user');
      }
      cid = await getOrCreateDirect(
        peer,
        callerDisplayName: _myChatDisplayName(),
        targetDisplayName: peerDisplayName,
      );
    }

    final sent = await _repo.sendTextMessage(
      cid,
      text.trim(),
      senderDisplayName: _myChatDisplayName(),
      peerDisplayName: peerDisplayName,
    );
    final msg = _messageFromApi(sent, myId);
    _appendMessageDedupe(msg);
    _bumpConversationFromSentMessage(msg);
    unawaited(refreshConversations(silent: true));
    return cid;
  }

  Future<void> markConversationRead(String conversationId) async {
    final myId = _myId;
    if (myId == null || conversationId.isEmpty) return;

    await _repo.markRead(conversationId);
    final next = state.conversations
        .map(
          (c) => c.id == conversationId
              ? ChatConversation(
                  id: c.id,
                  name: c.name,
                  avatar: c.avatar,
                  subtitle: c.subtitle,
                  lastMessage: c.lastMessage,
                  lastMessageTime: c.lastMessageTime,
                  unreadCount: 0,
                  isGroup: c.isGroup,
                  participantCount: c.participantCount,
                  isOnline: c.isOnline,
                  chatType: c.chatType,
                  otherUserId: c.otherUserId,
                  participantDisplayNames: c.participantDisplayNames,
                )
              : c,
        )
        .toList();
    state = state.copyWith(conversations: next);
  }

  Future<void> _connectWebSocket() async {
    await _wsSub?.cancel();
    _wsSub = null;
    final old = _channel;
    _channel = null;
    if (old != null) {
      await old.sink.close();
    }

    final token = await _ref.read(secureStorageProvider).getToken();
    if (token == null || token.isEmpty) return;

    final wsUrl = dotenv.env['CHAT_WS_URL'] ?? 'ws://localhost:8070/ws';
    final base = Uri.parse(wsUrl);
    final qp = Map<String, String>.from(base.queryParameters);
    qp['token'] = token;
    final uri = base.replace(queryParameters: qp);

    try {
      final ch = WebSocketChannel.connect(uri);
      _channel = ch;
      state = state.copyWith(wsConnected: true);

      _wsSub = ch.stream.listen(
        (dynamic event) {
          if (event is String) {
            _onWsPayload(event);
          } else if (event is List<int>) {
            _onWsPayload(utf8.decode(event));
          }
        },
        onError: (_) {
          state = state.copyWith(wsConnected: false);
        },
        onDone: () {
          state = state.copyWith(wsConnected: false);
        },
      );
    } catch (_) {
      state = state.copyWith(wsConnected: false);
    }
  }

  void _onWsPayload(String raw) {
    Map<String, dynamic>? m;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        m = decoded;
      } else if (decoded is Map) {
        m = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return;
    }
    if (m == null) return;

    final type = m['type']?.toString();
    if (type == 'new_message') {
      final inner = m['message'];
      if (inner is Map<String, dynamic>) {
        _handleInboundMessageMap(inner);
      } else if (inner is Map) {
        _handleInboundMessageMap(Map<String, dynamic>.from(inner));
      }
    }
  }

  void _handleInboundMessageMap(Map<String, dynamic> inner) {
    final myId = _myId;
    if (myId == null) return;

    final convId =
        (inner['conversationId'] ?? inner['conversation_id'])?.toString() ?? '';
    if (convId.isEmpty) return;

    final existedBefore = _hasConversation(convId);
    final msg = _messageFromApi(inner, myId);
    final open = _ref.read(openChatConversationIdProvider);
    final fromOther = msg.senderId != myId;

    if (!existedBefore) {
      final conv = ChatConversation(
        id: convId,
        name: _peerChatTitle(fromOther ? msg.senderId : null),
        lastMessage: msg.text,
        lastMessageTime: msg.timestamp,
        unreadCount: fromOther && open != convId ? 1 : 0,
        isGroup: false,
        participantCount: 2,
        isOnline: false,
        chatType: ChatType.personal,
        otherUserId: fromOther ? msg.senderId : null,
        participantDisplayNames: const {},
      );
      _upsertConversation(conv);
      unawaited(
        refreshConversations(silent: true).then((_) {
          _subscribeAllConversationChannels();
        }),
      );
    } else {
      _bumpConversationFromInbound(msg);
      if (fromOther && open != convId) {
        _incrementUnread(convId);
      }
    }

    _appendMessageDedupe(msg);
  }

  bool _hasConversation(String id) =>
      state.conversations.any((c) => c.id == id);

  void _incrementUnread(String conversationId) {
    final next = state.conversations
        .map(
          (c) => c.id == conversationId
              ? ChatConversation(
                  id: c.id,
                  name: c.name,
                  avatar: c.avatar,
                  subtitle: c.subtitle,
                  lastMessage: c.lastMessage,
                  lastMessageTime: c.lastMessageTime,
                  unreadCount: c.unreadCount + 1,
                  isGroup: c.isGroup,
                  participantCount: c.participantCount,
                  isOnline: c.isOnline,
                  chatType: c.chatType,
                  otherUserId: c.otherUserId,
                  participantDisplayNames: c.participantDisplayNames,
                )
              : c,
        )
        .toList();
    next.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    state = state.copyWith(conversations: next);
  }

  void _subscribeAllConversationChannels() {
    final ch = _channel;
    if (ch == null) return;
    final ids = state.conversations.map((c) => c.id).toList();
    if (ids.isEmpty) return;
    try {
      final frame = jsonEncode({
        'type': 'subscribe',
        'conversation_ids': ids,
      });
      ch.sink.add(frame);
    } catch (_) {}
  }

  void _appendMessageDedupe(ChatMessage msg) {
    final existing = state.messagesByConversationId[msg.conversationId] ?? [];
    if (existing.any((m) => m.id == msg.id)) return;
    final merged = [...existing, msg]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final map = Map<String, List<ChatMessage>>.from(state.messagesByConversationId);
    map[msg.conversationId] = merged;
    state = state.copyWith(messagesByConversationId: map);
  }

  void _bumpConversationFromSentMessage(ChatMessage msg) {
    final preview = msg.text;
    final next = state.conversations.map((c) {
      if (c.id != msg.conversationId) return c;
      return ChatConversation(
        id: c.id,
        name: c.name,
        avatar: c.avatar,
        subtitle: c.subtitle,
        lastMessage: preview,
        lastMessageTime: msg.timestamp,
        unreadCount: c.unreadCount,
        isGroup: c.isGroup,
        participantCount: c.participantCount,
        isOnline: c.isOnline,
        chatType: c.chatType,
        otherUserId: c.otherUserId,
        participantDisplayNames: c.participantDisplayNames,
      );
    }).toList();
    if (!_hasConversation(msg.conversationId)) {
      return;
    }
    next.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    state = state.copyWith(conversations: next);
  }

  void _bumpConversationFromInbound(ChatMessage msg) {
    final preview = msg.text;
    final idx = state.conversations.indexWhere((c) => c.id == msg.conversationId);
    if (idx < 0) return;

    final c = state.conversations[idx];
    final updated = ChatConversation(
      id: c.id,
      name: c.name,
      avatar: c.avatar,
      subtitle: c.subtitle,
      lastMessage: preview,
      lastMessageTime: msg.timestamp,
      unreadCount: c.unreadCount,
      isGroup: c.isGroup,
      participantCount: c.participantCount,
      isOnline: c.isOnline,
      chatType: c.chatType,
      otherUserId: c.otherUserId,
      participantDisplayNames: c.participantDisplayNames,
    );
    final next = [...state.conversations]..[idx] = updated;
    next.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    state = state.copyWith(conversations: next);
  }

  void _upsertConversation(ChatConversation conv) {
    final others = state.conversations.where((c) => c.id != conv.id).toList();
    final next = [conv, ...others];
    next.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    state = state.copyWith(conversations: next);
  }

  ChatConversation _conversationFromApi(Map<String, dynamic> j, String myId) {
    final id = j['id']?.toString() ?? '';
    final participants = (j['participants'] as List<dynamic>? ?? const [])
        .map(
          (e) => e is Map<String, dynamic>
              ? e
              : (e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}),
        )
        .toList();

    String? otherId;
    final names = <String, String>{};
    for (final p in participants) {
      final uid = (p['userId'] ?? p['user_id'])?.toString() ?? '';
      final dnRaw = (p['displayName'] ?? p['display_name'])?.toString().trim();
      if (uid.isNotEmpty && dnRaw != null && dnRaw.isNotEmpty) {
        names[uid] = dnRaw;
      }
    }

    String? otherDisplay;
    for (final p in participants) {
      final uid = (p['userId'] ?? p['user_id'])?.toString() ?? '';
      if (uid.isNotEmpty && uid != myId) {
        otherId = uid;
        otherDisplay = names[uid];
        break;
      }
    }

    final title = (j['title'] as String?)?.trim();
    final name = (title != null && title.isNotEmpty)
        ? title
        : (otherDisplay ?? _peerChatTitle(otherId));

    final lastMsg = j['lastMessage'] ?? j['last_message'];
    var lastText = '';
    var lastTime = _parseTimestamp(j['lastMessageAt'] ?? j['last_message_at']) ??
        _parseTimestamp(j['createdAt'] ?? j['created_at']) ??
        DateTime.now();

    if (lastMsg is Map) {
      final lm = Map<String, dynamic>.from(lastMsg);
      final c = lm['content']?.toString();
      if (c != null && c.isNotEmpty) lastText = c;
      lastTime = _parseTimestamp(lm['createdAt'] ?? lm['created_at']) ?? lastTime;
    }

    final unreadRaw = j['unreadCount'] ?? j['unread_count'];
    final unread = unreadRaw is int ? unreadRaw : int.tryParse('$unreadRaw') ?? 0;
    final typeStr = j['type']?.toString() ?? '';
    final isGroup = typeStr.contains('GROUP');

    return ChatConversation(
      id: id,
      name: name,
      subtitle: null,
      lastMessage: lastText,
      lastMessageTime: lastTime,
      unreadCount: unread,
      isGroup: isGroup,
      participantCount: participants.isEmpty ? 2 : participants.length,
      isOnline: false,
      chatType: ChatType.personal,
      otherUserId: otherId,
      participantDisplayNames: names,
    );
  }

  ChatMessage _messageFromApi(Map<String, dynamic> m, String myId) {
    final id = m['id']?.toString() ?? '';
    final convId =
        (m['conversationId'] ?? m['conversation_id'])?.toString() ?? '';
    final senderId = (m['senderId'] ?? m['sender_id'])?.toString() ?? '';
    final content = m['content']?.toString() ?? '';
    final ts = _parseTimestamp(m['createdAt'] ?? m['created_at']) ?? DateTime.now();
    final isMe = senderId == myId;
    final senderName = _senderDisplayName(convId, senderId, myId);
    return ChatMessage(
      id: id,
      conversationId: convId,
      senderId: senderId,
      senderName: senderName,
      text: content,
      timestamp: ts,
      isMe: isMe,
    );
  }

  String _senderDisplayName(String conversationId, String senderId, String myId) {
    if (senderId == myId) return 'You';
    if (conversationId.isEmpty) {
      return _peerChatTitle(senderId);
    }
    for (final c in state.conversations) {
      if (c.id != conversationId) continue;
      final dn = c.participantDisplayNames[senderId];
      if (dn != null && dn.isNotEmpty) return dn;
      break;
    }
    return _peerChatTitle(senderId);
  }

  DateTime? _parseTimestamp(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    if (v is Map && v['seconds'] != null) {
      final sec = (v['seconds'] as num?)?.toInt();
      if (sec == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(sec * 1000, isUtc: true);
    }
    return null;
  }

  /// Backend has no display names for DMs yet; use a short peer id label.
  String _peerChatTitle(String? otherUserId) {
    if (otherUserId == null || otherUserId.isEmpty) return 'Chat';
    final t = otherUserId.trim();
    if (t.length <= 13) return t;
    return '${t.substring(0, 8)}…';
  }

  /// When REST omits last text, reuse newest message we already have in memory.
  ChatConversation _enrichConversationFromMessageCache(
    ChatConversation c,
    Map<String, List<ChatMessage>> cache,
  ) {
    if (c.lastMessage.trim().isNotEmpty) return c;
    final list = cache[c.id];
    if (list == null || list.isEmpty) return c;
    final last = list.last;
    if (last.text.trim().isEmpty) return c;
    return ChatConversation(
      id: c.id,
      name: c.name,
      avatar: c.avatar,
      subtitle: c.subtitle,
      lastMessage: last.text,
      lastMessageTime: last.timestamp,
      unreadCount: c.unreadCount,
      isGroup: c.isGroup,
      participantCount: c.participantCount,
      isOnline: c.isOnline,
      chatType: c.chatType,
      otherUserId: c.otherUserId,
      participantDisplayNames: c.participantDisplayNames,
    );
  }
}

final conversationsListProvider = Provider<List<ChatConversation>>((ref) {
  return ref.watch(chatControllerProvider).conversations;
});

final chatMessagesForProvider =
    Provider.family<List<ChatMessage>, String>((ref, conversationId) {
  return ref
          .watch(chatControllerProvider)
          .messagesByConversationId[conversationId] ??
      const [];
});

final totalUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(chatControllerProvider).conversations.fold<int>(
        0,
        (sum, c) => sum + c.unreadCount,
      );
});
