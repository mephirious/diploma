/// Chat type for in-app context: venue support, session groups, or personal.
enum ChatType { venue, session, personal }

class ChatConversation {
  final String id;
  final String name;
  final String? avatar;
  final String? subtitle;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isGroup;
  final int participantCount;
  final bool isOnline;
  final ChatType chatType;
  /// Other user in a direct chat (UUID), when known.
  final String? otherUserId;

  /// Conversation-scoped display names from API (`userId` -> label).
  final Map<String, String> participantDisplayNames;

  ChatConversation({
    required this.id,
    required this.name,
    this.avatar,
    this.subtitle,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isGroup = false,
    this.participantCount = 2,
    this.isOnline = false,
    this.chatType = ChatType.personal,
    this.otherUserId,
    this.participantDisplayNames = const {},
  });
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderRole;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderRole,
    required this.text,
    required this.timestamp,
    this.isMe = false,
  });
}

class ChatUserSearchResult {
  final String id;
  final String username;
  final String firstName;
  final String lastName;

  const ChatUserSearchResult({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  String get displayName {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) return '$first $last';
    if (first.isNotEmpty) return first;
    if (last.isNotEmpty) return last;
    return username;
  }

  factory ChatUserSearchResult.fromJson(Map<String, dynamic> json) {
    return ChatUserSearchResult(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      firstName: (json['first_name'] ?? json['firstName'] ?? '').toString(),
      lastName: (json['last_name'] ?? json['lastName'] ?? '').toString(),
    );
  }
}
