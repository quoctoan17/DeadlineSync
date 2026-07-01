import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = Firebase.apps.isEmpty ? null : FirebaseAuth.instance;
  return AuthRepository(firebaseAuth);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

class AuthRepository {
  AuthRepository(this._firebaseAuth);

  final FirebaseAuth? _firebaseAuth;

  Stream<User?> authStateChanges() {
    return _firebaseAuth?.authStateChanges() ?? Stream.value(null);
  }

  User? get currentUser => _firebaseAuth?.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) {
      throw StateError('Firebase Auth is not initialized.');
    }

    return firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth == null) {
      throw StateError('Firebase Auth is not initialized.');
    }

    return firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() {
    return _firebaseAuth?.signOut() ?? Future.value();
  }
}
