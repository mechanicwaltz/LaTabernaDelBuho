// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistModelAdapter extends TypeAdapter<PlaylistModel> {
  @override
  final int typeId = 3;

  @override
  PlaylistModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistModel(
      usuario: fields[0] as String,
      titulo: fields[1] as String,
      artista: fields[2] as String,
      coverUrl: fields[3] as String,
      audioUrl: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.usuario)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.artista)
      ..writeByte(3)
      ..write(obj.coverUrl)
      ..writeByte(4)
      ..write(obj.audioUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
