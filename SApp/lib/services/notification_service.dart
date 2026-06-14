import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';

class NotificationService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationService() {
    _loadMockData();
    fetchNotifications();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _notifications = [
      AppNotification(
        id: 'mock-1',
        title: 'Urgent System Maintenance 🚨',
        content: 'The system will undergo scheduled maintenance at 23:00 tonight to optimize task scheduling algorithms. Please save your progress before then.',
        category: NotificationCategory.urgent,
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        senderName: 'Administrator',
        actionLabel: 'View Details',
      ),
      AppNotification(
        id: 'mock-2',
        title: 'Upcoming Task Deadline ⏰',
        content: 'Your task "Complete ITSS Report" is due in 2 hours. Keep up the good work to finish on schedule.',
        category: NotificationCategory.task,
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        senderName: 'Lumina Assistant',
        actionLabel: 'View Task',
      ),
      AppNotification(
        id: 'mock-3',
        title: 'New Streak Milestone Reached! 🎉',
        content: 'Fantastic! You have successfully completed tasks for 3 consecutive days. Keep this brilliant streak alive!',
        category: NotificationCategory.news,
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        senderName: 'System',
      ),
      AppNotification(
        id: 'mock-4',
        title: 'New Feature: Sleep Schedule Sync',
        content: 'Welcome to Lumina v1.2! You can now synchronize your personal sleep routines directly with your automated timeline.',
        category: NotificationCategory.system,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        senderName: 'Dev Team',
        actionLabel: 'Learn More',
      ),
      AppNotification(
        id: 'mock-5',
        title: 'Bedtime Reminder 🌙',
        content: 'According to your preferences, your ideal bedtime starts in 30 minutes. Unwind your eyes and prepare to rest.',
        category: NotificationCategory.task,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        senderName: 'Lumina Health',
      ),
    ];
    notifyListeners();
  }

  void addLocalNotification({
    required String title,
    required String content,
    required NotificationCategory category,
    String senderName = 'Lumina Assistant',
    String? actionLabel,
  }) {
    final now = DateTime.now();
    final newNotif = AppNotification(
      id: 'local-${now.millisecondsSinceEpoch}',
      title: title,
      content: content,
      category: category,
      timestamp: now,
      isRead: false,
      senderName: senderName,
      actionLabel: actionLabel,
    );
    _notifications.insert(0, newNotif);
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);

      if (response.isNotEmpty) {
        final dbNotifications = response
            .map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        
        // Trộn cả dữ liệu giả để giao diện trông sinh động hơn
        _notifications = [
          ...dbNotifications,
          ..._notifications.where((n) => n.id.startsWith('mock-')),
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Không thể lấy thông báo từ Supabase (có thể bảng chưa được tạo): $e');
      }
      // Giữ lại dữ liệu mock
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();

      if (!id.startsWith('mock-')) {
        try {
          await _client
              .from('notifications')
              .update({'is_read': true})
              .eq('id', id);
        } catch (e) {
          if (kDebugMode) {
            print('Lỗi khi cập nhật trạng thái đã đọc trên Supabase: $e');
          }
        }
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();

    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _client
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('is_read', false);
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi khi cập nhật tất cả đã đọc trên Supabase: $e');
        }
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();

    if (!id.startsWith('mock-')) {
      try {
        await _client
            .from('notifications')
            .delete()
            .eq('id', id);
      } catch (e) {
        if (kDebugMode) {
          print('Lỗi khi xóa thông báo trên Supabase: $e');
        }
      }
    }
  }
}
