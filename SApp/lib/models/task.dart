

class Task {
  final int? id;
  final String name;
  final Duration t2c; // estimated duration
  final Duration timeCompleted; // completed minutes
  final DateTime deadline;
  final List<String>? tags;
  final String? description;
  final bool isComplete;
  final List<TaskAttachment>? attachments;

  Task({
    this.id,
    required this.name,
    required this.t2c,
    required this.timeCompleted,
    required this.deadline,
    this.tags,
    this.description,
    this.isComplete = false,
    this.attachments,
  });

  double get completionRate {
    if (t2c == Duration.zero) {
      return 0;
    }

    return timeCompleted.inMinutes / t2c.inMinutes;
  }

  bool get isUrgent {
    final now = DateTime.now();

    final isToday =
        deadline.year == now.year &&
            deadline.month == now.month &&
            deadline.day == now.day;

    return isToday && completionRate < 0.5;
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      name: json['name'] as String,
      t2c: Duration(minutes: json['time_to_complete'] ?? 0),
      timeCompleted: Duration(minutes: json['time_completed'] ?? 0),
      deadline: DateTime.parse(json['deadline'] as String),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      description: json['description'] as String?,
      isComplete: json['is_completed'] as bool? ?? false,
      attachments: (json['attachments'] as List? ?? const [])
          .map(
            (e) => TaskAttachment.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'time_to_complete': t2c,
      'time_completed': timeCompleted,
      'deadline': deadline.toIso8601String(),
      'tags': tags,
      'description': description,
      'is_completed': isComplete,
      'attachments':
      attachments?.map((e) => e.toJson()).toList(),
    };
  }
}

//TaskAttachment
 enum AttachmentType {
   image,
   file,
 }

 class TaskAttachment {
   final String name;
   final String? url;
   final AttachmentType type;

   TaskAttachment({
     required this.name,
     this.url,
     required this.type,
   });

   factory TaskAttachment.fromJson(
       Map<String, dynamic> json,
       ) {
     return TaskAttachment(
       name: json['name'] ?? '',
       url: json['url'],
       type: AttachmentType.values.firstWhere(
             (e) =>
         e.name ==
             (json['type'] ?? 'file').toString(),
         orElse: () => AttachmentType.file,
       ),
     );
   }

   Map<String, dynamic> toJson() {
     return {
       'name': name,
       'url': url,
       'type': type.name,
     };
   }
 }
