import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistFavorite {
  final String songId;
  final Timestamp? addedAt;

  const PlaylistFavorite({
    required this.songId,
    this.addedAt,
  });

  factory PlaylistFavorite.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return PlaylistFavorite(
      songId: (data['songId'] ?? doc.id).toString(),
      addedAt: data['addedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'songId': songId,
      'addedAt': addedAt,
    };
  }
}
