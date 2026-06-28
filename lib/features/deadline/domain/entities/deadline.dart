enum DeadlineSource { canvas, outlook, gmail, manual }

enum PriorityLevel { low, medium, high }

enum RiskLevel { low, medium, high, extreme }

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

  // Các trường bổ sung cho AI (Của Toàn)
  final RiskLevel riskLevel;
  final String? aiSuggestion;
  final String? emailId;

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
    RiskLevel? riskLevel,
    this.aiSuggestion,
    this.emailId,
  }) : updatedAt = updatedAt ?? createdAt,
       riskLevel = riskLevel ?? RiskLevel.low;

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
    RiskLevel? riskLevel,
    String? aiSuggestion,
    String? emailId,
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
      riskLevel: riskLevel ?? this.riskLevel,
      aiSuggestion: aiSuggestion ?? this.aiSuggestion,
      emailId: emailId ?? this.emailId,
    );
  }
}
