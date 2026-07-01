import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../notification/data/providers/local_notification_providers.dart';
import '../datasources/deadline_firestore_data_source.dart';
import '../datasources/deadline_local_data_source.dart';
import '../repositories/deadline_repository.dart';
import '../services/offline_sync_service.dart';

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

final deadlineFirestoreDataSourceProvider =
    Provider<DeadlineFirestoreDataSource?>((ref) {
      if (Firebase.apps.isEmpty) {
        return null;
      }

      return DeadlineFirestoreDataSource(FirebaseFirestore.instance);
    });

final deadlineRepositoryProvider = Provider<DeadlineRepository>((ref) {
  return DeadlineRepository(
    authRepository: ref.watch(authRepositoryProvider),
    localDataSource: ref.watch(deadlineLocalDataSourceProvider),
    firestoreDataSource: ref.watch(deadlineFirestoreDataSourceProvider),
    notificationService: ref.watch(localNotificationServiceProvider),
  );
});

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService(
    authRepository: ref.watch(authRepositoryProvider),
    localDataSource: ref.watch(deadlineLocalDataSourceProvider),
    firestoreDataSource: ref.watch(deadlineFirestoreDataSourceProvider),
    connectivity: Connectivity(),
  );

  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});
