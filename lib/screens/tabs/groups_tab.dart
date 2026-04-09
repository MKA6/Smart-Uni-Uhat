import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import '../chat/group_chat_screen.dart';
import '../chat/create_group_screen.dart';

class GroupsTab extends StatelessWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final groups = context.watch<ChatService>().groups;
    final user = context.read<AuthService>().currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('مجموعات المواد'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryBlue, Color(0xFF1E40AF)],
                  ),
                ),
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          // Stats Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.1),
                    AppTheme.accentGold.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  _StatChip(
                    label: 'مجموعاتي',
                    value: '${groups.length}',
                    icon: '📚',
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    label: 'غير مقروء',
                    value: '${groups.fold(0, (s, g) => s + g.unreadCount)}',
                    icon: '🔔',
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CreateGroupScreen()),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('مجموعة جديدة'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Groups List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final group = groups[i];
                return _GroupCard(group: group);
              },
              childCount: groups.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$icon $value',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final CourseGroup group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasUnread = group.unreadCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          context.read<ChatService>().markAsRead(group.id);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => GroupChatScreen(group: group)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasUnread
                  ? AppTheme.primaryBlue.withOpacity(0.3)
                  : AppTheme.dividerColor,
              width: hasUnread ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Emoji Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(group.emoji,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.courseName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: hasUnread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (group.lastMessage != null)
                          Text(
                            timeago.format(group.lastMessage!.timestamp,
                                locale: 'ar'),
                            style: TextStyle(
                              fontSize: 11,
                              color: hasUnread
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textSecondary,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            group.courseCode,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${group.memberIds.length} عضو',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    if (group.lastMessage != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (group.lastMessage!.isAiMessage)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child:
                                  Text('🤖', style: TextStyle(fontSize: 11)),
                            ),
                          Expanded(
                            child: Text(
                              group.lastMessage!.content,
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
                                '${group.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
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
