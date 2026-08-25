// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FolderItemModelAdapter extends TypeAdapter<FolderItemModel> {
  @override
  final int typeId = 21;

  @override
  FolderItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FolderItemModel(
      id: fields[0] as String,
      folderId: fields[1] as String,
      itemId: fields[2] as String,
      addedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FolderItemModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.folderId)
      ..writeByte(2)
      ..write(obj.itemId)
      ..writeByte(3)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
