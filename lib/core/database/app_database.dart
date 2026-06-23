import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const databaseName = 'deadline_sync.db';
  static const databaseVersion = 2;

  static const deadlinesTable = 'deadlines';
  static const processedEmailsTable = 'processed_emails';
  static const tasksTable = 'tasks';

  Database? _database;

  Future<Database> get database async {
    final existingDatabase = _database;
    if (existingDatabase != null) {
      return existingDatabase;
    }

    final databasePath = await getDatabasesPath();
    final fullPath = path.join(databasePath, databaseName);

    final openedDatabase = await openDatabase(
      fullPath,
      version: databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _database = openedDatabase;
    return openedDatabase;
  }

  Future<void> close() async {
    final existingDatabase = _database;
    if (existingDatabase != null) {
      await existingDatabase.close();
      _database = null;
    }
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute(_createDeadlinesTableSql);
    await database.execute(_createTasksTableSql);
    await database.execute(_createProcessedEmailsTableSql);
    await database.execute(_createDeadlinesDueDateIndexSql);
    await database.execute(_createDeadlinesSyncStatusIndexSql);
    await database.execute(_createDeadlinesEmailIdIndexSql);
    await database.execute(_createTasksDueDateIndexSql);
    await database.execute(_createTasksSyncStatusIndexSql);
  }

  Future<void> _onUpgrade(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await database.execute(
        "ALTER TABLE $deadlinesTable ADD COLUMN risk_level TEXT NOT NULL DEFAULT 'low'",
      );
      await database.execute(
        'ALTER TABLE $deadlinesTable ADD COLUMN ai_suggestion TEXT',
      );
      await database.execute(
        'ALTER TABLE $deadlinesTable ADD COLUMN email_id TEXT',
      );
      await database.execute(_createProcessedEmailsTableSql);
      await database.execute(_createDeadlinesEmailIdIndexSql);
    }
  }

  static const _createDeadlinesTableSql =
      '''
CREATE TABLE $deadlinesTable (
  id TEXT PRIMARY KEY,
  remote_id TEXT,
  title TEXT NOT NULL,
  due_date INTEGER,
  description TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL,
  priority TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  sync_status TEXT NOT NULL,
  risk_level TEXT NOT NULL DEFAULT 'low',
  ai_suggestion TEXT,
  email_id TEXT
)
''';

  static const _createProcessedEmailsTableSql =
      '''
CREATE TABLE $processedEmailsTable (
  email_id TEXT PRIMARY KEY,
  processed_at INTEGER NOT NULL
)
''';

  static const _createTasksTableSql =
      '''
CREATE TABLE $tasksTable (
  id TEXT PRIMARY KEY,
  remote_id TEXT,
  title TEXT NOT NULL,
  due_date INTEGER,
  notes TEXT,
  is_completed INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  sync_status TEXT NOT NULL
)
''';

  static const _createDeadlinesDueDateIndexSql =
      'CREATE INDEX idx_deadlines_due_date ON $deadlinesTable(due_date)';

  static const _createDeadlinesSyncStatusIndexSql =
      'CREATE INDEX idx_deadlines_sync_status ON $deadlinesTable(sync_status)';

  static const _createDeadlinesEmailIdIndexSql =
      'CREATE INDEX idx_deadlines_email_id ON $deadlinesTable(email_id)';

  static const _createTasksDueDateIndexSql =
      'CREATE INDEX idx_tasks_due_date ON $tasksTable(due_date)';

  static const _createTasksSyncStatusIndexSql =
      'CREATE INDEX idx_tasks_sync_status ON $tasksTable(sync_status)';
}
