enum TaskPriority { bajo, medio, alto }

enum TaskStatus { pending, inProgress, completed }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime date;
  final TaskStatus status;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.date,
    required this.status,
    required this.createdAt,
  });

  TaskModel copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? date,
    TaskStatus? status,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
