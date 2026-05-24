import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String nombre;
  final String apellidos;
  final String correo;
  final String usuario;
  final String usuarioLower;
  final String? fotoPerfilUrl;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const AppUser({
    required this.uid,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.usuario,
    required this.usuarioLower,
    this.fotoPerfilUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      nombre: (data['nombre'] ?? '').toString(),
      apellidos: (data['apellidos'] ?? '').toString(),
      correo: (data['correo'] ?? '').toString(),
      usuario: (data['usuario'] ?? '').toString(),
      usuarioLower: (data['usuarioLower'] ?? '').toString(),
      fotoPerfilUrl: data['fotoPerfilUrl']?.toString(),
      isActive: data['isActive'] is bool ? data['isActive'] as bool : true,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'usuario': usuario,
      'usuarioLower': usuarioLower,
      'fotoPerfilUrl': fotoPerfilUrl,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AppUser copyWith({
    String? nombre,
    String? apellidos,
    String? usuario,
    String? usuarioLower,
    String? fotoPerfilUrl,
    bool? isActive,
    Timestamp? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      correo: correo,
      usuario: usuario ?? this.usuario,
      usuarioLower: usuarioLower ?? this.usuarioLower,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
