import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/deadline.dart';
import '../models/deadline_model.dart';

class DeadlineLocalDataSource {
  DeadlineLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<DeadlineModel>> getAllDeadlines() async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      AppDatabase.deadlinesTable,
      where: 'sync_status != ?',
      whereArgs: ['pendingDelete'],
      orderBy: 'due_date IS NULL, due_date ASC, created_at DESC',
    );

    return rows.map(DeadlineModel.fromMap).toList();
  }

  Future<DeadlineModel?> getDeadlineById(String id) async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      AppDatabase.deadlinesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return DeadlineModel.fromMap(rows.first);
  }

  Future<List<DeadlineModel>> getPendingSyncDeadlines() async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      AppDatabase.deadlinesTable,
      where: 'sync_status != ?',
      whereArgs: ['synced'],
      orderBy: 'updated_at ASC',
    );

    return rows.map(DeadlineModel.fromMap).toList();
  }

  Future<void> upsertDeadline(DeadlineModel deadline) async {
    final database = await _appDatabase.database;
    await database.insert(
      AppDatabase.deadlinesTable,
      deadline.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertDeadlines(List<DeadlineModel> deadlines) async {
    final database = await _appDatabase.database;
    final batch = database.batch();

    for (final deadline in deadlines) {
      batch.insert(
        AppDatabase.deadlinesTable,
        deadline.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<bool> hasProcessedEmail(String emailId) async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      AppDatabase.processedEmailsTable,
      columns: ['email_id'],
      where: 'email_id = ?',
      whereArgs: [emailId],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<void> markEmailProcessed(String emailId) async {
    final database = await _appDatabase.database;
    await database.insert(
      AppDatabase.processedEmailsTable,
      {
        'email_id': emailId,
        'processed_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> markEmailsProcessed(Iterable<String> emailIds) async {
    final database = await _appDatabase.database;
    final batch = database.batch();
    final processedAt = DateTime.now().millisecondsSinceEpoch;

    for (final emailId in emailIds) {
      if (emailId.isEmpty) {
        continue;
      }

      batch.insert(
        AppDatabase.processedEmailsTable,
        {'email_id': emailId, 'processed_at': processedAt},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteDeadline(String id) async {
    final database = await _appDatabase.database;
    await database.delete(
      AppDatabase.deadlinesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markDeadlinePendingDelete(DeadlineModel deadline) async {
    await upsertDeadline(
      DeadlineModel.fromEntity(
        deadline.copyWith(
          syncStatus: SyncStatus.pendingDelete,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> clearDeadlines() async {
    final database = await _appDatabase.database;
    await database.delete(AppDatabase.deadlinesTable);
  }

  Future<void> clearProcessedEmails() async {
    final database = await _appDatabase.database;
    await database.delete(AppDatabase.processedEmailsTable);
  }
}
