import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/ai_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/message_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final CourseGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAiTyping = false;
  bool _showAiBadge = true;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();

    final user = context.read<AuthService>().currentUser!;
    final chatService = context.read<ChatService>();

    await chatService.sendMessage(
      chatId: widget.group.id,
      senderId: user.id,
      senderName: user.name,
      content: text,
    );
    _scrollToBottom();

    // AI auto-reply if message contains a question
    if (text.contains('?') ||
        text.contains('؟') ||
        text.contains('شرح') ||
        text.contains('explain') ||
        text.contains('مساعدة') ||
        text.contains('كيف')) {
      await _getAiReply(text);
    }
  }

  Future<void> _getAiReply(String userMessage) async {
    setState(() => _isAiTyping = true);
    _scrollToBottom();

    final aiService = context.read<AiService>();
    final chatService = context.read<ChatService>();

    final reply = await aiService.generateAcademicReply(
      userMessage,
      courseContext: widget.group.courseName,
    );

    if (mounted) {
      setState(() => _isAiTyping = false);
      await chatService.sendAiMessage(chatId: widget.group.id, content: reply);
      _scrollToBottom();
    }
  }

  Future<void> _summarizeChat() async {
    final messages = context.read<ChatService>().getMessages(widget.group.id);
    if (messages.isEmpty) return;

    final textMessages =
        messages
            .where((m) => m.type == MessageType.text)
            .map((m) => '${m.senderName}: ${m.content}')
            .toList();

    setState(() => _isAiTyping = true);
    final aiService = context.read<AiService>();
    final summary = await aiService.summarizeConversation(textMessages);

    if (mounted) {
      setState(() => _isAiTyping = false);
      await context.read<ChatService>().sendAiMessage(
        chatId: widget.group.id,
        content: '📝 **ملخص المحادثة:**\n$summary',
      );
      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إنشاء الملخص بنجاح ✅'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messages = context.watch<ChatService>().getMessages(widget.group.id);
    final currentUser = context.read<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  widget.group.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.courseName,
                    style: theme.textTheme.labelLarge?.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.group.memberIds.length} عضو • ${widget.group.courseCode}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            tooltip: 'تلخيص المحادثة',
            onPressed: _summarizeChat,
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // AI Badge
          if (_showAiBadge)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.aiPurple.withOpacity(0.15),
                    AppTheme.primaryBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.aiPurple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'المساعد الذكي يراقب المحادثة ويرد على أسئلتك تلقائياً',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showAiBadge = false),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isAiTyping && i == messages.length) {
                  return _AiTypingBubble();
                }
                final msg = messages[i];
                final isMe = msg.senderId == currentUser.id;
                return MessageBubble(message: msg, isMe: isMe);
              },
            ),
          ),

          // Input Area
          _ChatInputBar(
            controller: _inputController,
            onSend: _sendMessage,
            onAiTap:
                () => _getAiReply(
                  _inputController.text.isNotEmpty
                      ? _inputController.text
                      : 'مرحبا، أحتاج مساعدة في ${widget.group.courseName}',
                ),
          ),
        ],
      ),
    );
  }
}

class _AiTypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.aiPurple, Color(0xFF6D28D9)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.aiPurple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppTheme.aiPurple.withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المساعد الذكي يكتب',
                  style: TextStyle(fontSize: 12, color: AppTheme.aiPurple),
                ),
                SizedBox(width: 8),
                SizedBox(width: 20, height: 10, child: _ThreeDots()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeDots extends StatelessWidget {
  const _ThreeDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppTheme.aiPurple,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppTheme.aiPurple,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppTheme.aiPurple,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAiTap;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.onAiTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: AppTheme.textSecondary,
            ),
            onPressed: () {},
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                filled: true,
                fillColor: isDark ? AppTheme.cardDark : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // AI Button
          GestureDetector(
            onTap: onAiTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.aiPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Send Button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF3B82F6)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
