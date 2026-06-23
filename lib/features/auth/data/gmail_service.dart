import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:logger/logger.dart';

class GmailService {
  final _logger = Logger();

  /// Hàm lấy danh sách Email trong khoảng thời gian xác định
  /// [days]: Số ngày gần nhất muốn quét (7 hoặc 30)
  Future<List<Message>> fetchEmails(GoogleSignInAccount account, int days) async {
    try {
      // 1. Khởi tạo authenticated client từ tài khoản Google đã đăng nhập
      final httpClient = await account.authenticatedClient();
      if (httpClient == null) return [];

      final gmailApi = GmailApi(httpClient);

      // 2. Tính toán mốc thời gian (Gmail dùng định dạng YYYY/MM/DD cho query)
      final afterDate = DateTime.now().subtract(Duration(days: days));
      final dateQuery = "${afterDate.year}/${afterDate.month.toString().padLeft(2, '0')}/${afterDate.day.toString().padLeft(2, '0')}";

      // 3. Tạo câu truy vấn (Query) để lọc Email
      // after:YYYY/MM/DD -> Chỉ lấy mail sau ngày này
      // subject:(deadline OR assignment OR "hạn chót") -> Tìm các từ khóa liên quan
      final query = "after:$dateQuery subject:(deadline OR assignment OR \"hạn chót\" OR quiz OR \"bài tập\")";

      _logger.i("Đang quét Gmail với query: $query");

      // 4. Gọi API lấy danh sách Message IDs
      final ListMessagesResponse results = await gmailApi.users.messages.list(
        'me',
        q: query,
        maxResults: 20, // Giới hạn 20 mail gần nhất để tiết kiệm AI quota
      );

      if (results.messages == null || results.messages!.isEmpty) {
        _logger.i("Không tìm thấy email nào phù hợp.");
        return [];
      }

      // 5. Lấy nội dung chi tiết cho từng Message
      List<Message> fullMessages = [];
      for (var msg in results.messages!) {
        final fullMsg = await gmailApi.users.messages.get('me', msg.id!);
        fullMessages.add(fullMsg);
      }

      _logger.i("Đã lấy thành công ${fullMessages.length} email.");
      return fullMessages;
    } catch (e) {
      _logger.e("Lỗi khi fetch Gmail: $e");
      return [];
    }
  }
}
