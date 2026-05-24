import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  AdminRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _adminEmails =>
      _db.collection('admin_emails');

  Stream<bool> watchIsAdminEmail(String? email) {
    final normalized = (email ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return Stream<bool>.value(false);
    }
    return _adminEmails.doc(normalized).snapshots().map((doc) {
      final data = doc.data();
      return doc.exists && data != null && data['enabled'] == true;
    });
  }

  Stream<Set<String>> watchEnabledAdminEmails() {
    return _adminEmails.where('enabled', isEqualTo: true).snapshots().map(
      (snapshot) {
        final emails = <String>{};
        for (final doc in snapshot.docs) {
          final email = doc.id.trim().toLowerCase();
          if (email.isNotEmpty) {
            emails.add(email);
          }
        }
        return emails;
      },
    );
  }

  Future<bool> isAdminEmail(String? email) async {
    final normalized = (email ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return false;
    final doc = await _adminEmails.doc(normalized).get();
    final data = doc.data();
    return doc.exists && data != null && data['enabled'] == true;
  }
}
