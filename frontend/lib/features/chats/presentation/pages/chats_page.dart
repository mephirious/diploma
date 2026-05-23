import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_title_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/chat_model.dart';
import '../providers/chats_provider.dart';
import 'chat_detail_page.dart';
import '../../../../core/widgets/auth_required_screen.dart';

class ChatsPage extends ConsumerWidget {
  const ChatsPage({super.key});

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final local = time.toLocal();
    return '${local.day}/${local.month}';
  }

  IconData _iconForChatType(ChatType type) {
    switch (type) {
      case ChatType.venue:
        return Icons.storefront_outlined;
      case ChatType.session:
        return Icons.groups_outlined;
      case ChatType.personal:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) {
      return AuthRequiredScreen(
        title: l10n.chats,
        description: 'Login or register to view your chats.',
      );
    }

    final convos = ref.watch(conversationsListProvider);
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleHeader(title: l10n.chats),
            if (chatState.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  chatState.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            Expanded(
              child: chatState.isBootstrapping && convos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : convos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noChats,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  l10n.startChatting,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.grey[500]
                                            : Colors.grey[600],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(chatControllerProvider.notifier)
                              .refreshConversations(),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                            itemCount: convos.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              indent: 76,
                              endIndent: 20,
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.grey[100],
                            ),
                            itemBuilder: (context, i) {
                              final c = convos[i];
                              return ListTile(
                                onTap: () {
                                  ref
                                      .read(chatControllerProvider.notifier)
                                      .markConversationRead(c.id);
                                  Navigator.push<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailPage(
                                        conversationId: c.id,
                                        peerUserId: c.otherUserId,
                                        conversationTitle: c.name,
                                      ),
                                    ),
                                  );
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: c.chatType == ChatType.venue
                                      ? AppColors.colorSecondary.withOpacity(0.2)
                                      : (c.isGroup
                                          ? AppColors.colorMain.withOpacity(0.15)
                                          : Colors.primaries[i %
                                                  Colors.primaries.length]
                                              .withOpacity(0.15)),
                                  child: Icon(
                                    _iconForChatType(c.chatType),
                                    color: c.chatType == ChatType.venue
                                        ? AppColors.colorSecondary
                                        : (c.isGroup
                                            ? AppColors.colorMain
                                            : Colors.primaries[i %
                                                Colors.primaries.length]),
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  c.name,
                                  style: TextStyle(
                                    fontWeight: c.unreadCount > 0
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    c.lastMessage.isEmpty ? ' ' : c.lastMessage,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: c.unreadCount > 0
                                          ? (isDark
                                              ? Colors.white70
                                              : Colors.grey[800])
                                          : Colors.grey[500],
                                      fontWeight: c.unreadCount > 0
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(c.lastMessageTime),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: c.unreadCount > 0
                                            ? AppColors.colorMain
                                            : (isDark
                                                ? Colors.grey[600]
                                                : Colors.grey[400]),
                                      ),
                                    ),
                                    if (c.unreadCount > 0) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.colorMain,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          c.unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
