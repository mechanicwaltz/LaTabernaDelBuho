import 'package:hive/hive.dart';

part 'song_model.g.dart';

// typeId debe ser globalmente único en la app (entre todos los adapters registrados).
@HiveType(typeId: 6)
class SongModel extends HiveObject {
  @HiveField(0)
  String usuario; // 👈 dueño de la playlist

  @HiveField(1)
  String titulo;

  @HiveField(2)
  String artista;

  @HiveField(3)
  String albumCover; // URL de portada

  SongModel({
    required this.usuario,
    required this.titulo,
    required this.artista,
    required this.albumCover,
  });
}
