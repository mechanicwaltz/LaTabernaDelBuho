import 'package:cloud_firestore/cloud_firestore.dart';

class SongItem {
  final String id;
  final String titulo;
  final String artista;
  final String coverUrl;
  final String audioUrl;
  final List<String> tags;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const SongItem({
    required this.id,
    required this.titulo,
    required this.artista,
    required this.coverUrl,
    required this.audioUrl,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory SongItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawTags = data['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : const <String>[];

    return SongItem(
      id: doc.id,
      titulo: (data['titulo'] ?? '').toString(),
      artista: (data['artista'] ?? '').toString(),
      coverUrl: (data['coverUrl'] ?? '').toString(),
      audioUrl: (data['audioUrl'] ?? '').toString(),
      tags: tags,
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titulo': titulo,
      'artista': artista,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
