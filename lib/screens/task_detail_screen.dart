import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/task.dart';
import '../models/subject.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task; // Pass this if editing an existing task

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _priority = 'MEDIUM';
  String? _selectedSubjectId;
  DateTime? _selectedDeadline;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    if (_isEditing) {
      _priority = widget.task!.priority;
      _selectedSubjectId = widget.task!.subjectId;
      _selectedDeadline = widget.task!.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final supabaseService = Provider.of<SupabaseService>(context, listen: false);

    try {
      if (_isEditing) {
        await supabaseService.updateTask(
          id: widget.task!.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          deadline: _selectedDeadline,
          priority: _priority,
          subjectId: _selectedSubjectId,
        );
      } else {
        await supabaseService.createTask(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          deadline: _selectedDeadline,
          priority: _priority,
          subjectId: _selectedSubjectId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Task updated successfully' : 'Task created successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save task: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _deleteTask() async {
    if (!_isEditing) return;

    final supabaseService = Provider.of<SupabaseService>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabaseService.deleteTask(widget.task!.id);
        if (mounted) {
          Navigator.pop(context); // Close details page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete task: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = Provider.of<SupabaseService>(context).subjects;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _deleteTask,
              icon: const Icon(Icons.delete_outline_rounded),
              color: theme.colorScheme.error,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              Text(
                'Task Title',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter a title' : null,
                decoration: InputDecoration(
                  hintText: 'Enter task title (e.g., Submit Lab Report)',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description field
              Text(
                'Description (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add some details...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Subject selection & Priority in a row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSubjectId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLowest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('None / General'),
                            ),
                            ...subjects.map(
                              (s) => DropdownMenuItem<String>(
                                value: s.id,
                                child: Text(s.name),
                              ),
                            )
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedSubjectId = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Priority selection
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _priority,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLowest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'LOW', child: Text('Low')),
                            DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                            DropdownMenuItem(value: 'HIGH', child: Text('High')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _priority = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Deadline selection
              Text(
                'Deadline',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDeadline(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDeadline != null
                            ? DateFormat('EEEE, MMMM d, yyyy - hh:mm a').format(_selectedDeadline!)
                            : 'Set due date & time',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _selectedDeadline != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.secondary.withValues(alpha: 0.8),
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDeadline != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedDeadline = null;
                            });
                          },
                          icon: const Icon(Icons.clear, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Create Task',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
