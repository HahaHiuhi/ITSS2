import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _selectedFilter = 0; // 0 = All, 1 = Today, 2 = Upcoming, 3 = Completed

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supabaseService = Provider.of<SupabaseService>(context);

    // Apply filters
    List<Task> filteredTasks = [];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedFilter) {
      case 0: // All active tasks
        filteredTasks = supabaseService.tasks.where((t) => !t.isCompleted).toList();
        break;
      case 1: // Today
        filteredTasks = supabaseService.tasks.where((t) {
          if (t.isCompleted || t.deadline == null) return false;
          return t.deadline!.isAfter(todayStart) && t.deadline!.isBefore(todayEnd);
        }).toList();
        break;
      case 2: // Upcoming (later than today)
        filteredTasks = supabaseService.tasks.where((t) {
          if (t.isCompleted || t.deadline == null) return false;
          return t.deadline!.isAfter(todayEnd);
        }).toList();
        break;
      case 3: // Completed
        filteredTasks = supabaseService.tasks.where((t) => t.isCompleted).toList();
        break;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TaskDetailScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterChip(0, 'All', theme),
                _buildFilterChip(1, 'Today', theme),
                _buildFilterChip(2, 'Upcoming', theme),
                _buildFilterChip(3, 'Done', theme),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Task list content
          Expanded(
            child: supabaseService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          final subColor = _parseColor(task.subject?.color);
                          
                          return Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              supabaseService.deleteTask(task.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Deleted task: ${task.title}'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      // Optional undo logic
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 0,
                              color: theme.colorScheme.surfaceContainerLowest,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (val) {
                                    if (val != null) {
                                      supabaseService.toggleTaskCompletion(task.id, val);
                                    }
                                  },
                                  activeColor: theme.colorScheme.primary,
                                  shape: const CircleBorder(),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    fontWeight: FontWeight.bold,
                                    color: task.isCompleted
                                        ? theme.colorScheme.secondary.withValues(alpha: 0.7)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (task.description != null && task.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        task.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        if (task.subject != null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: subColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              task.subject!.name,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: subColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Icon(
                                          Icons.event_outlined,
                                          size: 14,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.deadline != null
                                              ? DateFormat('MMM d, hh:mm a').format(task.deadline!)
                                              : 'No due date',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                        const Spacer(),
                                        _buildPriorityBadge(task.priority, theme),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TaskDetailScreen(task: task),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, ThemeData theme) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority, ThemeData theme) {
    Color color;
    switch (priority) {
      case 'HIGH':
        color = const Color(0xFFEF4444);
        break;
      case 'MEDIUM':
        color = const Color(0xFFF59E0B);
        break;
      default:
        color = const Color(0xFF3B82F6);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 64,
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'There are no tasks matching this filter.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return const Color(0xFF3525CD);
    final buffer = StringBuffer();
    if (colorHex.length == 6 || colorHex.length == 7) buffer.write('ff');
    buffer.write(colorHex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
