// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      nombre: fields[0] as String,
      apellidos: fields[1] as String,
      correo: fields[2] as String,
      usuario: fields[3] as String,
      password: fields[4] as String,
      fotoPerfil: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.apellidos)
      ..writeByte(2)
      ..write(obj.correo)
      ..writeByte(3)
      ..write(obj.usuario)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.fotoPerfil);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
