import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/deadline_model.dart';

class DeadlineLocalDataSource {
  DeadlineLocalDataSource(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<DeadlineModel>> getAllDeadlines() async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      AppDatabase.deadlinesTable,
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

  Future<void> deleteDeadline(String id) async {
    final database = await _appDatabase.database;
    await database.delete(
      AppDatabase.deadlinesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDeadlines() async {
    final database = await _appDatabase.database;
    await database.delete(AppDatabase.deadlinesTable);
  }
}
