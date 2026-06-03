import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class SupabaseService extends ChangeNotifier {
  static const String _placeholderSupabaseUrl =
      'https://placeholder-url.supabase.co';
  static const String _placeholderSupabaseAnonKey = 'placeholder-anon-key';
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _placeholderSupabaseUrl,
  );
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _placeholderSupabaseAnonKey,
  );

  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _emailRemindersEnabled = true;
  bool _weeklySummaryEnabled = true;
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isConfigured =>
      _supabaseUrl != _placeholderSupabaseUrl &&
          _supabaseAnonKey != _placeholderSupabaseAnonKey;
  bool get isAuthenticated =>
      (isConfigured && _client.auth.currentUser != null);
  bool get emailRemindersEnabled => _emailRemindersEnabled;
  bool get weeklySummaryEnabled => _weeklySummaryEnabled;


  String? _profileName;
  String? _workplace;

  String? get profileName => _profileName;
  String? get workplace => _workplace;

  Future<void> fetchProfile() async {
    try {
      final userId = currentUserId;
      if (userId == null) return;

      final data = await _client
          .from('Profile')
          .select('full_name, workplace')
          .eq('user_id', userId)
          .maybeSingle();

      _profileName = data?['full_name'] as String?;

      _workplace = data?['workplace'] as String?;

      notifyListeners();
    } catch (e) {

      debugPrint('fetchProfile error: $e');
    }
  }


  String get profileEmail {
    return isConfigured ? (_client.auth.currentUser?.email ?? '') : '';
  }


  SupabaseClient get _client => Supabase.instance.client;

  String? get currentUserId {
    return isConfigured ? _client.auth.currentUser?.id : null;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await fetchInitialData();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (!isConfigured) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if ((fullName ?? '').trim().isNotEmpty) 'full_name': fullName!.trim(),
        },
      );
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;

      if (userId != null) {
        await _client.from('Profile').insert({
          'user': userId,
          'full_name': fullName ?? '',
          'workplace': '',
        });
      }
      await fetchInitialData();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }


  Future<void> updateProfile({
    required String fullName,
    required String workplace,
  }) async {
    final userId = currentUserId!;

    await _client
        .from('Profile')
        .update({
      'full_name': fullName,
      'workplace': workplace,
    })
        .eq('user', userId);

    await fetchProfile();
  }

  Future<void> sendPasswordReset() async {
    if (!isConfigured || profileEmail.isEmpty) return;
    await _client.auth.resetPasswordForEmail(profileEmail);
  }

  void setEmailRemindersEnabled(bool value) {
    _emailRemindersEnabled = value;
    notifyListeners();
  }

  void setWeeklySummaryEnabled(bool value) {
    _weeklySummaryEnabled = value;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (isConfigured) {
      await _client.auth.signOut();
    }
    _tasks = [];
    notifyListeners();
  }

  Future<void> fetchInitialData() async {
    if (!isConfigured) return;

    await Future.wait([
      fetchTasks(),
      fetchProfile(),
    ]);
  }

  // Set loading helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ================= TASKS CRUD =================
  Future<void> fetchTasks() async {
    if (!isConfigured || currentUserId == null) return;

    _setLoading(true);

    try {
      final taskRows = await _client
          .from('tasks')
          .select()
          .eq('user_id', currentUserId!)
          .order('deadline');

      final fileRows = await _client
          .from('TaskFiles')
          .select();

      final filesByTask = <int, List<TaskAttachment>>{};

      final userId = currentUserId!;

      for (final row in fileRows as List) {
        final taskId = row['task'] as int;

        final fileName =
        row['file_name'] as String;

        final mimeType =
        (row['mime_type'] ?? '')
            .toString();

        final url = _client.storage
            .from('task-files')
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

      _tasks = (taskRows as List).map((item) {
        final json =
        Map<String, dynamic>.from(item);

        final taskId = json['id'] as int;

        return Task(
          id: taskId,
          name: json['name'] ?? '',
          deadline: json['deadline'] != null
              ? DateTime.parse(json['deadline'])
              : DateTime.now(),
          priority: Priority.values.firstWhere(
                (e) =>
            e.name.toLowerCase() ==
                (json['priority'] ?? 'Medium')
                    .toString()
                    .toLowerCase(),
            orElse: () => Priority.Medium,
          ),
          tags: List<String>.from(
            json['tags'] ?? [],
          ),
          description: json['description'] ?? '',
          attributes: (json['attributes'] is List
              ? json['attributes']
              : const [])
              .map<TaskProperty>(
                (e) =>
                TaskProperty.fromJson(
                  Map<String, dynamic>.from(
                    e,
                  ),
                ),
          )
              .toList(),
          isComplete: json['is_completed'] ?? false,
          attachments: filesByTask[taskId] ?? [],
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tasks: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  List<Task> get tasksForSelectedDay {
    return _tasks.where((task) {
      final deadline = task.deadline;

      return deadline.year == _selectedDate.year &&
          deadline.month == _selectedDate.month &&
          deadline.day == _selectedDate.day;
    }).toList();
  }



  Future<int> createTask({
    required String title,
    String? description,
    DateTime? deadline,
    required String priority,
    List<Map<String, dynamic>>? attributes,
    List<String>? tags
  }) async {
    final task = await _client
        .from('tasks')
        .insert({
      'name': title,
      'description': description ?? '',
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'attributes': attributes ?? [],
      'is_completed': false,
      'user_id': currentUserId,
      'tags': tags ?? []
    })
        .select()
        .single();

    return task['id'] as int;
  }

  Future<void> uploadAttachment({
    required int taskId,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final userId = currentUserId!;

    final path = '$userId/$taskId/$fileName';

    await _client.storage
        .from('TaskFiles')
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

  Future<void> toggleTaskCompletion(int id, bool isCompleted) async {
    if (!isConfigured) return;

    try {
      await _client.from('tasks').update({
        'is_completed': isCompleted,
      }).eq('id', id);

      // Update local cache directly for snappy UI
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final t = _tasks[index];
        _tasks[index] = Task(
          id: t.id,
          name: t.name,
          deadline: t.deadline,
          priority: t.priority,
          tags: t.tags,
          description: t.description,
          attributes: t.attributes,
          isComplete: isCompleted,
          attachments: t.attachments,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error toggling task completion: $e');
      rethrow;
    }
  }

  Future<void> updateTask({
    required int id,
    required String title,
    String? description,
    DateTime? deadline,
    required String priority,
    List<Map<String, dynamic>>? attributes,
    required bool isCompleted,
    List<String>? tags
  }) async {
    if (!isConfigured) return;

    try {
      await _client.from('tasks').update({
        'name': title,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'priority': priority,
        'attributes': attributes ?? {},
        'is_completed': isCompleted,
        'tags' : tags ?? []
      }).eq('id', id);
      await fetchTasks();
    } catch (e) {
      if (kDebugMode) print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    if (!isConfigured) return;

    try {
      await _client.from('tasks').delete().eq('id', id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error deleting task: $e');
      rethrow;
    }
  }

  Future<void> deleteAttachment({
    required int taskId,
    required String fileName,
  }) async {
    final userId = currentUserId!;

    if (fileName == '*') {
      // Lấy toàn bộ file trong folder
      final files = await _client.storage
          .from('TaskFiles')
          .list(path: '$userId/$taskId');

      if (files.isNotEmpty) {
        await _client.storage
            .from('TaskFiles')
            .remove(
          files.map((f) => '$userId/$taskId/${f.name}').toList(),
        );
      }

      await _client
          .from('TaskFiles')
          .delete()
          .eq('task', taskId);

      return;
    }

    await _client.storage
        .from('TaskFiles')
        .remove([
      '$userId/$taskId/$fileName',
    ]);

    await _client
        .from('TaskFiles')
        .delete()
        .eq('task', taskId)
        .eq('file_name', fileName);
  }

  void selectDate(DateTime date) {
    print('Selected: $date');
    _selectedDate = date;
    notifyListeners();
  }
}
