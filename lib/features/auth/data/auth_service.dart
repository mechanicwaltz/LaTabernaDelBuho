import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

const String _pendingProfilePrefix = 'tdb.pending.';

class PendingRegistrationData {
  const PendingRegistrationData({
    required this.nombre,
    required this.apellidos,
    required this.usuario,
  });

  final String nombre;
  final String apellidos;
  final String usuario;
}

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> refreshIdToken({bool forceRefresh = true}) async {
    await _auth.currentUser?.getIdToken(forceRefresh);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }

  Future<void> reauthenticateWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final credential = EmailAuthProvider.credential(
      email: email.trim().toLowerCase(),
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> savePendingRegistrationData({
    required String nombre,
    required String apellidos,
    required String usuario,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final payload = <String, String>{
      'nombre': nombre.trim(),
      'apellidos': apellidos.trim(),
      'usuario': usuario.trim(),
    };
    final encoded = base64UrlEncode(utf8.encode(jsonEncode(payload)));
    await user.updateDisplayName('$_pendingProfilePrefix$encoded');
    await user.reload();
  }

  PendingRegistrationData? getPendingRegistrationData([User? user]) {
    final current = user ?? _auth.currentUser;
    final displayName = current?.displayName;
    if (displayName == null || !displayName.startsWith(_pendingProfilePrefix)) {
      return null;
    }

    try {
      final raw = displayName.substring(_pendingProfilePrefix.length);
      final decoded = utf8.decode(base64Url.decode(raw));
      final map = jsonDecode(decoded) as Map<String, dynamic>;

      final nombre = (map['nombre'] ?? '').toString().trim();
      final apellidos = (map['apellidos'] ?? '').toString().trim();
      final usuario = (map['usuario'] ?? '').toString().trim();
      if (nombre.isEmpty || usuario.isEmpty) return null;

      return PendingRegistrationData(
        nombre: nombre,
        apellidos: apellidos,
        usuario: usuario,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearPendingRegistrationData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (!(user.displayName ?? '').startsWith(_pendingProfilePrefix)) return;
    await user.updateDisplayName(null);
    await user.reload();
  }
}
