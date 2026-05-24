import 'package:cloud_firestore/cloud_firestore.dart';

class AppNote {
  final String id;
  final String tipo;
  final String titulo;
  final String contenido;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const AppNote({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.contenido,
    this.createdAt,
    this.updatedAt,
  });

  factory AppNote.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppNote(
      id: doc.id,
      tipo: (data['tipo'] ?? 'Nota').toString(),
      titulo: (data['titulo'] ?? '').toString(),
      contenido: (data['contenido'] ?? '').toString(),
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tipo': tipo,
      'titulo': titulo,
      'contenido': contenido,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AppNote copyWith({
    String? tipo,
    String? titulo,
    String? contenido,
    Timestamp? updatedAt,
  }) {
    return AppNote(
      id: id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
