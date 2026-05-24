// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'antibloqueo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AntibloqueoModelAdapter extends TypeAdapter<AntibloqueoModel> {
  @override
  final int typeId = 2;

  @override
  AntibloqueoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AntibloqueoModel(
      usuario: fields[0] as String,
      tema: fields[1] as String,
      texto: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AntibloqueoModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.usuario)
      ..writeByte(1)
      ..write(obj.tema)
      ..writeByte(2)
      ..write(obj.texto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AntibloqueoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
