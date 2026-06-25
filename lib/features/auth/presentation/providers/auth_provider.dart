import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/gmail_service.dart';
import '../../data/google_auth_service.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

final gmailServiceProvider = Provider<GmailService>((ref) {
  return GmailService();
});

final authStateProvider = StreamProvider<GoogleSignInAccount?>((ref) {
  final authService = ref.watch(googleAuthServiceProvider);
  // Kiểm tra đăng nhập thầm lặng ngay khi khởi tạo
  authService.signInSilently();
  return authService.onCurrentUserChanged;
});

final authControllerProvider = Provider<AuthController>((ref) {
  final authService = ref.watch(googleAuthServiceProvider);
  return AuthController(authService);
});

class AuthController {
  final GoogleAuthService _authService;
  AuthController(this._authService);

  Future<void> login() async {
    await _authService.signIn();
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
