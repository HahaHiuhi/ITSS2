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
        title: 'Cập nhật hệ thống khẩn cấp 🚨',
        content: 'Hệ thống sẽ tiến hành bảo trì định kỳ vào lúc 23:00 tối nay để tối ưu hóa hiệu suất lập lịch công việc. Vui lòng lưu các thay đổi của bạn trước thời gian này.',
        category: NotificationCategory.khanCap,
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        senderName: 'Quản trị viên',
        actionLabel: 'Xem chi tiết',
      ),
      AppNotification(
        id: 'mock-2',
        title: 'Hạn chót công việc sắp đến ⏰',
        content: 'Bạn có công việc "Hoàn thành báo cáo ITSS" sắp đến hạn hoàn thành trong 2 giờ tới. Hãy tập trung hoàn thành đúng tiến độ.',
        category: NotificationCategory.congViec,
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        senderName: 'Lumina Trợ lý',
        actionLabel: 'Xem công việc',
      ),
      AppNotification(
        id: 'mock-3',
        title: 'Chúc mừng! Bạn đạt Streak mới 🎉',
        content: 'Tuyệt vời! Bạn đã duy trì thói quen hoàn thành công việc liên tục trong 3 ngày qua. Tiếp tục phát huy tinh thần này nhé!',
        category: NotificationCategory.tinTuc,
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        senderName: 'Hệ thống',
      ),
      AppNotification(
        id: 'mock-4',
        title: 'Tính năng mới: Đồng bộ hóa Lịch trình',
        content: 'Chào mừng bạn đến với phiên bản Lumina v1.2! Giờ đây bạn đã có thể đồng bộ hóa lịch ngủ cá nhân trực tiếp vào thời gian biểu tự động.',
        category: NotificationCategory.heThong,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        senderName: 'Đội ngũ Phát triển',
        actionLabel: 'Tìm hiểu thêm',
      ),
      AppNotification(
        id: 'mock-5',
        title: 'Nhắc nhở chuẩn bị đi ngủ 🌙',
        content: 'Theo thiết lập của bạn, giờ đi ngủ lý tưởng sẽ bắt đầu sau 30 phút nữa. Hãy thư giãn mắt và chuẩn bị nghỉ ngơi.',
        category: NotificationCategory.congViec,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        senderName: 'Lumina Sức khỏe',
      ),
    ];
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
