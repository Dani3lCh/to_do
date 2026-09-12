enum Priority { low, medium, high }

class Todo {
  Todo({
    required this.id,
    required this.title,
    this.notes = '',
    this.done = false,
    this.priority = Priority.medium,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String title;
  String notes;
  bool done;
  Priority priority;
  final DateTime createdAt;

  Todo copyWith({
    String? title,
    String? notes,
    bool? done,
    Priority? priority,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      done: done ?? this.done,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'done': done,
        'priority': priority.index,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String? ?? '',
        done: json['done'] as bool? ?? false,
        priority: Priority.values[json['priority'] as int? ?? 1],
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );
}
