enum DeadlineSource { canvas, outlook, manual }

enum PriorityLevel { low, medium, high }

class Deadline {
  final String id; // ID duy nhất (từ Outlook hoặc UUID tự tạo)
  final String title; // Tiêu đề deadline
  final DateTime? dueDate; // Ngày hết hạn
  final String? description; // Mô tả chi tiết
  final bool isCompleted; // Trạng thái hoàn thành
  final DeadlineSource source; // Nguồn: Outlook hay Thủ công
  final PriorityLevel priority; // Mức độ ưu tiên
  final DateTime createdAt; // Ngày tạo

  Deadline({
    required this.id,
    required this.title,
    this.dueDate,
    this.description,
    this.isCompleted = false,
    required this.source,
    this.priority = PriorityLevel.medium,
    required this.createdAt,
  });

  // Helper để tạo bản sao với thay đổi (Dùng cho State Management của Thành viên B)
  Deadline copyWith({
    String? title,
    DateTime? dueDate,
    String? description,
    bool? isCompleted,
    PriorityLevel? priority,
  }) {
    return Deadline(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      source: source,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }
}
