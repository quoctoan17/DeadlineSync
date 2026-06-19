import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';

class MainDashboard extends ConsumerWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeadlineSync'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80),
              const SizedBox(height: 16),
              Text(
                'Signed in successfully',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email available',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'Firebase Authentication is ready. Next task: SQLite offline storage.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
