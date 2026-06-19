import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/main_dashboard.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        return const MainDashboard();
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
