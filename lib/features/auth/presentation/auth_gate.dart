import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';
import 'providers/auth_provider.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _hasStarted = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          if (!_hasStarted) {
            return OnboardingScreen(
              onStart: () => setState(() => _hasStarted = true),
            );
          }

          return const LoginScreen();
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
