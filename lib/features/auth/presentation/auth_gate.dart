import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';

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

        return const DashboardScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Auth error: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
