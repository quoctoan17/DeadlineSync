// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../auth/data/auth_repository.dart';
import '../../domain/entities/deadline.dart';
import '../datasources/deadline_firestore_data_source.dart';
import '../datasources/deadline_local_data_source.dart';
import '../models/deadline_model.dart';

class OfflineSyncService {
  OfflineSyncService({
    required AuthRepository authRepository,
    required DeadlineLocalDataSource localDataSource,
    required DeadlineFirestoreDataSource? firestoreDataSource,
    required Connectivity connectivity,
  }) : _authRepository = authRepository,
       _localDataSource = localDataSource,
       _firestoreDataSource = firestoreDataSource,
       _connectivity = connectivity;

  final AuthRepository _authRepository;
  final DeadlineLocalDataSource _localDataSource;
  final DeadlineFirestoreDataSource? _firestoreDataSource;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  Future<void> start() async {
    if (_firestoreDataSource == null) {
      return;
    }

    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (_hasConnection(results)) {
        unawaited(syncNow());
      }
    });

    final currentStatus = await _connectivity.checkConnectivity();
    if (_hasConnection(currentStatus)) {
      await syncNow();
    }
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<void> syncNow() async {
    final userId = _authRepository.currentUser?.uid;
    final firestoreDataSource = _firestoreDataSource;
    if (userId == null || firestoreDataSource == null || _isSyncing) {
      return;
    }

    _isSyncing = true;
    try {
      await _pushPendingLocalChanges(userId, firestoreDataSource);
      await _pullCloudChanges(userId, firestoreDataSource);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushPendingLocalChanges(
    String userId,
    DeadlineFirestoreDataSource firestoreDataSource,
  ) async {
    final pendingDeadlines = await _localDataSource.getPendingSyncDeadlines();

    for (final deadline in pendingDeadlines) {
      switch (deadline.syncStatus) {
        case SyncStatus.pendingCreate:
        case SyncStatus.pendingUpdate:
          final syncedDeadline = DeadlineModel.fromEntity(
            deadline.copyWith(syncStatus: SyncStatus.synced),
          );
          await firestoreDataSource.upsertDeadline(
            userId: userId,
            deadline: syncedDeadline,
          );
          await _localDataSource.upsertDeadline(syncedDeadline);
          break;
        case SyncStatus.pendingDelete:
          await firestoreDataSource.deleteDeadline(
            userId: userId,
            deadlineId: deadline.remoteId ?? deadline.id,
          );
          await _localDataSource.deleteDeadline(deadline.id);
          break;
        case SyncStatus.synced:
          break;
      }
    }
  }

  Future<void> _pullCloudChanges(
    String userId,
    DeadlineFirestoreDataSource firestoreDataSource,
  ) async {
    final cloudDeadlines = await firestoreDataSource.getDeadlines(userId);

    for (final cloudDeadline in cloudDeadlines) {
      final localDeadline = await _localDataSource.getDeadlineById(
        cloudDeadline.id,
      );

      if (localDeadline == null) {
        await _localDataSource.upsertDeadline(
          DeadlineModel.fromEntity(
            cloudDeadline.copyWith(syncStatus: SyncStatus.synced),
          ),
        );
        continue;
      }

      if (localDeadline.syncStatus != SyncStatus.synced) {
        continue;
      }

      final cloudWins = cloudDeadline.updatedAt.isAfter(
        localDeadline.updatedAt,
      );
      if (cloudWins) {
        await _localDataSource.upsertDeadline(
          _mergeCloudWithLocalAiFields(
            cloudDeadline: cloudDeadline,
            localDeadline: localDeadline,
          ),
        );
      }
    }
  }

  DeadlineModel _mergeCloudWithLocalAiFields({
    required DeadlineModel cloudDeadline,
    required DeadlineModel localDeadline,
  }) {
    final localSuggestion = localDeadline.aiSuggestion?.trim();
    final shouldKeepLocalSuggestion =
        localSuggestion != null && localSuggestion.isNotEmpty;
    final shouldKeepLocalRisk =
        localDeadline.riskLevel != RiskLevel.low ||
        cloudDeadline.riskLevel == RiskLevel.low;

    return DeadlineModel.fromEntity(
      cloudDeadline.copyWith(
        syncStatus: SyncStatus.synced,
        riskLevel: shouldKeepLocalRisk
            ? localDeadline.riskLevel
            : cloudDeadline.riskLevel,
        aiSuggestion: shouldKeepLocalSuggestion
            ? localDeadline.aiSuggestion
            : cloudDeadline.aiSuggestion,
      ),
    );
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
