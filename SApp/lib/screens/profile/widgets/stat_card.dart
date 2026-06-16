import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/task_service.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final totalTasks = taskService.tasks.length;
    final completedTasks = taskService.tasks.where((t) => t.isComplete).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Tasks',
              value: '$totalTasks',
            ),
            _StatItem(
              label: 'Done',
              value: '$completedTasks',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }
}