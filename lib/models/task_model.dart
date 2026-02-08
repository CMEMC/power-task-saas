enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final String assignedUserId;
  final String organizationId;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.assignedUserId,
    required this.organizationId,
    required this.createdAt,
  });

  // Convert Firestore Data to Task Object
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      assignedUserId: map['assignedUserId'] ?? '',
      organizationId: map['organizationId'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'assignedUserId': assignedUserId,
      'organizationId': organizationId,
      'createdAt': createdAt,
    };
  }
}