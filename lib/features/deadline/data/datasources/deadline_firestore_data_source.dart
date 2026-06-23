import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/deadline.dart';
import '../models/deadline_model.dart';

class DeadlineFirestoreDataSource {
  DeadlineFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _deadlinesCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('deadlines');
  }

  Stream<List<DeadlineModel>> watchDeadlines(String userId) {
    return _deadlinesCollection(userId)
        .orderBy('due_date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DeadlineFirestoreMapper.fromFirestore(doc))
              .toList(),
        );
  }

  Future<List<DeadlineModel>> getDeadlines(String userId) async {
    final snapshot = await _deadlinesCollection(userId)
        .orderBy('due_date')
        .get();

    return snapshot.docs
        .map((doc) => DeadlineFirestoreMapper.fromFirestore(doc))
        .toList();
  }

  Future<void> upsertDeadline({
    required String userId,
    required DeadlineModel deadline,
  }) {
    return _deadlinesCollection(userId)
        .doc(deadline.remoteId ?? deadline.id)
        .set(
          DeadlineFirestoreMapper.toFirestore(deadline),
          SetOptions(merge: true),
        );
  }

  Future<void> upsertDeadlines({
    required String userId,
    required List<DeadlineModel> deadlines,
  }) async {
    final batch = _firestore.batch();
    final collection = _deadlinesCollection(userId);

    for (final deadline in deadlines) {
      batch.set(
        collection.doc(deadline.remoteId ?? deadline.id),
        DeadlineFirestoreMapper.toFirestore(deadline),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  Future<void> deleteDeadline({
    required String userId,
    required String deadlineId,
  }) {
    return _deadlinesCollection(userId).doc(deadlineId).delete();
  }
}

class DeadlineFirestoreMapper {
  const DeadlineFirestoreMapper._();

  static Map<String, Object?> toFirestore(Deadline deadline) {
    return {
      'id': deadline.id,
      'remote_id': deadline.remoteId,
      'title': deadline.title,
      'due_date': _timestampFromDateTime(deadline.dueDate),
      'description': deadline.description,
      'is_completed': deadline.isCompleted,
      'source': deadline.source.name,
      'priority': deadline.priority.name,
      'created_at': _timestampFromDateTime(deadline.createdAt),
      'updated_at': _timestampFromDateTime(deadline.updatedAt),
      'sync_status': deadline.syncStatus.name,
      'risk_level': deadline.riskLevel.name,
      'ai_suggestion': deadline.aiSuggestion,
      'email_id': deadline.emailId,
    };
  }

  static DeadlineModel fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return DeadlineModel(
      id: data['id'] as String? ?? doc.id,
      remoteId: data['remote_id'] as String? ?? doc.id,
      title: data['title'] as String? ?? 'Untitled deadline',
      dueDate: _dateTimeFromTimestamp(data['due_date']),
      description: data['description'] as String?,
      isCompleted: data['is_completed'] as bool? ?? false,
      source: _enumByName(
        DeadlineSource.values,
        data['source'] as String?,
        DeadlineSource.manual,
      ),
      priority: _enumByName(
        PriorityLevel.values,
        data['priority'] as String?,
        PriorityLevel.medium,
      ),
      createdAt:
          _dateTimeFromTimestamp(data['created_at']) ?? DateTime.now(),
      updatedAt:
          _dateTimeFromTimestamp(data['updated_at']) ?? DateTime.now(),
      syncStatus: _enumByName(
        SyncStatus.values,
        data['sync_status'] as String?,
        SyncStatus.synced,
      ),
      riskLevel: _enumByName(
        RiskLevel.values,
        data['risk_level'] as String?,
        RiskLevel.low,
      ),
      aiSuggestion: data['ai_suggestion'] as String?,
      emailId: data['email_id'] as String?,
    );
  }

  static Timestamp? _timestampFromDateTime(DateTime? value) {
    return value == null ? null : Timestamp.fromDate(value);
  }

  static DateTime? _dateTimeFromTimestamp(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    if (name == null) {
      return fallback;
    }

    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }

    return fallback;
  }
}
