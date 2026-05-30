class Subject {
  final String id;
  final String name;
  final String color; // Hex code, e.g., '#3525CD'
  final String? userId;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    this.userId,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#3525CD',
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'color': color,
    };
    if (userId != null) {
      data['user_id'] = userId;
    }
    return data;
  }
}
