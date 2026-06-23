import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:logger/logger.dart';

class GoogleAuthService {
  final _logger = Logger();

  static const _scopes = [
    GmailApi.gmailReadonlyScope,
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  // Stream để lắng nghe sự thay đổi của người dùng (Đăng nhập/Đăng xuất)
  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _googleSignIn.onCurrentUserChanged;

  // Hàm đăng nhập
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      _logger.e("Lỗi đăng nhập Google: $error");
      return null;
    }
  }

  // Hàm đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _logger.i("Đã đăng xuất thành công");
    } catch (error) {
      _logger.e("Lỗi khi đăng xuất: $error");
    }
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
