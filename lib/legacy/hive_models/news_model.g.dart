// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'news_model.dart';

class NewsModelAdapter extends TypeAdapter<NewsModel> {
  @override
  final int typeId = 4;

  @override
  NewsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsModel(
      titulo: fields[0] as String,
      descripcion: fields[1] as String,
      imagenUrl: fields[2] as String,
      link: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NewsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.descripcion)
      ..writeByte(2)
      ..write(obj.imagenUrl)
      ..writeByte(3)
      ..write(obj.link);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
