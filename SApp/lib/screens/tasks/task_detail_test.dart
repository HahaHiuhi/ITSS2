// task_detail_screen.dart
// Generated TaskDetailScreen template.
// Adjust imports if your project structure differs.
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/tasks/widget/property.dart';
import '../../models/task.dart';
import '../../services/supabase_service.dart';

class EditableProperty {
  String name;
  String value;

  EditableProperty({required this.name, required this.value});
}

class LocalAttachment {
  final String name;
  final Uint8List bytes;
  final AttachmentType type;

  LocalAttachment({
    required this.name,
    required this.bytes,
    required this.type,
  });
}

class TaskDetailScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  DateTime? _dueDate;
  Priority _priority = Priority.Medium;
  String _status = 'Not Started';
  final List<String> _tags = [];
  final List<EditableProperty> _properties = [];
  final List<LocalAttachment> _newAttachments = [];
  final List<TaskAttachment> _existingAttachments = [];
  final List<TaskAttachment> _deletedAttachments = [];

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    // CONTROLLERS + STATES
    _titleController =
        TextEditingController(text: widget.task?.name ?? '');

    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');

    _dueDate = widget.task?.deadline;
    _priority = widget.task?.priority ?? Priority.Medium;
    _status =
    (widget.task?.isComplete ?? false) ? 'Finished' : 'Not Started';
    _tags.addAll(widget.task?.tags ?? []);
    for (final p in widget.task?.attributes ?? <TaskProperty>[]) {
      _properties.add(
        EditableProperty(name: p.name, value: p.value),
      );
    }

    _existingAttachments.addAll(widget.task?.attachments ?? []);
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  Future<void> _addTag() async {
    final controller = TextEditingController();

    final tag = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Exam, Work, Project...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (tag == null || tag.isEmpty) return;

    setState(() {
      if (!_tags.contains(tag)) {
        _tags.add(tag);
      }
    });
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _newAttachments.add(
        LocalAttachment(
          name: image.name,
          bytes: bytes,
          type: AttachmentType.image,
        ),
      );
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      for (final file in result.files) {
        if (file.bytes == null) continue;

        _newAttachments.add(
          LocalAttachment(
            name: file.name,
            bytes: file.bytes!,
            type: AttachmentType.file,
          ),
        );
      }
    });
  }

  Future<void> _pickDueDate() async {
    if (context.mounted) {
      final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _dueDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );

      if (date == null) return;

      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time == null) return;

      setState(() {
        _dueDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _selectPriority() async {
    final value = await showModalBottomSheet<Priority>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Priority.values
              .map(
                (e) => ListTile(
              title: Text(e.name),
              onTap: () => Navigator.pop(context, e),
            ),
          )
              .toList(),
        ),
      ),
    );

    if (value != null) {
      setState(() => _priority = value);
    }
  }

  Future<void> _selectStatus() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Not Started'),
              onTap: () => Navigator.pop(context, 'Not Started'),
            ),
            ListTile(
              title: const Text('Finished'),
              onTap: () => Navigator.pop(context, 'Finished'),
            ),
          ],
        ),
      ),
    );

    if (value != null) {
      setState(() => _status = value);
    }
  }

  Future<void> _addProperty() async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Property'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Property Name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != true) return;

    if (nameController.text.trim().isEmpty) return;

    setState(() {
      _properties.add(
        EditableProperty(
          name: nameController.text.trim(),
          value: valueController.text.trim(),
        ),
      );
    });
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final service =
    Provider.of<SupabaseService>(context, listen: false);

    final attributes = _properties
        .map((e) => {'name': e.name, 'value': e.value})
        .toList();

    int? taskId;

    if (_isEditing) {
      taskId = widget.task!.id;
      if (taskId != null) {
        await service.updateTask(
            id: taskId,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            deadline: _dueDate,
            priority: _priority.name,
            attributes: attributes,
            isCompleted: _status != "Not Started",
            tags: _tags
        );


        for (final attachment in _deletedAttachments) {
          await service.deleteAttachment(
            taskId: taskId,
            fileName: attachment.name,
          );
        }
      }
    }
    else {
        taskId = await service.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          deadline: _dueDate,
          priority: _priority.name,
          attributes: attributes,
        );


      for (final attachment in _newAttachments) {
        await service.uploadAttachment(
          taskId: taskId,
          fileName: attachment.name,
          bytes: attachment.bytes,
          mimeType: attachment.type == AttachmentType.image
              ? 'image/jpeg'
              : 'application/octet-stream',
        );
      }

      await service.fetchTasks();
    }
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _deleteTask(int taskId) async {
    final service =
    Provider.of<SupabaseService>(context, listen: false);
    await service.deleteAttachment(taskId: taskId, fileName: "*");
    await service.deleteTask(taskId);
    if (mounted) {
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isEditing)
            FloatingActionButton(
              heroTag: 'delete',
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              onPressed: () => _deleteTask(widget.task!.id!),
              child: const Icon(Icons.delete_outline),
            ),

          const SizedBox(width: 12),

          FloatingActionButton.extended(
            heroTag: 'save',
            foregroundColor: Colors.white,
            onPressed: _saveTask,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Task title',
                ),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: InputBorder.none
                ),
              ),
              const SizedBox(height: 20),
              PropertyRow(
                icon: Icons.calendar_today_outlined,
                label: 'Due date',
                value: _dueDate == null
                    ? 'Empty'
                    : DateFormat('dd/MM/yyyy HH:mm').format(_dueDate!),
                onTap: _pickDueDate,
              ),

              PropertyRow(
                icon: Icons.flag_outlined,
                label: 'Priority',
                value: _priority.name,
                onTap: _selectPriority,
              ),

              PropertyRow(
                icon: Icons.check_circle_outline,
                label: 'Status',
                value: _status,
                onTap: _selectStatus,
              ),

              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _addTag,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return TagChip(
                    tag: tag,
                    onDelete: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Properties',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _addProperty,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              ..._properties.asMap().entries.map((entry) {
                final index = entry.key;
                final property = entry.value;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade50,
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          initialValue: property.name,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Property',
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (value) {
                            property.name = value;
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: TextFormField(
                          initialValue: property.value,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Empty',
                          ),
                          onChanged: (value) {
                            property.value = value;
                          },
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          setState(() {
                            _properties.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Image'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('File'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._existingAttachments.map(
                    (a) => ListTile(
                  leading: const Icon(Icons.cloud_done),
                  title: Text(a.name),
                  onTap: a.url != null
                      ? () => _openUrl(a.url!)
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _deletedAttachments.add(a);
                        _existingAttachments.remove(a);
                      });
                    },
                  ),
                ),
              ),
              ..._newAttachments.map(
                    (a) => ListTile(
                  leading: Icon(
                    a.type == AttachmentType.image
                        ? Icons.image
                        : Icons.insert_drive_file,
                  ),
                  title: Text(a.name),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
