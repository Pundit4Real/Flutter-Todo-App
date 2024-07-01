class Task {
  final int id;
  final String title;
  final String? description;
  bool completed;
  final DateTime dueDate;
  final DateTime dateCreated;  // Added dateCreated field

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.dueDate,
    required this.dateCreated,  // Added dateCreated field
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
      dueDate: DateTime.parse(json['due_date']),
      dateCreated: DateTime.parse(json['date_created']),  // Added dateCreated parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'due_date': dueDate.toIso8601String(),
      // 'date_created': dateCreated.toIso8601String(),  // Removed from toJson
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    DateTime? dateCreated,  // Added dateCreated parameter
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      dateCreated: dateCreated ?? this.dateCreated,  // Updated dateCreated
    );
  }
}
