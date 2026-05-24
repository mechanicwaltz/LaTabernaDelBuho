import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appantibloqueo/features/dnd/domain/character.dart';

class CharacterRepository {
  CharacterRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _charactersRef(String uid) {
    return _db.collection('users').doc(uid).collection('characters');
  }

  Stream<List<Character>> watchCharacters(String uid) {
    return _charactersRef(uid).orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final mapped = <String, dynamic>{...data, 'id': doc.id};
        return Character.fromJson(mapped);
      }).toList(growable: false);
    });
  }

  Future<List<Character>> loadCharacters(String uid) async {
    final snapshot = await _charactersRef(uid).orderBy('name').get();
    return snapshot.docs.map((doc) {
      final mapped = <String, dynamic>{...doc.data(), 'id': doc.id};
      return Character.fromJson(mapped);
    }).toList(growable: false);
  }

  Future<void> upsertCharacter({
    required String uid,
    required Character character,
  }) {
    final payload = character.toJson()
      ..['updatedAt'] = FieldValue.serverTimestamp();
    // Sobrescribimos el documento completo para evitar que mapas anidados
    // (p.ej. classLevels) con claves eliminadas se queden "fantasma".
    return _charactersRef(uid).doc(character.id).set(payload);
  }

  Future<void> deleteCharacter({
    required String uid,
    required String characterId,
  }) {
    return _charactersRef(uid).doc(characterId).delete();
  }
}
