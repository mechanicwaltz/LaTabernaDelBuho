import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class NoteModel extends HiveObject {
  @HiveField(0)
  String usuario;

  @HiveField(1)
  String tipo;

  @HiveField(2)
  String titulo;

  @HiveField(3)
  String contenido;

  @HiveField(4)
  DateTime fecha;

  NoteModel({
    required this.usuario,
    required this.tipo,
    required this.titulo,
    required this.contenido,
    required this.fecha,
  });
}
