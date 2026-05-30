import 'subject.dart';

class Schedule {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final int? dayOfWeek; // 1 = Monday, 7 = Sunday
  final String? location;
  final String? subjectId;
  final String? userId;
  final DateTime createdAt;
  final Subject? subject; // Optional joined subject model

  Schedule({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.dayOfWeek,
    this.location,
    this.subjectId,
    this.userId,
    required this.createdAt,
    this.subject,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      dayOfWeek: json['day_of_week'] as int?,
      location: json['location'] as String?,
      subjectId: json['subject_id'] as String?,
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      subject: json['subjects'] != null ? Subject.fromJson(json['subjects'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'day_of_week': dayOfWeek,
      'location': location,
      'subject_id': subjectId,
    };
    if (userId != null) {
      data['user_id'] = userId;
    }
    return data;
  }
}
