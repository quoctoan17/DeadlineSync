import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/screens/dashboard_screen.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';
import 'providers/auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuthState = ref.watch(authStateChangesProvider);
    final googleAuthState = ref.watch(authStateProvider);

    final firebaseUser = firebaseAuthState.valueOrNull;
    final googleUser = googleAuthState.valueOrNull;
    if (firebaseUser != null || googleUser != null) {
      return const DashboardScreen();
    }

    if (firebaseAuthState.isLoading || googleAuthState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authError = firebaseAuthState.error ?? googleAuthState.error;
    if (authError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Auth error: $authError', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return const LoginScreen();
  }
}
