import '../../../auth/data/auth_repository.dart';
import '../../domain/entities/deadline.dart';
import '../datasources/deadline_firestore_data_source.dart';
import '../datasources/deadline_local_data_source.dart';
import '../models/deadline_model.dart';

class DeadlineRepository {
  DeadlineRepository({
    required AuthRepository authRepository,
    required DeadlineLocalDataSource localDataSource,
    required DeadlineFirestoreDataSource firestoreDataSource,
  }) : _authRepository = authRepository,
       _localDataSource = localDataSource,
       _firestoreDataSource = firestoreDataSource;

  final AuthRepository _authRepository;
  final DeadlineLocalDataSource _localDataSource;
  final DeadlineFirestoreDataSource _firestoreDataSource;

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

    final localPendingModels = deadlines
        .map((deadline) => DeadlineModel.fromEntity(deadline))
        .toList();
    await _localDataSource.upsertDeadlines(localPendingModels);

    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final syncedModels = deadlines
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
      final pendingModels = deadlines
          .map(
            (deadline) => DeadlineModel.fromEntity(
              deadline.copyWith(syncStatus: SyncStatus.pendingCreate),
            ),
          )
          .toList();
      await _localDataSource.upsertDeadlines(pendingModels);
    }
  }

  Future<void> deleteDeadline(String deadlineId) async {
    await _localDataSource.deleteDeadline(deadlineId);

    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    await _firestoreDataSource.deleteDeadline(
      userId: userId,
      deadlineId: deadlineId,
    );
  }

  String? get _currentUserId => _authRepository.currentUser?.uid;
}
