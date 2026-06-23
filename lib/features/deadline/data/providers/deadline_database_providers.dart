import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../datasources/deadline_local_data_source.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final deadlineLocalDataSourceProvider = Provider<DeadlineLocalDataSource>((
  ref,
) {
  return DeadlineLocalDataSource(ref.watch(appDatabaseProvider));
});
