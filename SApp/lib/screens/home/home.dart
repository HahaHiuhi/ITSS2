import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sapp/screens/home/widgets/home_widgets.dart';
import 'package:sapp/screens/tasks/task_detail_test.dart';
import 'package:sapp/services/supabase_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SupabaseService>();
    final tasks = service.tasksForSelectedDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
                .read<SupabaseService>()
                .fetchTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CalendarDaysRow(
            onDateSelected: (date) {
              context.read<SupabaseService>().selectDate(date);
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
                      .read<SupabaseService>()
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