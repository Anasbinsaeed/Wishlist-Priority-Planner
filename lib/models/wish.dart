enum WishStatus { active, completed, archived }

enum WishPriority { low, medium, high, critical }

class Wish {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final WishPriority priority;
  final WishStatus status;
  final DateTime createdAt;
  final DateTime? deadline;
  final String? imagePath;
  final String? notes;
  final List<String> tags;

  Wish({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.priority,
    this.status = WishStatus.active,
    required this.createdAt,
    this.deadline,
    this.imagePath,
    this.notes,
    this.tags = const [],
  });

  Wish copyWith({
    String? title,
    String? description,
    String? categoryId,
    WishPriority? priority,
    WishStatus? status,
    DateTime? deadline,
    String? imagePath,
    String? notes,
    List<String>? tags,
  }) {
    return Wish(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt,
      deadline: deadline ?? this.deadline,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'priority': priority.index,
      'status': status.index,
      'created_at': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'image_path': imagePath,
      'notes': notes,
      'tags': tags.join(','),
    };
  }

  factory Wish.fromMap(Map<String, dynamic> map) {
    return Wish(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      categoryId: map['category_id'],
      priority: WishPriority.values[map['priority']],
      status: WishStatus.values[map['status']],
      createdAt: DateTime.parse(map['created_at']),
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      imagePath: map['image_path'],
      notes: map['notes'],
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
    );
  }
}
