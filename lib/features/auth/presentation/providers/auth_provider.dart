import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/auth_repository.dart';
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
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authService, authRepository);
});

class AuthController {
  final GoogleAuthService _authService;
  final AuthRepository _authRepository;

  AuthController(this._authService, this._authRepository);

  Future<void> loginWithGoogle() async {
    await _authService.signIn();
  }

  Future<void> signIn({required String email, required String password}) async {
    await _authRepository.signIn(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _authRepository.signUp(email: email, password: password);
  }

  Future<void> logout() async {
    await _authService.signOut();
    await _authRepository.signOut();
  }
}
