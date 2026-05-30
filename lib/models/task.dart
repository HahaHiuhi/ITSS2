import 'subject.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final String priority; // 'LOW', 'MEDIUM', 'HIGH'
  final bool isCompleted;
  final String? subjectId;
  final String? userId;
  final DateTime createdAt;
  final Subject? subject; // Optional joined subject model

  Task({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    required this.priority,
    required this.isCompleted,
    this.subjectId,
    this.userId,
    required this.createdAt,
    this.subject,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      priority: json['priority'] as String? ?? 'MEDIUM',
      isCompleted: json['is_completed'] as bool? ?? false,
      subjectId: json['subject_id'] as String?,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      subject: json['subjects'] != null ? Subject.fromJson(json['subjects'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'is_completed': isCompleted,
      'subject_id': subjectId,
    };
    if (userId != null) {
      data['user_id'] = userId;
    }
    return data;
  }
}
