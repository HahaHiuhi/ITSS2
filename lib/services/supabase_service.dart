import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject.dart';
import '../models/task.dart';
import '../models/schedule.dart';

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

  List<Subject> _subjects = [];
  List<Task> _tasks = [];
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  bool _isDemoSession = false;
  bool _emailRemindersEnabled = true;
  bool _weeklySummaryEnabled = true;
  String _demoName = 'Demo Student';
  String _demoEmail = 'demo@student.edu';
  String _demoStudentId = 'STU-2026';
  String _demoSchool = 'Academic Planner University';
  String _demoMajor = 'Computer Science';
  String _demoPhone = '+84 900 000 000';
  String _demoBio =
      'Focused on keeping classes, deadlines, and study goals organized.';

  List<Subject> get subjects => _subjects;
  List<Task> get tasks => _tasks;
  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  bool get isConfigured =>
      _supabaseUrl != _placeholderSupabaseUrl &&
      _supabaseAnonKey != _placeholderSupabaseAnonKey;
  bool get isAuthenticated =>
      _isDemoSession || (isConfigured && _client.auth.currentUser != null);
  bool get isDemoSession => _isDemoSession;
  bool get emailRemindersEnabled => _emailRemindersEnabled;
  bool get weeklySummaryEnabled => _weeklySummaryEnabled;
  String get profileName {
    if (_isDemoSession) return _demoName;
    final metadata =
        isConfigured ? _client.auth.currentUser?.userMetadata : null;
    return (metadata?['full_name'] as String?) ??
        (metadata?['name'] as String?) ??
        'Student';
  }

  String get profileEmail {
    if (_isDemoSession) return _demoEmail;
    return isConfigured ? (_client.auth.currentUser?.email ?? '') : '';
  }

  String get profileStudentId {
    if (_isDemoSession) return _demoStudentId;
    final metadata =
        isConfigured ? _client.auth.currentUser?.userMetadata : null;
    return (metadata?['student_id'] as String?) ?? '';
  }

  String get profileSchool {
    if (_isDemoSession) return _demoSchool;
    final metadata =
        isConfigured ? _client.auth.currentUser?.userMetadata : null;
    return (metadata?['school'] as String?) ?? '';
  }

  String get profileMajor {
    if (_isDemoSession) return _demoMajor;
    final metadata =
        isConfigured ? _client.auth.currentUser?.userMetadata : null;
    return (metadata?['major'] as String?) ?? '';
  }

  String get profilePhone {
    if (_isDemoSession) return _demoPhone;
    final metadata =
        isConfigured ? _client.auth.currentUser?.userMetadata : null;
    return (metadata?['phone'] as String?) ?? '';
  }

  String get profileBio {
    if (_isDemoSession) return _demoBio;
    final metadata =
        isConfigured ? _client.auth.currentUser?.userMetadata : null;
    return (metadata?['bio'] as String?) ?? '';
  }

  SupabaseClient get _client => Supabase.instance.client;

  String? get currentUserId {
    if (_isDemoSession) return 'demo-user';
    return isConfigured ? _client.auth.currentUser?.id : null;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      _isDemoSession = true;
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
      if ((fullName ?? '').trim().isNotEmpty) {
        _demoName = fullName!.trim();
      }
      _demoEmail = email.trim();
      _isDemoSession = true;
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
      await fetchInitialData();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> continueAsDemo() async {
    _isDemoSession = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String studentId,
    required String school,
    required String major,
    required String phone,
    required String bio,
  }) async {
    _setLoading(true);
    try {
      if (_isDemoSession || !isConfigured) {
        _demoName = name;
        _demoStudentId = studentId;
        _demoSchool = school;
        _demoMajor = major;
        _demoPhone = phone;
        _demoBio = bio;
        _isDemoSession = true;
      } else {
        await _client.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': name,
              'student_id': studentId,
              'school': school,
              'major': major,
              'phone': phone,
              'bio': bio,
            },
          ),
        );
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
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
    _isDemoSession = false;
    if (isConfigured) {
      await _client.auth.signOut();
    }
    _subjects = [];
    _tasks = [];
    _schedules = [];
    notifyListeners();
  }

  Future<void> fetchInitialData() async {
    if (!isConfigured) return;

    await Future.wait([
      fetchSubjects(),
      fetchTasks(),
      fetchSchedules(),
    ]);
  }

  // Set loading helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ================= SUBJECTS CRUD =================
  Future<void> fetchSubjects() async {
    if (!isConfigured) return;

    _setLoading(true);
    try {
      final response = await _client
          .from('subjects')
          .select()
          .order('name', ascending: true);

      _subjects =
          (response as List).map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching subjects: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createSubject(String name, String colorHex) async {
    if (!isConfigured) return;

    try {
      final newSubject = {
        'name': name,
        'color': colorHex,
        'user_id': currentUserId,
      };
      await _client.from('subjects').insert(newSubject);
      await fetchSubjects(); // Refresh local cache
    } catch (e) {
      if (kDebugMode) print('Error creating subject: $e');
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    if (!isConfigured) return;

    try {
      await _client.from('subjects').delete().eq('id', id);
      await fetchSubjects(); // Refresh
      await fetchTasks(); // Refresh tasks too, since cascade might set null
    } catch (e) {
      if (kDebugMode) print('Error deleting subject: $e');
      rethrow;
    }
  }

  // ================= TASKS CRUD =================
  Future<void> fetchTasks() async {
    if (!isConfigured) return;

    _setLoading(true);
    try {
      final response = await _client
          .from('tasks')
          .select('*, subjects(*)')
          .order('deadline', ascending: true);

      _tasks = (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching tasks: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTask({
    required String title,
    String? description,
    DateTime? deadline,
    required String priority,
    String? subjectId,
  }) async {
    if (!isConfigured) return;

    try {
      final newTask = {
        'title': title,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'priority': priority,
        'is_completed': false,
        'subject_id': subjectId,
        'user_id': currentUserId,
      };
      await _client.from('tasks').insert(newTask);
      await fetchTasks();
    } catch (e) {
      if (kDebugMode) print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
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
          title: t.title,
          description: t.description,
          deadline: t.deadline,
          priority: t.priority,
          isCompleted: isCompleted,
          subjectId: t.subjectId,
          userId: t.userId,
          createdAt: t.createdAt,
          subject: t.subject,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error toggling task completion: $e');
      rethrow;
    }
  }

  Future<void> updateTask({
    required String id,
    required String title,
    String? description,
    DateTime? deadline,
    required String priority,
    String? subjectId,
  }) async {
    if (!isConfigured) return;

    try {
      await _client.from('tasks').update({
        'title': title,
        'description': description,
        'deadline': deadline?.toIso8601String(),
        'priority': priority,
        'subject_id': subjectId,
      }).eq('id', id);
      await fetchTasks();
    } catch (e) {
      if (kDebugMode) print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
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

  // ================= SCHEDULES CRUD =================
  Future<void> fetchSchedules() async {
    if (!isConfigured) return;

    _setLoading(true);
    try {
      final response = await _client
          .from('schedules')
          .select('*, subjects(*)')
          .order('start_time', ascending: true);

      _schedules =
          (response as List).map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) print('Error fetching schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createSchedule({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    int? dayOfWeek,
    String? location,
    String? subjectId,
  }) async {
    if (!isConfigured) return;

    try {
      final newSchedule = {
        'title': title,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'day_of_week': dayOfWeek,
        'location': location,
        'subject_id': subjectId,
        'user_id': currentUserId,
      };
      await _client.from('schedules').insert(newSchedule);
      await fetchSchedules();
    } catch (e) {
      if (kDebugMode) print('Error creating schedule: $e');
      rethrow;
    }
  }

  Future<void> deleteSchedule(String id) async {
    if (!isConfigured) return;

    try {
      await _client.from('schedules').delete().eq('id', id);
      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error deleting schedule: $e');
      rethrow;
    }
  }

  // ================= RPC DASHBOARD FUNCTION =================
  Future<Map<String, dynamic>?> fetchDashboardSummary() async {
    if (!isConfigured || currentUserId == null) return null;
    try {
      final response = await _client.rpc(
        'get_dashboard_summary',
        params: {'p_user_id': currentUserId},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('Error calling RPC get_dashboard_summary: $e');
      return null;
    }
  }
}
