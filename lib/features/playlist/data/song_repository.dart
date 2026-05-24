import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appantibloqueo/features/playlist/domain/song_item.dart';

class SongRepository {
  SongRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _songs =>
      _db.collection('songs');

  Stream<List<SongItem>> watchSongs() {
    return _songs.orderBy('titulo').snapshots().map((snapshot) =>
        snapshot.docs.map(SongItem.fromDoc).toList(growable: false));
  }

  Future<void> addSong({
    required String titulo,
    required String artista,
    required String coverUrl,
    required String audioUrl,
    required List<String> tags,
  }) {
    return _songs.add(<String, dynamic>{
      'titulo': titulo.trim(),
      'artista': artista.trim(),
      'coverUrl': coverUrl.trim(),
      'audioUrl': audioUrl.trim(),
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSong({
    required String songId,
    required String titulo,
    required String artista,
    required String coverUrl,
    required String audioUrl,
    required List<String> tags,
  }) {
    return _songs.doc(songId).update(<String, dynamic>{
      'titulo': titulo.trim(),
      'artista': artista.trim(),
      'coverUrl': coverUrl.trim(),
      'audioUrl': audioUrl.trim(),
      'tags': tags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSong(String songId) => _songs.doc(songId).delete();

  Future<void> upsertByAudioUrl({
    required String titulo,
    required String artista,
    required String coverUrl,
    required String audioUrl,
    required List<String> tags,
  }) async {
    final existing = await _songs
        .where('audioUrl', isEqualTo: audioUrl.trim())
        .limit(1)
        .get();
    if (existing.docs.isEmpty) {
      await addSong(
        titulo: titulo,
        artista: artista,
        coverUrl: coverUrl,
        audioUrl: audioUrl,
        tags: tags,
      );
      return;
    }

    await updateSong(
      songId: existing.docs.first.id,
      titulo: titulo,
      artista: artista,
      coverUrl: coverUrl,
      audioUrl: audioUrl,
      tags: tags,
    );
  }
}
