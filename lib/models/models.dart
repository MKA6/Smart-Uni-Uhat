// ─── User Model ───────────────────────────────────────────────────────────────
class User {
  final String id;
  final String name;
  final String email;
  final String universityId;
  final String department;
  final String avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.universityId,
    required this.department,
    this.avatarUrl = '',
    this.isOnline = false,
    this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        universityId: json['universityId'] ?? '',
        department: json['department'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        isOnline: json['isOnline'] ?? false,
        lastSeen: json['lastSeen'] != null
            ? DateTime.parse(json['lastSeen'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'universityId': universityId,
        'department': department,
        'avatarUrl': avatarUrl,
        'isOnline': isOnline,
        'lastSeen': lastSeen?.toIso8601String(),
      };

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

// ─── Message Model ────────────────────────────────────────────────────────────
enum MessageType { text, image, file, aiReply, summary }
enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? fileUrl;
  final String? fileName;
  final bool isAiMessage;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.fileUrl,
    this.fileName,
    this.isAiMessage = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json['id'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        content: json['content'] ?? '',
        type: MessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MessageType.text,
        ),
        status: MessageStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => MessageStatus.sent,
        ),
        timestamp: DateTime.parse(json['timestamp']),
        fileUrl: json['fileUrl'],
        fileName: json['fileName'],
        isAiMessage: json['isAiMessage'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'type': type.name,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        'fileUrl': fileUrl,
        'fileName': fileName,
        'isAiMessage': isAiMessage,
      };
}

// ─── Group/Course Model ───────────────────────────────────────────────────────
class CourseGroup {
  final String id;
  final String courseName;
  final String courseCode;
  final String description;
  final String adminId;
  final List<String> memberIds;
  final DateTime createdAt;
  final Message? lastMessage;
  final int unreadCount;
  final String emoji;

  CourseGroup({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.description,
    required this.adminId,
    required this.memberIds,
    required this.createdAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.emoji = '📚',
  });

  factory CourseGroup.fromJson(Map<String, dynamic> json) => CourseGroup(
        id: json['id'] ?? '',
        courseName: json['courseName'] ?? '',
        courseCode: json['courseCode'] ?? '',
        description: json['description'] ?? '',
        adminId: json['adminId'] ?? '',
        memberIds: List<String>.from(json['memberIds'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
        lastMessage: json['lastMessage'] != null
            ? Message.fromJson(json['lastMessage'])
            : null,
        unreadCount: json['unreadCount'] ?? 0,
        emoji: json['emoji'] ?? '📚',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseName': courseName,
        'courseCode': courseCode,
        'description': description,
        'adminId': adminId,
        'memberIds': memberIds,
        'createdAt': createdAt.toIso8601String(),
        'lastMessage': lastMessage?.toJson(),
        'unreadCount': unreadCount,
        'emoji': emoji,
      };
}

// ─── Direct Chat Model ────────────────────────────────────────────────────────
class DirectChat {
  final String id;
  final User otherUser;
  final Message? lastMessage;
  final int unreadCount;

  DirectChat({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });
}
