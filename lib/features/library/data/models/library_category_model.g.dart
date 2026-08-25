// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LibraryCategoryModelAdapter extends TypeAdapter<LibraryCategoryModel> {
  @override
  final int typeId = 23;

  @override
  LibraryCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LibraryCategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      parentId: fields[2] as String?,
      order: fields[3] as int,
      icon: fields[4] as String,
      isSystem: fields[5] as bool,
      acceptsItems: fields[6] as bool,
      allowsChildren: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LibraryCategoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.parentId)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.isSystem)
      ..writeByte(6)
      ..write(obj.acceptsItems)
      ..writeByte(7)
      ..write(obj.allowsChildren);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
