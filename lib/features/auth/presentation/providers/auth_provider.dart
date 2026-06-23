import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/google_auth_service.dart';

import '../../data/gmail_service.dart';

/// Provider cung cấp instance của GoogleAuthService
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

/// Provider cung cấp instance của GmailService
final gmailServiceProvider = Provider<GmailService>((ref) {
  return GmailService();
});

/// StreamProvider lắng nghe trạng thái đăng nhập của người dùng.
/// UI có thể dùng ref.watch(authStateProvider) để biết User đã log in hay chưa.
final authStateProvider = StreamProvider<GoogleSignInAccount?>((ref) {
  final authService = ref.watch(googleAuthServiceProvider);
  return authService.onCurrentUserChanged;
});

/// Provider cung cấp các phương thức hành động (login, logout)
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
