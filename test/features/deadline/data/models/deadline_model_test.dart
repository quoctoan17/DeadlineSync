import 'package:deadline_sync/features/deadline/data/models/deadline_model.dart';
import 'package:deadline_sync/features/deadline/domain/entities/deadline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DeadlineModel serializes to and from SQLite map', () {
    final createdAt = DateTime(2026, 6, 19, 9);
    final updatedAt = DateTime(2026, 6, 19, 10);
    final dueDate = DateTime(2026, 6, 20, 18, 30);

    final model = DeadlineModel(
      id: 'local-1',
      remoteId: 'remote-1',
      title: 'Submit project report',
      dueDate: dueDate,
      description: 'Final mobile app report',
      isCompleted: true,
      source: DeadlineSource.canvas,
      priority: PriorityLevel.high,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncStatus: SyncStatus.pendingUpdate,
      riskLevel: RiskLevel.high,
      aiSuggestion: 'Start this before the weekend.',
      emailId: 'gmail-123',
    );

    final restored = DeadlineModel.fromMap(model.toMap());

    expect(restored.id, 'local-1');
    expect(restored.remoteId, 'remote-1');
    expect(restored.title, 'Submit project report');
    expect(restored.dueDate, dueDate);
    expect(restored.description, 'Final mobile app report');
    expect(restored.isCompleted, isTrue);
    expect(restored.source, DeadlineSource.canvas);
    expect(restored.priority, PriorityLevel.high);
    expect(restored.createdAt, createdAt);
    expect(restored.updatedAt, updatedAt);
    expect(restored.syncStatus, SyncStatus.pendingUpdate);
    expect(restored.riskLevel, RiskLevel.high);
    expect(restored.aiSuggestion, 'Start this before the weekend.');
    expect(restored.emailId, 'gmail-123');
  });
}
