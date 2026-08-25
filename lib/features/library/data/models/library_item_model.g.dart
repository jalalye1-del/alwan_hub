// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LibraryItemModelAdapter extends TypeAdapter<LibraryItemModel> {
  @override
  final int typeId = 20;

  @override
  LibraryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LibraryItemModel(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[3] as int,
      sourceId: fields[4] as String,
      localPath: fields[5] as String,
      imageUrl: fields[6] as String?,
      durationInSeconds: fields[7] as int?,
      fileSize: fields[8] as int?,
      createdAt: fields[9] as DateTime,
      lastPlayedAt: fields[10] as DateTime?,
      categoryId: fields[11] as String?,
      audioUrl: fields[12] as String?,
      videoUrl: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LibraryItemModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.sourceId)
      ..writeByte(5)
      ..write(obj.localPath)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.durationInSeconds)
      ..writeByte(8)
      ..write(obj.fileSize)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastPlayedAt)
      ..writeByte(11)
      ..write(obj.categoryId)
      ..writeByte(12)
      ..write(obj.audioUrl)
      ..writeByte(13)
      ..write(obj.videoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
