import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 3)
class PlaylistModel extends HiveObject {
  @HiveField(0)
  String usuario;

  @HiveField(1)
  String titulo;

  @HiveField(2)
  String artista;

  @HiveField(3)
  String coverUrl;

  @HiveField(4)
  String audioUrl;

  PlaylistModel({
    required this.usuario,
    required this.titulo,
    required this.artista,
    required this.coverUrl,
    required this.audioUrl,
  });
}
