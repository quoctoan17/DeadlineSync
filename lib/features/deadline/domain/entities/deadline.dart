enum DeadlineSource { outlook, gmail, manual }

enum PriorityLevel { low, medium, high }

enum RiskLevel { low, medium, high, extreme }

class Deadline {
  final String id;
  final String title;
  final DateTime? dueDate;
  final String? description;
  final bool isCompleted;
  final DeadlineSource source;
  final PriorityLevel priority;
  final DateTime createdAt;
  
  // Các trường bổ sung cho AI
  final RiskLevel riskLevel;    // Mức độ rủi ro AI đánh giá
  final String? aiSuggestion;   // Lời khuyên cụ thể từ AI
  final String? emailId;        // Lưu ID email gốc để chặn trùng lặp

  Deadline({
    required this.id,
    required this.title,
    this.dueDate,
    this.description,
    this.isCompleted = false,
    required this.source,
    this.priority = PriorityLevel.medium,
    required this.createdAt,
    this.riskLevel = RiskLevel.low,
    this.aiSuggestion,
    this.emailId,
  });

  Deadline copyWith({
    String? title,
    DateTime? dueDate,
    String? description,
    bool? isCompleted,
    PriorityLevel? priority,
    RiskLevel? riskLevel,
    String? aiSuggestion,
  }) {
    return Deadline(
      id: this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      source: this.source,
      priority: priority ?? this.priority,
      createdAt: this.createdAt,
      riskLevel: riskLevel ?? this.riskLevel,
      aiSuggestion: aiSuggestion ?? this.aiSuggestion,
      emailId: this.emailId,
    );
  }
}
