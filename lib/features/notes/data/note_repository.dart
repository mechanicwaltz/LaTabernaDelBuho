import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appantibloqueo/features/notes/domain/app_note.dart';

class NoteRepository {
  NoteRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _notesRef(String uid) {
    return _db.collection('users').doc(uid).collection('notes');
  }

  Stream<List<AppNote>> watchNotes(String uid) {
    return _notesRef(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(AppNote.fromDoc).toList(growable: false));
  }

  Future<void> addNote({
    required String uid,
    required String tipo,
    required String titulo,
    required String contenido,
  }) {
    return _notesRef(uid).add(<String, dynamic>{
      'tipo': tipo,
      'titulo': titulo,
      'contenido': contenido,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote({
    required String uid,
    required String noteId,
    required String titulo,
    required String contenido,
  }) {
    return _notesRef(uid).doc(noteId).update(<String, dynamic>{
      'titulo': titulo,
      'contenido': contenido,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote({
    required String uid,
    required String noteId,
  }) {
    return _notesRef(uid).doc(noteId).delete();
  }
}
