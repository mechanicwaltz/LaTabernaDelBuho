import 'package:hive/hive.dart';

part 'reto_model.g.dart';

// typeId debe ser globalmente único en la app (entre todos los adapters registrados).
@HiveType(typeId: 5)
class RetoModel extends HiveObject {
  @HiveField(0)
  String usuario; // 👈 quién creó el reto

  @HiveField(1)
  String tema;

  @HiveField(2)
  String historia;

  RetoModel({
    required this.usuario,
    required this.tema,
    required this.historia,
  });
}
