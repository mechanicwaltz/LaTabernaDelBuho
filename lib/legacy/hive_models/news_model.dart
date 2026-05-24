import 'package:hive/hive.dart';

part 'news_model.g.dart';

@HiveType(typeId: 4)
class NewsModel extends HiveObject {
  @HiveField(0)
  String titulo;

  @HiveField(1)
  String descripcion;

  @HiveField(2)
  String imagenUrl;

  @HiveField(3)
  String link;

  NewsModel({
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.link,
  });
}
