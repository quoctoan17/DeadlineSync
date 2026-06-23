enum DeadlineSource { canvas, outlook, manual }

enum PriorityLevel { low, medium, high }

enum SyncStatus { synced, pendingCreate, pendingUpdate, pendingDelete }

class Deadline {
  final String id;
  final String? remoteId;
  final String title;
  final DateTime? dueDate;
  final String? description;
  final bool isCompleted;
  final DeadlineSource source;
  final PriorityLevel priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  Deadline({
    required this.id,
    this.remoteId,
    required this.title,
    this.dueDate,
    this.description,
    this.isCompleted = false,
    required this.source,
    this.priority = PriorityLevel.medium,
    required this.createdAt,
    DateTime? updatedAt,
    this.syncStatus = SyncStatus.pendingCreate,
  }) : updatedAt = updatedAt ?? createdAt;

  Deadline copyWith({
    String? remoteId,
    String? title,
    DateTime? dueDate,
    String? description,
    bool? isCompleted,
    DeadlineSource? source,
    PriorityLevel? priority,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Deadline(
      id: id,
      remoteId: remoteId ?? this.remoteId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      source: source ?? this.source,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
