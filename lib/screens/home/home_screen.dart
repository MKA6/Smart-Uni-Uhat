import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import '../tabs/groups_tab.dart';
import '../tabs/direct_chats_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/ai_assistant_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    GroupsTab(),
    DirectChatsTab(),
    AiAssistantTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatService = context.watch<ChatService>();

    // Calculate total unread
    final totalGroupUnread = chatService.groups.fold<int>(
      0,
      (sum, g) => sum + g.unreadCount,
    );
    final totalDmUnread = chatService.directChats.fold<int>(
      0,
      (sum, d) => sum + d.unreadCount,
    );

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  index: 0,
                  selected: _selectedIndex == 0,
                  icon: Icons.groups_outlined,
                  activeIcon: Icons.groups,
                  label: 'المجموعات',
                  badge: totalGroupUnread,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavItem(
                  index: 1,
                  selected: _selectedIndex == 1,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'الرسائل',
                  badge: totalDmUnread,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _NavItem(
                  index: 2,
                  selected: _selectedIndex == 2,
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                  label: 'المساعد الذكي',
                  badge: 0,
                  onTap: () => setState(() => _selectedIndex = 2),
                  isAi: true,
                ),
                _NavItem(
                  index: 3,
                  selected: _selectedIndex == 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'الملف الشخصي',
                  badge: 0,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  final VoidCallback onTap;
  final bool isAi;

  const _NavItem({
    required this.index,
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.badge,
    required this.onTap,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        selected
            ? (isAi ? AppTheme.aiPurple : AppTheme.primaryBlue)
            : AppTheme.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected
                  ? (isAi ? AppTheme.aiPurple : AppTheme.primaryBlue)
                      .withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? activeIcon : icon, color: color, size: 24),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
