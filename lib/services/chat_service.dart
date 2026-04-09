import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class ChatService extends ChangeNotifier {
  final List<CourseGroup> _groups = [];
  final List<DirectChat> _directChats = [];
  final Map<String, List<Message>> _messages = {};
  bool _isConnected = false;
  StreamController<Message>? _messageStream;
  Timer? _simulationTimer;

  List<CourseGroup> get groups => List.unmodifiable(_groups);
  List<DirectChat> get directChats => List.unmodifiable(_directChats);
  bool get isConnected => _isConnected;

  ChatService() {
    _initMockData();
    _simulateConnection();
  }

  void _initMockData() {
    // Mock Course Groups
    final now = DateTime.now();
    _groups.addAll([
      CourseGroup(
        id: 'g1',
        courseName: 'هندسة البرمجيات',
        courseCode: 'CS401',
        description: 'مناقشة مادة هندسة البرمجيات - د. أحمد علي',
        adminId: 'user_1',
        memberIds: ['user_1', 'user_2', 'user_3', 'user_4'],
        createdAt: now.subtract(const Duration(days: 30)),
        unreadCount: 3,
        emoji: '💻',
        lastMessage: Message(
          id: 'm_last1',
          senderId: 'user_2',
          senderName: 'سارة محمود',
          content: 'هل راجعتم ملاحظات المحاضرة الأخيرة؟',
          timestamp: now.subtract(const Duration(minutes: 15)),
        ),
      ),
      CourseGroup(
        id: 'g2',
        courseName: 'قواعد البيانات المتقدمة',
        courseCode: 'CS402',
        description: 'مساق قواعد البيانات - الفصل الثاني',
        adminId: 'user_1',
        memberIds: ['user_1', 'user_2', 'user_5'],
        createdAt: now.subtract(const Duration(days: 20)),
        unreadCount: 0,
        emoji: '🗄️',
        lastMessage: Message(
          id: 'm_last2',
          senderId: 'user_5',
          senderName: 'أحمد خالد',
          content: 'الواجب يجب تسليمه الخميس القادم',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
      ),
      CourseGroup(
        id: 'g3',
        courseName: 'الذكاء الاصطناعي',
        courseCode: 'CS403',
        description: 'نقاشات مادة الذكاء الاصطناعي والتعلم الآلي',
        adminId: 'user_3',
        memberIds: ['user_1', 'user_3', 'user_6', 'user_7'],
        createdAt: now.subtract(const Duration(days: 10)),
        unreadCount: 7,
        emoji: '🧠',
        lastMessage: Message(
          id: 'm_last3',
          senderId: 'user_3',
          senderName: 'ليلى حسن',
          content: '🤖 المساعد الذكي: Neural networks use layers...',
          timestamp: now.subtract(const Duration(minutes: 5)),
          isAiMessage: true,
        ),
      ),
      CourseGroup(
        id: 'g4',
        courseName: 'أمن المعلومات',
        courseCode: 'CS404',
        description: 'مادة أمن المعلومات والشبكات',
        adminId: 'user_2',
        memberIds: ['user_1', 'user_2', 'user_8'],
        createdAt: now.subtract(const Duration(days: 5)),
        unreadCount: 1,
        emoji: '🔐',
        lastMessage: Message(
          id: 'm_last4',
          senderId: 'user_8',
          senderName: 'عمر يوسف',
          content: 'شاركت ملف شرح التشفير',
          timestamp: now.subtract(const Duration(hours: 5)),
          type: MessageType.file,
        ),
      ),
    ]);

    // Mock Direct Chats
    _directChats.addAll([
      DirectChat(
        id: 'dc1',
        otherUser: User(
          id: 'user_2',
          name: 'سارة محمود',
          email: 'sarah@ucst.edu.ps',
          universityId: '120207183',
          department: 'تكنولوجيا المعلومات',
          isOnline: true,
        ),
        lastMessage: Message(
          id: 'dm_last1',
          senderId: 'user_2',
          senderName: 'سارة محمود',
          content: 'هل أرسلت الواجب؟',
          timestamp: now.subtract(const Duration(minutes: 30)),
        ),
        unreadCount: 1,
      ),
      DirectChat(
        id: 'dc2',
        otherUser: User(
          id: 'user_3',
          name: 'ليلى حسن',
          email: 'layla@ucst.edu.ps',
          universityId: '120207190',
          department: 'تكنولوجيا المعلومات',
          isOnline: false,
          lastSeen: now.subtract(const Duration(hours: 1)),
        ),
        lastMessage: Message(
          id: 'dm_last2',
          senderId: 'user_1',
          senderName: 'أنت',
          content: 'شكراً على الملاحظات',
          timestamp: now.subtract(const Duration(hours: 3)),
        ),
        unreadCount: 0,
      ),
    ]);

    // Mock messages for groups
    _messages['g1'] = _generateMockMessages('g1');
    _messages['g2'] = _generateMockMessages('g2');
    _messages['g3'] = _generateMockMessages('g3');
    _messages['dc1'] = _generateMockDirectMessages();
  }

  List<Message> _generateMockMessages(String groupId) {
    final now = DateTime.now();
    final uuid = const Uuid();
    final senders = [
      {'id': 'user_2', 'name': 'سارة محمود'},
      {'id': 'user_3', 'name': 'ليلى حسن'},
      {'id': 'user_4', 'name': 'محمد علي'},
    ];

    final contents =
        groupId == 'g1'
            ? [
              'مرحباً بالجميع! متى موعد تسليم المشروع؟',
              'الأسبوع القادم يوم الأحد',
              'هل راجعتم ملاحظات المحاضرة الأخيرة؟',
              'نعم، كانت مثيرة جداً حول نماذج Agile',
              'هل يمكن أحد يشرح لي الفرق بين Scrum وKanban؟',
              '🤖 المساعد الذكي: Scrum يعتمد على sprints محددة زمنياً، بينما Kanban هو نظام مستمر يركز على تقليل العمل الجاري. Scrum مناسب للفرق التي تحتاج بنية واضحة، وKanban أكثر مرونة.',
              'شكراً! هذا واضح جداً',
              'من يريد جلسة مذاكرة جماعية غداً؟',
            ]
            : [
              'صباح الخير جميعاً',
              'هل اطلعتم على الواجب الجديد؟',
              'نعم، يبدو صعباً بعض الشيء',
              'يمكننا المساعدة بعضنا البعض',
              'من لديه وقت فراغ الغد؟',
            ];

    return List.generate(contents.length, (i) {
      final isAi = contents[i].startsWith('🤖');
      final sender =
          isAi
              ? {'id': 'ai', 'name': 'المساعد الذكي'}
              : senders[i % senders.length];
      return Message(
        id: uuid.v4(),
        senderId: sender['id']!,
        senderName: sender['name']!,
        content: contents[i],
        timestamp: now.subtract(Duration(hours: contents.length - i)),
        isAiMessage: isAi,
        status: MessageStatus.read,
      );
    });
  }

  List<Message> _generateMockDirectMessages() {
    final now = DateTime.now();
    final uuid = const Uuid();
    return [
      Message(
        id: uuid.v4(),
        senderId: 'user_2',
        senderName: 'سارة محمود',
        content: 'مرحباً! كيف حالك؟',
        timestamp: now.subtract(const Duration(hours: 4)),
        status: MessageStatus.read,
      ),
      Message(
        id: uuid.v4(),
        senderId: 'user_current',
        senderName: 'أنا',
        content: 'بخير، شكراً! وأنت؟',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 55)),
        status: MessageStatus.read,
      ),
      Message(
        id: uuid.v4(),
        senderId: 'user_2',
        senderName: 'سارة محمود',
        content: 'هل أرسلت الواجب؟',
        timestamp: now.subtract(const Duration(minutes: 30)),
        status: MessageStatus.delivered,
      ),
    ];
  }

  void _simulateConnection() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _isConnected = true;
      notifyListeners();
    });
  }

  List<Message> getMessages(String chatId) {
    return _messages[chatId] ?? [];
  }

  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
  }) async {
    final message = Message(
      id: const Uuid().v4(),
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      fileUrl: fileUrl,
      fileName: fileName,
    );

    _messages[chatId] = [...(_messages[chatId] ?? []), message];
    notifyListeners();

    // Simulate delivery
    await Future.delayed(const Duration(milliseconds: 800));
    final updatedMessages = List<Message>.from(_messages[chatId] ?? []);
    final idx = updatedMessages.indexWhere((m) => m.id == message.id);
    if (idx != -1) {
      updatedMessages[idx] = Message(
        id: message.id,
        senderId: message.senderId,
        senderName: message.senderName,
        content: message.content,
        type: message.type,
        status: MessageStatus.delivered,
        timestamp: message.timestamp,
        fileUrl: message.fileUrl,
        fileName: message.fileName,
      );
      _messages[chatId] = updatedMessages;
      notifyListeners();
    }

    return message;
  }

  Future<Message> sendAiMessage({
    required String chatId,
    required String content,
  }) async {
    final aiMessage = Message(
      id: const Uuid().v4(),
      senderId: 'ai_assistant',
      senderName: 'المساعد الذكي 🤖',
      content: content,
      status: MessageStatus.delivered,
      timestamp: DateTime.now(),
      isAiMessage: true,
    );

    _messages[chatId] = [...(_messages[chatId] ?? []), aiMessage];
    notifyListeners();
    return aiMessage;
  }

  Future<CourseGroup> createGroup({
    required String courseName,
    required String courseCode,
    required String description,
    required String adminId,
    required String emoji,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final group = CourseGroup(
      id: const Uuid().v4(),
      courseName: courseName,
      courseCode: courseCode,
      description: description,
      adminId: adminId,
      memberIds: [adminId],
      createdAt: DateTime.now(),
      emoji: emoji,
    );
    _groups.insert(0, group);
    notifyListeners();
    return group;
  }

  void markAsRead(String chatId) {
    final groupIdx = _groups.indexWhere((g) => g.id == chatId);
    if (groupIdx != -1) {
      final g = _groups[groupIdx];
      _groups[groupIdx] = CourseGroup(
        id: g.id,
        courseName: g.courseName,
        courseCode: g.courseCode,
        description: g.description,
        adminId: g.adminId,
        memberIds: g.memberIds,
        createdAt: g.createdAt,
        lastMessage: g.lastMessage,
        unreadCount: 0,
        emoji: g.emoji,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageStream?.close();
    _simulationTimer?.cancel();
    super.dispose();
  }
}
