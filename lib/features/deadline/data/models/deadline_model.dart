import '../../domain/entities/deadline.dart';

class DeadlineModel extends Deadline {
  DeadlineModel({
    required super.id,
    super.remoteId,
    required super.title,
    super.dueDate,
    super.description,
    super.isCompleted,
    required super.source,
    super.priority,
    required super.createdAt,
    super.updatedAt,
    super.syncStatus,
  });

  factory DeadlineModel.fromEntity(Deadline deadline) {
    return DeadlineModel(
      id: deadline.id,
      remoteId: deadline.remoteId,
      title: deadline.title,
      dueDate: deadline.dueDate,
      description: deadline.description,
      isCompleted: deadline.isCompleted,
      source: deadline.source,
      priority: deadline.priority,
      createdAt: deadline.createdAt,
      updatedAt: deadline.updatedAt,
      syncStatus: deadline.syncStatus,
    );
  }

  factory DeadlineModel.fromMap(Map<String, Object?> map) {
    return DeadlineModel(
      id: map['id'] as String,
      remoteId: map['remote_id'] as String?,
      title: map['title'] as String,
      dueDate: _dateTimeFromMilliseconds(map['due_date'] as int?),
      description: map['description'] as String?,
      isCompleted: (map['is_completed'] as int) == 1,
      source: DeadlineSource.values.byName(map['source'] as String),
      priority: PriorityLevel.values.byName(map['priority'] as String),
      createdAt: _dateTimeFromMilliseconds(map['created_at'] as int)!,
      updatedAt: _dateTimeFromMilliseconds(map['updated_at'] as int)!,
      syncStatus: SyncStatus.values.byName(map['sync_status'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'title': title,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'source': source.name,
      'priority': priority.name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus.name,
    };
  }

  static DateTime? _dateTimeFromMilliseconds(int? value) {
    if (value == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(value);
  }
}
