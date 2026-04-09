import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/models.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import '../chat/direct_chat_screen.dart';

class DirectChatsTab extends StatelessWidget {
  const DirectChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chats = context.watch<ChatService>().directChats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرسائل المباشرة'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.person_add_outlined), onPressed: () {}),
        ],
      ),
      body: chats.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              itemBuilder: (_, i) => _DirectChatCard(chat: chats[i]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💬', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('لا توجد محادثات بعد',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('ابدأ محادثة مع زملائك',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DirectChatCard extends StatelessWidget {
  final DirectChat chat;
  const _DirectChatCard({required this.chat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasUnread = chat.unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DirectChatScreen(chat: chat)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                    child: Text(
                      chat.otherUser.initials,
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (chat.otherUser.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppTheme.cardDark
                                : AppTheme.surfaceLight,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.otherUser.name,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight:
                                  hasUnread ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (chat.lastMessage != null)
                          Text(
                            timeago.format(chat.lastMessage!.timestamp,
                                locale: 'ar'),
                            style: TextStyle(
                              fontSize: 11,
                              color: hasUnread
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chat.otherUser.isOnline
                          ? 'متصل الآن'
                          : 'آخر ظهور منذ قليل',
                      style: TextStyle(
                        fontSize: 11,
                        color: chat.otherUser.isOnline
                            ? AppTheme.successGreen
                            : AppTheme.textSecondary,
                      ),
                    ),
                    if (chat.lastMessage != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage!.content,
                              style: TextStyle(
                                fontSize: 12,
                                color: hasUnread
                                    ? theme.textTheme.bodyLarge?.color
                                    : AppTheme.textSecondary,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${chat.unreadCount}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
