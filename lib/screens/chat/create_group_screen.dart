import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import '../chat/group_chat_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedEmoji = '📚';
  bool _isLoading = false;

  final List<String> _emojis = [
    '📚', '💻', '🧠', '🔐', '🗄️', '📊', '⚙️',
    '🌐', '📡', '🔬', '🎯', '🏗️', '🤖', '📱', '🖥️',
  ];

  final List<String> _departments = [
    'تكنولوجيا المعلومات',
    'هندسة الحاسوب',
    'نظم المعلومات',
    'الذكاء الاصطناعي',
    'هندسة الشبكات',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = context.read<AuthService>().currentUser!;
    final group = await context.read<ChatService>().createGroup(
          courseName: _nameController.text.trim(),
          courseCode: _codeController.text.trim().toUpperCase(),
          description: _descController.text.trim(),
          adminId: user.id,
          emoji: _selectedEmoji,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => GroupChatScreen(group: group)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء مجموعة جديدة'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'إنشاء',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji Picker
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showEmojiPicker,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(_selectedEmoji,
                              style: const TextStyle(fontSize: 38)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('اضغط لتغيير الأيقونة',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Course Name
              _buildLabel('اسم المادة / الكورس'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'مثال: هندسة البرمجيات',
                  prefixIcon:
                      Icon(Icons.school_outlined, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال اسم المادة' : null,
              ),

              const SizedBox(height: 16),

              // Course Code
              _buildLabel('رمز المادة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  hintText: 'مثال: CS401',
                  prefixIcon:
                      Icon(Icons.tag_rounded, size: 20),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'يرجى إدخال رمز المادة' : null,
              ),

              const SizedBox(height: 16),

              // Description
              _buildLabel('وصف المجموعة (اختياري)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'أضف وصفاً للمجموعة...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              // Tips
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.accentGold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text('نصائح للمجموعة',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...[
                      'المساعد الذكي سيرد تلقائياً على أسئلة الطلاب',
                      'يمكنك تلخيص المحادثة بضغطة زر واحدة',
                      'شارك الملفات والمواد الدراسية بسهولة',
                    ].map((tip) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(tip,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _createGroup,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Icon(Icons.add_rounded),
                label: const Text('إنشاء المجموعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر أيقونة للمجموعة',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _emojis
                  .map((e) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedEmoji = e);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: e == _selectedEmoji
                                ? AppTheme.primaryBlue.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: e == _selectedEmoji
                                ? Border.all(
                                    color: AppTheme.primaryBlue,
                                    width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(e,
                                style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}
