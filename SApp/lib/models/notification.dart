enum NotificationCategory {
  all,
  urgent,
  system,
  task,
  news,
}

class AppNotification {
  final String id;
  final String title;
  final String content;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final String senderName;
  final String? senderAvatar;
  final String? actionLabel;

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    required this.senderName,
    this.senderAvatar,
    this.actionLabel,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? content,
    NotificationCategory? category,
    DateTime? timestamp,
    bool? isRead,
    String? senderName,
    String? senderAvatar,
    String? actionLabel,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    NotificationCategory cat;
    switch (json['category'] as String?) {
      case 'urgent':
      case 'khanCap':
        cat = NotificationCategory.urgent;
        break;
      case 'system':
      case 'heThong':
        cat = NotificationCategory.system;
        break;
      case 'task':
      case 'congViec':
        cat = NotificationCategory.task;
        break;
      case 'news':
      case 'tinTuc':
      default:
        cat = NotificationCategory.news;
        break;
    }

    return AppNotification(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: cat,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'] ?? 'System',
      senderAvatar: json['sender_avatar'],
      actionLabel: json['action_label'],
    );
  }

  Map<String, dynamic> toJson() {
    String catString;
    switch (category) {
      case NotificationCategory.urgent:
        catString = 'urgent';
        break;
      case NotificationCategory.system:
        catString = 'system';
        break;
      case NotificationCategory.task:
        catString = 'task';
        break;
      case NotificationCategory.news:
      default:
        catString = 'news';
        break;
    }

    return {
      'id': id,
      'title': title,
      'content': content,
      'category': catString,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'action_label': actionLabel,
    };
  }
}
