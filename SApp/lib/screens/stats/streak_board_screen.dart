import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';

class StreakBoardScreen extends StatelessWidget {
  const StreakBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final currentStreak = taskService.currentStreak;
    final longestStreak = taskService.longestStreak;
    final completedDates = taskService.completedDates;
    final totalCompletedTasks = taskService.tasks.where((t) => t.isComplete).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B1C30)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Streak Board',
          style: TextStyle(
            color: Color(0xFF0B1C30),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fire Badge Section
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.12),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glowing rings
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 96,
                    color: currentStreak > 0 ? Colors.orange.shade700 : Colors.grey.shade300,
                  ),
                  if (currentStreak > 0)
                    Positioned(
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xff4B46E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              '$currentStreak Days Streak',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getMotivationalMessage(currentStreak),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5A5F68),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Statistics Row
            Row(
              children: [
                _buildStatCard(
                  title: 'Longest Streak',
                  value: '$longestStreak',
                  subtitle: 'days record',
                  icon: Icons.emoji_events_outlined,
                  iconColor: Colors.amber.shade700,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'Completed Tasks',
                  value: '$totalCompletedTasks',
                  subtitle: 'tasks total',
                  icon: Icons.task_alt,
                  iconColor: const Color(0xff4B46E5),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Contribution Grid Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lịch Sử Hoàn Thành',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hoàn thành ít nhất 1 nhiệm vụ trong ngày để thắp sáng ô.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lưới 30 ngày đóng góp kiểu GitHub
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, // 7 ngày 1 tuần
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 28, // Hiển thị 4 tuần gần đây
                    itemBuilder: (context, index) {
                      final dayDiff = 27 - index;
                      final date = DateTime.now().subtract(Duration(days: dayDiff));
                      final dateStr = _formatDateStr(date);
                      final isDone = completedDates.contains(dateStr);
                      final isToday = date.day == DateTime.now().day &&
                          date.month == DateTime.now().month &&
                          date.year == DateTime.now().year;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isToday
                                ? const Color(0xff4B46E5).withOpacity(0.5)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          gradient: isDone
                              ? LinearGradient(
                                  colors: [
                                    Colors.orange.shade500,
                                    Colors.orange.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade200,
                                  ],
                                ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _getWeekdayLabel(date.weekday),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isDone
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B1C30),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage(int streak) {
    if (streak == 0) {
      return 'Bắt đầu hoàn thành nhiệm vụ ngay hôm nay để thắp sáng ngọn lửa Streak đầu tiên của bạn! 🔥';
    } else if (streak < 3) {
      return 'Một khởi đầu tuyệt vời! Hãy duy trì thêm một ngày nữa để củng cố thói quen nhé. 👍';
    } else if (streak < 7) {
      return 'Tuyệt vời! Bạn đang hình thành thói quen tốt rồi đấy. Tiếp tục phát huy nào! 🚀';
    } else {
      return 'Quá xuất sắc! Bạn là một chiến binh năng suất thực thụ. Ngọn lửa đang cháy rực rỡ! 🔥🎉';
    }
  }

  String _getWeekdayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  String _formatDateStr(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
