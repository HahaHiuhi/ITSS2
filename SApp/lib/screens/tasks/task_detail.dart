import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
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

  const TaskDetailScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskDetailScreen> createState() =>
      _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>  {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  DateTime _deadline = DateTime.now();

  Duration _t2c = Duration.zero;
  Duration _timeCompleted = Duration.zero;

  final List<TaskAttachment> _existingAttachments = [];
  final List<TaskAttachment> _deletedAttachments = [];
  final List<LocalAttachment> _newAttachments = [];
  List<String> _tags = [];
  List<TaskAttachment> _attachments = [];

  bool get isEditMode => widget.task != null;

  double get completionRate {
    if (_t2c == 0) return 0;
    return (_timeCompleted.inMinutes / _t2c.inMinutes)
        .clamp(0.0, 1.0);
  }



  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _nameController = TextEditingController(
      text: task?.name ?? '',
    );

    _descriptionController =
        TextEditingController(
          text: task?.description ?? '',
        );

    _deadline =
        task?.deadline ?? DateTime.now();

    _t2c = task?.t2c ?? Duration.zero;
    _timeCompleted = task?.timeCompleted ?? Duration.zero;

    _tags = List<String>.from(
      task?.tags ?? [],
    );

    _attachments =
    List<TaskAttachment>.from(
      task?.attachments ?? [],
    );

    _existingAttachments.addAll(widget.task?.attachments ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _deadline,
      ),
    );

    if (time == null) return;

    setState(() {
      _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final task = Task(
      id: widget.task?.id,
      name: _nameController.text.trim(),
      deadline: _deadline,
      t2c: _t2c,
      timeCompleted: _timeCompleted,
      tags: _tags,
      description:
      _descriptionController.text.trim(),
      isComplete:
      _t2c.inMinutes > 0 &&
          _timeCompleted.inMinutes >= _t2c.inMinutes,
      attachments: _attachments,
    );

    final service =
    context.read<TaskService>();

    if (isEditMode) {
      await service.updateTask(task);
    } else {
      await service.createTask(task);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode
              ? 'Edit Task'
              : 'Create Task',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration:
              const InputDecoration(
                labelText: 'Task Name',
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _descriptionController,
              maxLines: 4,
              decoration:
              const InputDecoration(
                labelText: 'Description',
              ),
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(
                Icons.calendar_today,
              ),
              title: const Text(
                'Deadline',
              ),
              subtitle: Text(
                '${_deadline.day}/${_deadline.month}/${_deadline.year}',
              ),
              onTap: _pickDeadline,
            ),

            const SizedBox(height: 16),

            TextFormField(
              initialValue: _t2c.inMinutes.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimated Minutes',
              ),
              onChanged: (value) {
                setState(() {
                  _t2c = Duration(
                    minutes: int.tryParse(value) ?? 0,
                  );
                });
              },
            ),

            TextFormField(
              initialValue: _timeCompleted.inMinutes.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Completed Minutes',
              ),
              onChanged: (value) {
                setState(() {
                  _timeCompleted = Duration(
                    minutes: int.tryParse(value) ?? 0,
                  );
                });
              },
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: completionRate,
            ),

            const SizedBox(height: 8),

            Text(
              '${(completionRate * 100).toStringAsFixed(0)}%',
            ),

            const SizedBox(height: 24),

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

// EXISTING attachments
            ..._existingAttachments.map((a) {
              return ListTile(
                leading: const Icon(Icons.cloud_done),
                title: Text(a.name),
                onTap: a.url != null ? () => _openUrl(a.url!) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _deletedAttachments.add(a);
                      _existingAttachments.remove(a);
                    });
                  },
                ),
              );
            }),

// NEW attachments
            ..._newAttachments.map((a) {
              return ListTile(
                leading: Icon(
                  a.type == AttachmentType.image
                      ? Icons.image
                      : Icons.insert_drive_file,
                ),
                title: Text(a.name),
              );
            }),
            FilledButton(
              onPressed: _saveTask,
              child: Text(
                isEditMode
                    ? 'Save Changes'
                    : 'Create Task',
              ),
            ),
          ],
        ),
      ),
    );
  }
}