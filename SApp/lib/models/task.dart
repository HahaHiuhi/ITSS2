

enum Priority {
   Low,
   Medium,
   High,
 }
class Task {
  final int? id;
  final String name;
  final DateTime deadline;
  final Priority priority;
  final List<String>? tags;
  final String? description;
  final List<TaskProperty>? attributes;
  final bool isComplete;
  final List<TaskAttachment>? attachments;

  Task( {
    this.id,
    required this.name,
    required this.deadline,
    required this.priority,
    this.tags,
    this.description,
    this.attributes,
    this.isComplete = false,
    this.attachments,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'];

    final attributes = rawAttributes is List
        ? rawAttributes
        .map((e) =>
        TaskProperty.fromJson(
          Map<String, dynamic>.from(e),
        ))
        .toList()
        : <TaskProperty>[];

    return Task(
      id: json['id'] as int?,
      name: json['name'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: Priority.values.firstWhere(
            (e) =>
        e.name.toLowerCase() ==
            json['priority'].toString().toLowerCase(),
        orElse: () => Priority.Medium,
      ),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : null,
      description: json['description'] as String?,
      attributes: attributes,
      isComplete: json['is_completed'] as bool? ?? false,
      attachments: (json['attachments'] as List? ?? const [])
          .map(
            (e) =>
            TaskAttachment.fromJson(
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
      'deadline': deadline.toIso8601String(),
      'priority': priority.name,
      'tags': tags,
      'description': description,
      'attributes': attributes
          ?.map((attribute) => attribute.toJson())
          .toList(),
      'is_completed': isComplete,
      'attachments': attachments
          ?.map((attachment) => attachment.toJson())
          .toList(),
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

 class TaskProperty {
   final String name;
   final String value;

   TaskProperty({
     required this.name,
     required this.value,
   });

   factory TaskProperty.fromJson(
       Map<String, dynamic> json,
       ) {
     return TaskProperty(
       name: json['name'] ?? '',
       value: json['value'] ?? '',
     );
   }

   Map<String, dynamic> toJson() {
     return {
       'name': name,
       'value': value,
     };
   }
 }