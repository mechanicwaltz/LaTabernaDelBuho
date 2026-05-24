import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appantibloqueo/features/profile/domain/app_user.dart';

class UsernameTakenException implements Exception {
  const UsernameTakenException();
}

class UserProfileNotFoundException implements Exception {
  const UserProfileNotFoundException();
}

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      _db.collection('usernames');
  CollectionReference<Map<String, dynamic>> get _recoveryStatus =>
      _db.collection('recovery_status');
  static const List<String> _ownedSubcollections = <String>[
    'notes',
    'characters',
    'playlist',
    'news_favorites',
    'fcmTokens',
  ];

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromDoc(doc);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Stream<List<AppUser>> watchAllUsers() {
    return _users.orderBy('usuarioLower').snapshots().map(
          (snapshot) =>
              snapshot.docs.map(AppUser.fromDoc).toList(growable: false),
        );
  }

  Future<bool> isUsernameAvailable(String usuario) async {
    final usernameLower = usuario.trim().toLowerCase();
    if (usernameLower.isEmpty) return false;
    final doc = await _usernames.doc(usernameLower).get();
    return !doc.exists;
  }

  Future<bool> isRecoveryBlockedByEmail(String correo) async {
    final emailLower = correo.trim().toLowerCase();
    if (emailLower.isEmpty) return false;
    final doc = await _recoveryStatus.doc(emailLower).get();
    final data = doc.data();
    if (!doc.exists || data == null) return false;
    return data['isActive'] == false;
  }

  Future<void> createUserProfileAndReserveUsername({
    required String uid,
    required String nombre,
    required String apellidos,
    required String correo,
    required String usuario,
  }) async {
    final usernameLower = usuario.trim().toLowerCase();
    final correoLower = correo.trim().toLowerCase();
    final userRef = _users.doc(uid);
    final usernameRef = _usernames.doc(usernameLower);
    final recoveryRef = _recoveryStatus.doc(correoLower);

    await _db.runTransaction((tx) async {
      final usernameSnap = await tx.get(usernameRef);
      if (usernameSnap.exists) {
        throw const UsernameTakenException();
      }

      tx.set(userRef, <String, dynamic>{
        'nombre': nombre.trim(),
        'apellidos': apellidos.trim(),
        'correo': correo.trim().toLowerCase(),
        'usuario': usuario.trim(),
        'usuarioLower': usernameLower,
        'fotoPerfilUrl': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(usernameRef, <String, dynamic>{
        'uid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(recoveryRef, <String, dynamic>{
        'uid': uid,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateOwnProfile({
    required String uid,
    required String nombre,
    required String apellidos,
    required String usuario,
  }) async {
    await _updateUserCore(
      uid: uid,
      nombre: nombre,
      apellidos: apellidos,
      usuario: usuario,
    );
  }

  Future<void> updateUserByAdmin({
    required String uid,
    required String nombre,
    required String apellidos,
    required String usuario,
  }) async {
    await _updateUserCore(
      uid: uid,
      nombre: nombre,
      apellidos: apellidos,
      usuario: usuario,
    );
  }

  Future<void> _updateUserCore({
    required String uid,
    required String nombre,
    required String apellidos,
    required String usuario,
  }) async {
    final nextUsernameLower = usuario.trim().toLowerCase();
    final userRef = _users.doc(uid);

    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      if (!userSnap.exists) {
        throw const UserProfileNotFoundException();
      }
      final data = userSnap.data() ?? const <String, dynamic>{};
      final currentUsernameLower =
          (data['usuarioLower'] ?? '').toString().trim().toLowerCase();

      if (currentUsernameLower != nextUsernameLower) {
        final newUsernameRef = _usernames.doc(nextUsernameLower);
        final newUsernameSnap = await tx.get(newUsernameRef);
        if (newUsernameSnap.exists) {
          final mappedUid = (newUsernameSnap.data()?['uid'] ?? '').toString();
          if (mappedUid != uid) {
            throw const UsernameTakenException();
          }
        }

        tx.set(newUsernameRef, <String, dynamic>{
          'uid': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (currentUsernameLower.isNotEmpty) {
          tx.delete(_usernames.doc(currentUsernameLower));
        }
      }

      tx.update(userRef, <String, dynamic>{
        'nombre': nombre.trim(),
        'apellidos': apellidos.trim(),
        'usuario': usuario.trim(),
        'usuarioLower': nextUsernameLower,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateProfilePhotoUrl({
    required String uid,
    required String downloadUrl,
  }) {
    return _users.doc(uid).update(<String, dynamic>{
      'fotoPerfilUrl': downloadUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserActive({
    required String uid,
    required bool isActive,
  }) async {
    final userRef = _users.doc(uid);

    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      if (!userSnap.exists) {
        throw const UserProfileNotFoundException();
      }

      final data = userSnap.data() ?? const <String, dynamic>{};
      final correoLower =
          (data['correo'] ?? '').toString().trim().toLowerCase();

      tx.update(userRef, <String, dynamic>{
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (correoLower.isNotEmpty) {
        tx.set(_recoveryStatus.doc(correoLower), <String, dynamic>{
          'uid': uid,
          'isActive': isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> deleteOwnAccountData({
    required String uid,
  }) async {
    // Reutiliza la misma limpieza completa del borrado por admin.
    await deleteUserProfileByAdmin(uid: uid);
  }

  Future<void> _deleteUserSubcollection({
    required String uid,
    required String subPath,
  }) async {
    final query = await _users.doc(uid).collection(subPath).get();
    if (query.docs.isEmpty) return;

    var batch = _db.batch();
    var pending = 0;

    for (final doc in query.docs) {
      batch.delete(doc.reference);
      pending += 1;

      // Evita llegar al límite de 500 operaciones por batch.
      if (pending >= 450) {
        await batch.commit();
        batch = _db.batch();
        pending = 0;
      }
    }

    if (pending > 0) {
      await batch.commit();
    }
  }

  Future<void> deleteUserProfileByAdmin({
    required String uid,
  }) async {
    // 1) Limpia subcolecciones para evitar documentos "fantasma" en consola.
    for (final subPath in _ownedSubcollections) {
      await _deleteUserSubcollection(uid: uid, subPath: subPath);
    }

    // 2) Borra perfil principal y aliases.
    final userRef = _users.doc(uid);
    final userSnap = await userRef.get();
    final aliasRefsToDelete = <DocumentReference<Map<String, dynamic>>>{};
    final recoveryRefsToDelete = <DocumentReference<Map<String, dynamic>>>{};

    if (userSnap.exists) {
      final data = userSnap.data() ?? const <String, dynamic>{};
      final usernameLower =
          (data['usuarioLower'] ?? '').toString().trim().toLowerCase();
      final usernameFromRaw =
          (data['usuario'] ?? '').toString().trim().toLowerCase();
      final correoLower =
          (data['correo'] ?? '').toString().trim().toLowerCase();

      final candidateUsernames = <String>{
        if (usernameLower.isNotEmpty) usernameLower,
        if (usernameFromRaw.isNotEmpty) usernameFromRaw,
      };

      for (final username in candidateUsernames) {
        final aliasRef = _usernames.doc(username);
        final aliasSnap = await aliasRef.get();
        final mappedUid = (aliasSnap.data()?['uid'] ?? '').toString();
        if (aliasSnap.exists && mappedUid == uid) {
          aliasRefsToDelete.add(aliasRef);
        }
      }

      if (correoLower.isNotEmpty) {
        final recoveryRef = _recoveryStatus.doc(correoLower);
        final recoverySnap = await recoveryRef.get();
        final mappedUid = (recoverySnap.data()?['uid'] ?? '').toString();
        if (recoverySnap.exists && mappedUid == uid) {
          recoveryRefsToDelete.add(recoveryRef);
        }
      }
    }

    final batch = _db.batch();
    batch.delete(userRef);
    for (final aliasRef in aliasRefsToDelete) {
      batch.delete(aliasRef);
    }
    for (final recoveryRef in recoveryRefsToDelete) {
      batch.delete(recoveryRef);
    }
    await batch.commit();
  }

  Future<void> upsertFcmToken({
    required String uid,
    required String token,
    required String platform,
  }) async {
    final tokenId = _tokenDocId(token);
    final ref = _users.doc(uid).collection('fcmTokens').doc(tokenId);

    await ref.set(
      <String, dynamic>{
        'token': token,
        'platform': platform,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deleteFcmToken({
    required String uid,
    required String token,
  }) async {
    final tokenId = _tokenDocId(token);
    await _users.doc(uid).collection('fcmTokens').doc(tokenId).delete();
  }

  String _tokenDocId(String token) {
    return base64Url.encode(utf8.encode(token));
  }
}
