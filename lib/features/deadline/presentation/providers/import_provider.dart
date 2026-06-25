import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/providers/deadline_database_providers.dart';
import '../../domain/entities/deadline.dart';
import 'ai_provider.dart';

final pendingDeadlinesProvider = StateProvider<List<Deadline>>((ref) => []);

final isImportingProvider = StateProvider<bool>((ref) => false);

final importControllerProvider = Provider<ImportController>((ref) {
  return ImportController(ref);
});

class ImportController {
  ImportController(this._ref);

  final Ref _ref;

  Future<void> runImportFlow(int days) async {
    final authService = _ref.read(googleAuthServiceProvider);
    final gmailService = _ref.read(gmailServiceProvider);
    final aiService = _ref.read(aiServiceProvider);
    final localDataSource = _ref.read(deadlineLocalDataSourceProvider);

    final account = authService.currentUser;
    if (account == null) {
      throw Exception('Google account is not connected.');
    }

    try {
      _ref.read(isImportingProvider.notifier).state = true;
      _ref.read(pendingDeadlinesProvider.notifier).state = [];

      final messages = await gmailService.fetchEmails(account, days);
      final extractedDeadlines = <Deadline>[];

      for (final message in messages) {
        final emailId = message.id ?? '';
        if (emailId.isEmpty ||
            await localDataSource.hasProcessedEmail(emailId)) {
          continue;
        }

        final content = message.snippet ?? '';
        if (content.isEmpty) {
          await localDataSource.markEmailProcessed(emailId);
          continue;
        }

        final deadline = await aiService.extractDeadlineFromEmail(
          content,
          emailId,
        );

        if (deadline != null) {
          extractedDeadlines.add(deadline);
        } else {
          await localDataSource.markEmailProcessed(emailId);
        }
      }

      final analyzedDeadlines = await aiService.analyzeOverallRisk(
        extractedDeadlines,
      );
      _ref.read(pendingDeadlinesProvider.notifier).state = analyzedDeadlines;
    } finally {
      _ref.read(isImportingProvider.notifier).state = false;
    }
  }

  Future<void> confirmImport(List<Deadline> selectedDeadlines) async {
    final deadlineRepository = _ref.read(deadlineRepositoryProvider);
    final localDataSource = _ref.read(deadlineLocalDataSourceProvider);
    final pendingDeadlines = _ref.read(pendingDeadlinesProvider);

    await deadlineRepository.saveDeadlines(selectedDeadlines);
    await localDataSource.markEmailsProcessed({
      ...pendingDeadlines
          .map((deadline) => deadline.emailId)
          .whereType<String>(),
      ...selectedDeadlines
          .map((deadline) => deadline.emailId)
          .whereType<String>(),
    });

    _ref.read(pendingDeadlinesProvider.notifier).state = [];
  }
}
