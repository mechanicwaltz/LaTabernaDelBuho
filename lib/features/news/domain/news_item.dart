import 'package:cloud_firestore/cloud_firestore.dart';

class NewsItem {
  final String id;
  final String titulo;
  final String descripcion;
  final String imagenUrl;
  final String link;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const NewsItem({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.link,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return NewsItem(
      id: doc.id,
      titulo: (data['titulo'] ?? '').toString(),
      descripcion: (data['descripcion'] ?? '').toString(),
      imagenUrl: (data['imagenUrl'] ?? '').toString(),
      link: (data['link'] ?? '').toString(),
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'link': link,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
