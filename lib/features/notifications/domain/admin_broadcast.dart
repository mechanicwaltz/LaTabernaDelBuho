import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appantibloqueo/core/notifications/app_notification_target.dart';

class AdminBroadcast {
  const AdminBroadcast({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.createdByUid,
    required this.createdByEmail,
    this.createdAt,
    this.clientCreatedAt,
    this.scheduledFor,
  });

  final String id;
  final String title;
  final String body;
  final AppNotificationTarget target;
  final String createdByUid;
  final String createdByEmail;
  final Timestamp? createdAt;
  final Timestamp? clientCreatedAt;
  final Timestamp? scheduledFor;

  factory AdminBroadcast.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AdminBroadcast(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      body: (data['body'] ?? '').toString(),
      target: AppNotificationTargetX.tryParse(data['target']?.toString()) ??
          AppNotificationTarget.news,
      createdByUid: (data['createdByUid'] ?? '').toString(),
      createdByEmail: (data['createdByEmail'] ?? '').toString(),
      createdAt: data['createdAt'] as Timestamp?,
      clientCreatedAt: data['clientCreatedAt'] as Timestamp?,
      scheduledFor: data['scheduledFor'] as Timestamp?,
    );
  }
}
