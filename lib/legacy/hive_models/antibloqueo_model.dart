import 'package:hive/hive.dart';

part 'antibloqueo_model.g.dart';

@HiveType(typeId: 2)
class AntibloqueoModel extends HiveObject {
  @HiveField(0)
  String usuario; // 👈 dueño del reto

  @HiveField(1)
  String tema;

  @HiveField(2)
  String texto;

  AntibloqueoModel({
    required this.usuario,
    required this.tema,
    required this.texto,
  });
}
