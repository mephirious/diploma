import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/chats_provider.dart';
import '../../data/models/chat_model.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  /// Existing thread (null when starting from venue before first send).
  final String? conversationId;

  /// Other user id when [conversationId] is null (e.g. venue owner).
  final String? peerUserId;

  final String conversationTitle;

  /// Shown to the chat service as the peer label on first message (e.g. venue name).
  final String? peerDisplayName;

  const ChatDetailPage({
    super.key,
    this.conversationId,
    this.peerUserId,
    required this.conversationTitle,
    this.peerDisplayName,
  });

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _resolvedConversationId;
  bool _sending = false;

  /// [ref] is invalid in [dispose]; use the root container for cleanup.
  ProviderContainer? _container;

  /// Last conversation id we associate with [openChatConversationIdProvider].
  String? _openIdWeRegistered;

  bool _disposed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container ??= ProviderScope.containerOf(context);
  }

  /// Riverpod forbids updating providers during build / dispose; defer to next event.
  void _scheduleOpenChatProvider(String id) {
    _openIdWeRegistered = id;
    final container = _container;
    if (container == null) return;
    Future<void>(() {
      if (_disposed) return;
      container.read(openChatConversationIdProvider.notifier).state = id;
    });
  }

  void _scheduleClearOpenChatProviderIfOurs() {
    final container = _container;
    final ours = _openIdWeRegistered;
    if (container == null || ours == null) return;
    Future<void>(() {
      try {
        if (container.read(openChatConversationIdProvider) == ours) {
          container.read(openChatConversationIdProvider.notifier).state = null;
        }
      } catch (_) {}
    });
  }

  @override
  void initState() {
    super.initState();
    _resolvedConversationId = widget.conversationId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(Duration.zero);
      if (!mounted || _disposed) return;
      final container = _container;
      if (container == null) return;
      final id = _resolvedConversationId;
      if (id == null || id.isEmpty) return;
      _scheduleOpenChatProvider(id);
      try {
        await container.read(chatControllerProvider.notifier).loadMessages(id);
      } catch (_) {}
      if (!mounted || _disposed) return;
      try {
        await container
            .read(chatControllerProvider.notifier)
            .markConversationRead(id);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _scheduleClearOpenChatProviderIfOurs();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeId = _resolvedConversationId ?? '';
    final messages = activeId.isEmpty
        ? const <ChatMessage>[]
        : ref.watch(chatMessagesForProvider(activeId));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.colorMain.withOpacity(0.15),
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.colorMain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.conversationTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      l10n.chatEmptyThread,
                      style: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, i) =>
                        _MessageBubble(message: messages[i], isGroup: false),
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              8,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: !_sending,
                      decoration: InputDecoration(
                        hintText: l10n.typeMessage,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 14,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _send(l10n),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.colorMain,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sending ? null : () => _send(l10n),
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(AppLocalizations l10n) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final peer = widget.peerUserId;
    if ((_resolvedConversationId == null || _resolvedConversationId!.isEmpty) &&
        (peer == null || peer.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noChats)),
      );
      return;
    }

    setState(() => _sending = true);
    final container = _container;
    if (container == null) {
      if (mounted) setState(() => _sending = false);
      return;
    }

    try {
      final newId = await container.read(chatControllerProvider.notifier).sendText(
            conversationId: _resolvedConversationId,
            peerUserId: peer,
            peerDisplayName: widget.peerDisplayName,
            text: text,
          );
      if (!mounted) return;
      setState(() {
        _resolvedConversationId = newId;
        _sending = false;
      });
      _scheduleOpenChatProvider(newId);
      await container.read(chatControllerProvider.notifier).loadMessages(newId);
      if (!mounted) return;
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isGroup;

  const _MessageBubble({required this.message, required this.isGroup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMe = message.isMe;
    final localTime = message.timestamp.toLocal();
    final timeLabel =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.colorMain
                    : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey[100]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe && isGroup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : null,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : (isDark ? Colors.grey[500] : Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
