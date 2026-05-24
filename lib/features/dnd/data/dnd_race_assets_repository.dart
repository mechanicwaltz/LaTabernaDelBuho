import 'package:cloud_firestore/cloud_firestore.dart';

class DndRaceAssetsRepository {
  DndRaceAssetsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _raceAssets =>
      _db.collection('dnd_races');

  Stream<Map<String, String>> watchRaceImageUrls() {
    return _raceAssets.snapshots().map((snapshot) {
      final urls = <String, String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final key = _normalizeKey((data['key'] ?? doc.id).toString());
        final imageUrl =
            ((data['imageUrl'] ?? data['imagenUrl'] ?? '').toString()).trim();
        if (key.isNotEmpty && imageUrl.isNotEmpty) {
          urls[key] = imageUrl;
        }
      }
      return urls;
    });
  }

  Future<void> refreshFromServer({int limit = 50}) async {
    await _raceAssets.limit(limit).get(const GetOptions(source: Source.server));
  }

  String _normalizeKey(String raw) {
    var value = raw.trim().toLowerCase();
    value = value
        .replaceAll('\u00e1', 'a')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00ed', 'i')
        .replaceAll('\u00f3', 'o')
        .replaceAll('\u00fa', 'u')
        .replaceAll('\u00fc', 'u')
        .replaceAll('\u00f1', 'n');
    return value.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
