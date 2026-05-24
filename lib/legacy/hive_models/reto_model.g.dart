// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reto_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RetoModelAdapter extends TypeAdapter<RetoModel> {
  @override
  final int typeId = 5;

  @override
  RetoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RetoModel(
      usuario: fields[0] as String,
      tema: fields[1] as String,
      historia: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RetoModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.usuario)
      ..writeByte(1)
      ..write(obj.tema)
      ..writeByte(2)
      ..write(obj.historia);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RetoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
