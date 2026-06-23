import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class GmailService {
  final _logger = Logger();

  /// Hàm lấy danh sách Email trong khoảng thời gian xác định
  Future<List<Message>> fetchEmails(GoogleSignInAccount account, int days) async {
    try {
      // 1. Lấy Auth Headers chứa Access Token
      final authHeaders = await account.authHeaders;
      final httpClient = GoogleAuthClient(authHeaders);

      final gmailApi = GmailApi(httpClient);

      // 2. Tính toán mốc thời gian
      final afterDate = DateTime.now().subtract(Duration(days: days));
      final dateQuery = "${afterDate.year}/${afterDate.month.toString().padLeft(2, '0')}/${afterDate.day.toString().padLeft(2, '0')}";

      final query = "after:$dateQuery subject:(deadline OR assignment OR \"hạn chót\" OR quiz OR \"bài tập\")";

      _logger.i("Đang quét Gmail với query: $query");

      final ListMessagesResponse results = await gmailApi.users.messages.list(
        'me',
        q: query,
        maxResults: 20,
      );

      if (results.messages == null || results.messages!.isEmpty) {
        _logger.i("Không tìm thấy email nào phù hợp.");
        return [];
      }

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

/// Helper class để đính kèm Google Auth Headers vào mọi request
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
