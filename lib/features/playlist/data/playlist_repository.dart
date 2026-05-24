import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistRepository {
  PlaylistRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _playlistRef(String uid) {
    return _db.collection('users').doc(uid).collection('playlist');
  }

  Stream<Set<String>> watchFavoriteSongIds(String uid) {
    return _playlistRef(uid).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => (doc.data()['songId'] ?? doc.id).toString())
          .where((id) => id.isNotEmpty)
          .toSet();
    });
  }

  Future<void> setFavorite({
    required String uid,
    required String songId,
    required bool isFavorite,
  }) async {
    final ref = _playlistRef(uid).doc(songId);
    if (isFavorite) {
      await ref.set(<String, dynamic>{
        'songId': songId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  Future<void> toggleFavorite({
    required String uid,
    required String songId,
  }) async {
    final ref = _playlistRef(uid).doc(songId);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set(<String, dynamic>{
        'songId': songId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
