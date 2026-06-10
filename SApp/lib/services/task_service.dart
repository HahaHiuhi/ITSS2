import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task.dart';
import '../models/schedule.dart';
class TaskService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  static const String bucketName = 'TaskFiles';

  List<Task> _tasks = [];
  List<Schedule> _schedules = [];
  List<Schedule> _sleepSchedules = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  // =========================
  // GETTERS
  // =========================

  List<Task> get tasks => _tasks;
  List<Schedule> get schedules => _schedules;
  set schedules(List<Schedule> value) {
    _schedules = value;
    notifyListeners();
  }
  bool get isLoading => _isLoading;

  DateTime get selectedDate => _selectedDate;

  String? get currentUserId =>
      _client.auth.currentUser?.id;

  bool get isAuthenticated =>
      currentUserId != null;

  List<Task> get tasksForSelectedDay {
    return _tasks.where((task) {
      final d = task.deadline;

      return d.year == _selectedDate.year &&
          d.month == _selectedDate.month &&
          d.day == _selectedDate.day;
    }).toList();
  }

  List<Schedule> get sleepSchedules => _sleepSchedules;


  set sleepSchedules (List<Schedule> value) {
    _sleepSchedules = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void rebuildSchedule({
    required List<Event> fixedEvents,
  }) {
    final now = DateTime.now();
    final slots = Scheduler.generateFreeSlots(
      start: now,
      end: now.add(const Duration(days: 3)),
      fixedEvents: fixedEvents,
    );

    final taskSchedules = Scheduler.scheduleTasks(
      tasks: _tasks,
      slots: slots,
      now: now,
    );
    _schedules = [
      ..._sleepSchedules,
      ...taskSchedules,
    ];
    print(_schedules);
    notifyListeners();
  }
  // =========================
  // FETCH TASKS
  // =========================

  Future<void> fetchTasks({bool rebuild = false})async {
    final userId = currentUserId;

    if (userId == null) return;

    _setLoading(true);

    try {
      final taskRows = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('deadline');

      final fileRows =
      await _client.from('TaskFiles').select();

      final filesByTask =
      <int, List<TaskAttachment>>{};

      for (final row in fileRows as List) {
        final taskId = row['task'] as int;
        final fileName =
        row['file_name'] as String;
        final mimeType =
        (row['mime_type'] ?? '').toString();

        final url = _client.storage
            .from(bucketName)
            .getPublicUrl(
          '$userId/$taskId/$fileName',
        );

        final attachment = TaskAttachment(
          name: fileName,
          url: url,
          type: mimeType.startsWith('image/')
              ? AttachmentType.image
              : AttachmentType.file,
        );

        filesByTask
            .putIfAbsent(taskId, () => [])
            .add(attachment);
      }

      _tasks = (taskRows as List)
          .map((item) {
        final json =
        Map<String, dynamic>.from(item);

        final taskId = json['id'] as int;

        return Task(
          id: taskId,
          name: json['name'] ?? '',
          deadline: json['deadline'] != null
              ? DateTime.parse(
              json['deadline'])
              : DateTime.now(),
          t2c: Duration(minutes: json['time_to_complete'] ?? 0),
          timeCompleted: Duration(minutes: json['time_completed'] ?? 0),
          description:
          json['description'] ?? '',
          isComplete:
          json['is_completed'] ?? false,
          attachments:
          filesByTask[taskId] ?? [],
        );
      })
          .toList();
      print(tasks);
      if (rebuild == true){
        List<Event> fixedEvents = [];
        for (final schedule in _sleepSchedules) {
          if (schedule.task == null){
            final event = schedule.toEvent();
            fixedEvents.add(event);
          }
        }
        rebuildSchedule(fixedEvents: fixedEvents);
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Fetch tasks error: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // CREATE
  // =========================

  Future<int> createTask(Task task) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    final result = await _client
        .from('tasks')
        .insert({
      'name': task.name,
      'time_to_complete': task.t2c.inMinutes,
      'time_completed': task.timeCompleted.inMinutes,
      'deadline': task.deadline.toIso8601String(),
      'description': task.description,
      'tags': task.tags ?? [],
      'is_completed': task.isComplete,
      'user_id': userId,
    })
        .select()
        .single();
    final taskId = result['id'] as int;
    for (final f in task.attachments ?? []) {
      await _client.from('TaskFiles').insert({
        'file_name': f.fileName,
        'file_url': f.url,
        'file_size': f.size,
        'mime_type': f.mimeType,
        'task': taskId,
        'uploaded_by': userId,
      });
    }
    await fetchTasks(rebuild: true);

    return result['id'] as int;
  }

  Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception('Task id is null');
    }

    final oldTask = _tasks.firstWhere((t) => t.id == task.id);

    bool shouldRebuild = false;

    if (oldTask.t2c != task.t2c ||
        oldTask.timeCompleted != task.timeCompleted ||
        oldTask.deadline != task.deadline ||
        oldTask.name != task.name ||
        oldTask.isComplete != task.isComplete) {
      shouldRebuild = true;
    }

    // 1. UPDATE TASK
    await _client.from('tasks').update({
      'name': task.name,
      'time_to_complete': task.t2c.inMinutes,
      'time_completed': task.timeCompleted.inMinutes,
      'deadline': task.deadline.toIso8601String(),
      'description': task.description,
      'tags': task.tags ?? [],
      'is_completed': task.isComplete,
    }).eq('id', task.id!);

    // 2. UPDATE ATTACHMENTS (TaskFiles)
    // ❗ delete old files first
    await _client
        .from('TaskFiles')
        .delete()
        .eq('task', task.id!);

    // ❗ insert new files
    for (final file in task.attachments ?? []) {
      await _client.from('TaskFiles').insert({
        'file_name': file.fileName,
        'file_url': file.url,
        'file_size': file.size,
        'mime_type': file.mimeType,
        'task': task.id!,
        'uploaded_by': currentUserId,
      });
    }

    // 3. refresh local state
    await fetchTasks(rebuild: shouldRebuild);
  }

  // =========================
  // TOGGLE COMPLETE
  // =========================

  Future<void> toggleTaskCompletion(
      int id,
      bool isCompleted,
      ) async {
    await _client
        .from('tasks')
        .update({
      'is_completed': isCompleted,
    })
        .eq('id', id);

    final index =
    _tasks.indexWhere((t) => t.id == id);

    if (index != -1) {
      final task = _tasks[index];

      _tasks[index] = Task(
        id: task.id,
        name: task.name,
        deadline: task.deadline,
        t2c: task.t2c,
        timeCompleted: task.timeCompleted,
        tags: task.tags,
        description: task.description,
        isComplete: isCompleted,
        attachments: task.attachments,
      );
      await fetchTasks(rebuild: true);
      notifyListeners();
    }
  }

  // =========================
  // DELETE TASK
  // =========================

  Future<void> deleteTask(int id) async {
    await deleteAttachment(
      taskId: id,
      fileName: '*',
    );

    await _client
        .from('tasks')
        .delete()
        .eq('id', id);

    _tasks.removeWhere(
          (task) => task.id == id,
    );

    await fetchTasks(rebuild: true);

    notifyListeners();
  }

  // =========================
  // FILE UPLOAD
  // =========================

  Future<void> uploadAttachment({
    required int taskId,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    final path =
        '$userId/$taskId/$fileName';

    await _client.storage
        .from(bucketName)
        .uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: mimeType,
        upsert: true,
      ),
    );

    await _client.from('TaskFiles').insert({
      'file_name': fileName,
      'file_size': bytes.length,
      'mime_type': mimeType,
      'task': taskId,
      'uploaded_by': userId,
    });
  }

  // =========================
  // FILE DELETE
  // =========================

  Future<void> deleteAttachment({
    required int taskId,
    required String fileName,
  }) async {
    final userId = currentUserId;

    if (userId == null) return;

    if (fileName == '*') {
      final files = await _client.storage
          .from(bucketName)
          .list(
        path: '$userId/$taskId',
      );

      if (files.isNotEmpty) {
        await _client.storage
            .from(bucketName)
            .remove(
          files
              .map(
                (f) =>
            '$userId/$taskId/${f.name}',
          )
              .toList(),
        );
      }

      await _client
          .from('TaskFiles')
          .delete()
          .eq('task', taskId);

      return;
    }

    await _client.storage
        .from(bucketName)
        .remove([
      '$userId/$taskId/$fileName',
    ]);

    await _client
        .from('TaskFiles')
        .delete()
        .eq('task', taskId)
        .eq('file_name', fileName);
  }

  // =========================
  // UI HELPERS
  // =========================

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clear() {
    _tasks = [];
    notifyListeners();
  }
}