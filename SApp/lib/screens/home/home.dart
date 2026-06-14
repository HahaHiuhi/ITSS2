import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sapp/screens/home/widgets/home_widgets.dart';
import 'package:sapp/screens/tasks/task_detail.dart';
import 'package:sapp/services/task_service.dart';
import 'package:sapp/services/notification_service.dart';
import 'package:sapp/screens/notifications/notification_screen.dart';
import 'package:sapp/screens/stats/streak_board_screen.dart';
import 'package:sapp/models/notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FireworksOverlayState> _fireworksKey = GlobalKey<FireworksOverlayState>();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<TaskService>();
    final tasks = service.tasksForSelectedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Consumer<NotificationService>(
            builder: (context, notifService, _) {
              final unread = notifService.unreadCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StreakBoardScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: service.currentStreak > 0 ? Colors.orange.shade700 : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${service.currentStreak}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: service.currentStreak > 0 ? Colors.orange.shade700 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff4B46E5), Color(0xff6C63FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff4B46E5).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          foregroundColor: Colors.white,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TaskDetailScreen(),
              ),
            );

            if (context.mounted) {
              await context
                  .read<TaskService>()
                  .fetchTasks();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              CalendarDaysRow(
                onDateSelected: (date) {
                  context.read<TaskService>().selectDate(date);
                },
              ),
              if (tasks.isNotEmpty)
                DailyProgressCard(
                  progress: tasks.where((t) => t.isComplete).length / tasks.length,
                  completedCount: tasks.where((t) => t.isComplete).length,
                  totalCount: tasks.length,
                ),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                  child: Text('No tasks found'),
                )
                    : TaskList(
                  items: tasks,
                  onTaskTap: (task) async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(
                          task: task,
                        ),
                      ),
                    );

                    if (context.mounted) {
                      await context
                          .read<TaskService>()
                          .fetchTasks();
                    }
                  },
                  onToggleComplete: (task, isCompleted) async {
                    if (isCompleted) {
                      _fireworksKey.currentState?.shoot();
                    }
                    
                    final taskService = context.read<TaskService>();
                    final notifService = context.read<NotificationService>();
                    final oldStreak = taskService.currentStreak;

                    await taskService.toggleTaskCompletion(task.id!, isCompleted);

                    if (isCompleted) {
                      final todayTasks = taskService.tasksForSelectedDay;
                      final allCompleted = todayTasks.isNotEmpty && todayTasks.every((t) => t.isComplete);
                      if (allCompleted) {
                        notifService.addLocalNotification(
                          title: 'Daily Tasks Completed! 🌟',
                          content: 'Incredible work! You have finished all tasks assigned for today. Keep up this amazing momentum!',
                          category: NotificationCategory.news,
                          senderName: 'Lumina Assistant',
                        );
                      }

                      final newStreak = taskService.currentStreak;
                      if (newStreak > oldStreak) {
                        if (newStreak == 3 || newStreak == 7 || newStreak == 30 || newStreak == 100 || (newStreak > 0 && newStreak % 5 == 0)) {
                          notifService.addLocalNotification(
                            title: 'New Streak Milestone! 🏆',
                            content: 'Phenomenal! You have reached a $newStreak-day streak of completing tasks. You are on fire!',
                            category: NotificationCategory.news,
                            senderName: 'Lumina Assistant',
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          FireworksOverlay(key: _fireworksKey),
        ],
      ),
    );
  }
}