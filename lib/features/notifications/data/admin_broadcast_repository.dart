import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appantibloqueo/core/notifications/app_notification_target.dart';
import 'package:appantibloqueo/features/notifications/domain/admin_broadcast.dart';

class AdminBroadcastRepository {
  AdminBroadcastRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _broadcasts =>
      _db.collection('admin_broadcasts');

  Future<void> publish({
    required String title,
    required String body,
    required AppNotificationTarget target,
    required String createdByUid,
    required String createdByEmail,
    DateTime? scheduledFor,
  }) {
    return _broadcasts.add(<String, dynamic>{
      'title': title.trim(),
      'body': body.trim(),
      'target': target.key,
      'createdByUid': createdByUid,
      'createdByEmail': createdByEmail.trim().toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
      'clientCreatedAt': Timestamp.now(),
      'scheduledFor': scheduledFor == null
          ? null
          : Timestamp.fromDate(scheduledFor.toUtc()),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBroadcastsSince({
    required Timestamp since,
  }) {
    return _broadcasts
        .where('clientCreatedAt', isGreaterThan: since)
        .orderBy('clientCreatedAt', descending: false)
        .snapshots();
  }

  Stream<List<AdminBroadcast>> watchRecent({int limit = 20}) {
    return _broadcasts
        .orderBy('clientCreatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(AdminBroadcast.fromDoc).toList(growable: false);
    });
  }

  Future<List<AdminBroadcast>> fetchPendingScheduled({
    required DateTime fromUtc,
    int limit = 100,
  }) async {
    final snapshot = await _broadcasts
        .where(
          'scheduledFor',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromUtc.toUtc()),
        )
        .orderBy('scheduledFor', descending: false)
        .limit(limit)
        .get();

    return snapshot.docs.map(AdminBroadcast.fromDoc).toList(growable: false);
  }

  Future<void> deleteById(String id) {
    return _broadcasts.doc(id).delete();
  }
}
