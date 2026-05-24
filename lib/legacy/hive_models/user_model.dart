import 'package:hive/hive.dart';

part 'user_model.g.dart'; // 👈 esto se queda

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  String apellidos;

  @HiveField(2)
  String correo;

  @HiveField(3)
  String usuario;

  @HiveField(4)
  String password;

  @HiveField(5)
  String? fotoPerfil;

  UserModel({
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.usuario,
    required this.password,
    this.fotoPerfil,
  });
}
