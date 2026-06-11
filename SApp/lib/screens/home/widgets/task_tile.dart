import 'package:flutter/material.dart';
import 'package:sapp/models/task.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/task_service.dart';
class TaskTile extends StatelessWidget {
  final Task item;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: item.isComplete
              ? Colors.grey.shade100
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// CHECKBOX
            IconButton(
              icon: Icon(
                item.isComplete
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: const Color(0xff4B46E5),
                size: 30,
              ),
              onPressed: () {
                if (item.id != null) {
                  context.read<TaskService>().toggleTaskCompletion(item.id!, !item.isComplete);
                }
              },
            ),

            const SizedBox(width: 16),

            /// TEXT SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: (item.tags ?? []).map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    DateFormat('HH:mm').format(item.deadline),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      decoration: item.isComplete
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.isComplete
                          ? Colors.black54
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TaskList extends StatelessWidget {
  final List<Task> items;
  final void Function(Task)? onTaskTap;

  const TaskList({
    super.key,
    required this.items,
    this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TaskTile(
          item: items[index],
          onTap: onTaskTap == null
              ? null
              : () => onTaskTap!(items[index]),
        );
      },
    );
  }
}