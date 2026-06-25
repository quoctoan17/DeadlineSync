// ignore_for_file: prefer_initializing_formals

import '../../../auth/data/auth_repository.dart';
import '../../../notification/data/services/local_notification_service.dart';
import '../../domain/entities/deadline.dart';
import '../datasources/deadline_firestore_data_source.dart';
import '../datasources/deadline_local_data_source.dart';
import '../models/deadline_model.dart';

class DeadlineRepository {
  DeadlineRepository({
    required AuthRepository authRepository,
    required DeadlineLocalDataSource localDataSource,
    required DeadlineFirestoreDataSource firestoreDataSource,
    required LocalNotificationService notificationService,
  }) : _authRepository = authRepository,
       _localDataSource = localDataSource,
       _firestoreDataSource = firestoreDataSource,
       _notificationService = notificationService;

  final AuthRepository _authRepository;
  final DeadlineLocalDataSource _localDataSource;
  final DeadlineFirestoreDataSource _firestoreDataSource;
  final LocalNotificationService _notificationService;

  Future<List<DeadlineModel>> getLocalDeadlines() {
    return _localDataSource.getAllDeadlines();
  }

  Stream<List<DeadlineModel>> watchCloudDeadlines() {
    final userId = _currentUserId;
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestoreDataSource.watchDeadlines(userId);
  }

  Future<void> saveDeadline(Deadline deadline) async {
    await saveDeadlines([deadline]);
  }

  Future<void> saveDeadlines(List<Deadline> deadlines) async {
    if (deadlines.isEmpty) {
      return;
    }

    final localPendingModels = <DeadlineModel>[];
    for (final deadline in deadlines) {
      localPendingModels.add(await _pendingModelForSave(deadline));
    }

    await _localDataSource.upsertDeadlines(localPendingModels);
    await _scheduleReminders(deadlines);

    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final syncedModels = localPendingModels
          .map(
            (deadline) => DeadlineModel.fromEntity(
              deadline.copyWith(syncStatus: SyncStatus.synced),
            ),
          )
          .toList();

      await _firestoreDataSource.upsertDeadlines(
        userId: userId,
        deadlines: syncedModels,
      );

      await _localDataSource.upsertDeadlines(syncedModels);
    } catch (_) {
      await _localDataSource.upsertDeadlines(localPendingModels);
    }
  }

  Future<void> deleteDeadline(String deadlineId) async {
    final existingDeadline = await _localDataSource.getDeadlineById(deadlineId);
    await _notificationService.cancelDeadlineReminder(deadlineId);

    final userId = _currentUserId;
    if (userId == null || existingDeadline == null) {
      await _localDataSource.deleteDeadline(deadlineId);
      return;
    }

    try {
      await _firestoreDataSource.deleteDeadline(
        userId: userId,
        deadlineId: existingDeadline.remoteId ?? existingDeadline.id,
      );
      await _localDataSource.deleteDeadline(deadlineId);
    } catch (_) {
      await _localDataSource.markDeadlinePendingDelete(existingDeadline);
    }
  }

  Future<void> _scheduleReminders(List<Deadline> deadlines) async {
    for (final deadline in deadlines) {
      await _notificationService.scheduleDeadlineReminder(deadline);
    }
  }

  Future<DeadlineModel> _pendingModelForSave(Deadline deadline) async {
    final existingDeadline = await _localDataSource.getDeadlineById(
      deadline.id,
    );
    final shouldCreate =
        existingDeadline?.syncStatus == SyncStatus.pendingCreate ||
        (existingDeadline == null && deadline.remoteId == null);

    return DeadlineModel.fromEntity(
      deadline.copyWith(
        syncStatus: shouldCreate
            ? SyncStatus.pendingCreate
            : SyncStatus.pendingUpdate,
      ),
    );
  }

  String? get _currentUserId => _authRepository.currentUser?.uid;
}
