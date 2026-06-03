import '../models/task.dart';

final List<Map<String, dynamic>> mockJson = [
  {
    "id": 1,
    "name": "Quarterly strategy review session",
    "due_date": "2025-05-20T09:00:00",
    "priority": "high",
    "type": ["urgent", "work"],
    "description": "Review quarterly company strategy.",
    "attachments": [],
    "is_completed": false
  },
  {
    "id": 2,
    "name": "Finalize client proposal deck",
    "due_date": "2025-05-20T11:30:00",
    "priority": "medium",
    "type": ["work"],
    "description": "Complete proposal slides.",
    "attachments": [],
    "is_completed": false
  }
];

final List<Task> mockTasks =
mockJson.map((e) => Task.fromJson(e)).toList();