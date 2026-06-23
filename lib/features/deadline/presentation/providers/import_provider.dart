import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/deadline.dart';
import 'ai_provider.dart';

/// Provider quản lý danh sách deadline đang chờ xác nhận (Review list)
final pendingDeadlinesProvider = StateProvider<List<Deadline>>((ref) => []);

/// Provider quản lý trạng thái đang quét (Loading state)
final isImportingProvider = StateProvider<bool>((ref) => false);

final importControllerProvider = Provider<ImportController>((ref) {
  return ImportController(ref);
});

class ImportController {
  final Ref _ref;
  ImportController(this._ref);

  /// Luồng xử lý chính: Quét -> AI Lọc -> Trả về danh sách chờ lưu
  Future<void> runImportFlow(int days) async {
    final authService = _ref.read(googleAuthServiceProvider);
    final gmailService = _ref.read(gmailServiceProvider);
    final aiService = _ref.read(aiServiceProvider);
    
    // 1. Kiểm tra đăng nhập
    final account = authService.currentUser;
    if (account == null) {
      throw Exception("Người dùng chưa đăng nhập Google.");
    }

    try {
      _ref.read(isImportingProvider.notifier).state = true;
      _ref.read(pendingDeadlinesProvider.notifier).state = [];

      // 2. Fetch danh sách Email (Task 2 đã làm)
      final messages = await gmailService.fetchEmails(account, days);
      
      List<Deadline> extractedDeadlines = [];

      // 3. Lặp qua từng email và gửi cho AI
      for (var msg in messages) {
        // [TASK 8]: Chặn trùng lặp Email
        // Trong thực tế, bạn sẽ kiểm tra messageId này trong SQLite của Quân (C)
        // Nếu đã tồn tại thì bỏ qua email này.
        final emailId = msg.id ?? "";
        
        final content = msg.snippet ?? "";
        
        if (content.isNotEmpty) {
          final deadline = await aiService.extractDeadlineFromEmail(content, emailId);
          if (deadline != null) {
            extractedDeadlines.add(deadline);
          }
        }
      }

      // [TASK 6 & 7]: Sau khi import, chạy AI phân tích rủi ro cho toàn bộ danh sách mới
      final analyzedDeadlines = await aiService.analyzeOverallRisk(extractedDeadlines);

      // 4. Cập nhật danh sách chờ xác nhận
      _ref.read(pendingDeadlinesProvider.notifier).state = analyzedDeadlines;
      
    } finally {
      _ref.read(isImportingProvider.notifier).state = false;
    }
  }

  /// Hàm để người dùng xác nhận lưu các deadline đã chọn vào Database
  void confirmImport(List<Deadline> selectedDeadlines) {
    // Phần này sẽ gọi sang Service của Hoàng Quân (C) để lưu vào SQLite
    // Hiện tại chúng ta để trống để đợi Quân xong Database
  }
}
