import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sapp/screens/home/widgets/home_widgets.dart';
import 'package:sapp/screens/tasks/task_detail.dart';
import 'package:sapp/services/task_service.dart';
import 'package:sapp/services/notification_service.dart';
import 'package:sapp/screens/notifications/notification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '3',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
      body: Column(
        children: [
          CalendarDaysRow(
            onDateSelected: (date) {
              context.read<TaskService>().selectDate(date);
            },
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
            ),
          ),
        ],
      ),
    );
  }
}