// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordingFileAdapter extends TypeAdapter<RecordingFile> {
  @override
  final int typeId = 3;

  @override
  RecordingFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordingFile(
      id: fields[0] as String,
      title: fields[1] as String,
      fileName: fields[2] as String,
      filePath: fields[3] as String,
      sourceType: fields[4] as RecordingSourceType,
      category: fields[5] as String,
      folderName: fields[6] as String,
      durationMilliseconds: fields[12] as int,
      fileSize: fields[13] as int,
      createdAt: fields[14] as DateTime,
      status: fields[18] as RecordingStatus,
      stationName: fields[7] as String?,
      programName: fields[8] as String?,
      stationId: fields[9] as String?,
      programId: fields[10] as String?,
      imageUrl: fields[11] as String?,
      lastPlayed: fields[15] as DateTime?,
      playCount: fields[16] as int,
      isFavorite: fields[17] as bool,
      notes: fields[19] as String?,
      tags: (fields[20] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecordingFile obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.sourceType)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.folderName)
      ..writeByte(7)
      ..write(obj.stationName)
      ..writeByte(8)
      ..write(obj.programName)
      ..writeByte(9)
      ..write(obj.stationId)
      ..writeByte(10)
      ..write(obj.programId)
      ..writeByte(11)
      ..write(obj.imageUrl)
      ..writeByte(12)
      ..write(obj.durationMilliseconds)
      ..writeByte(13)
      ..write(obj.fileSize)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.lastPlayed)
      ..writeByte(16)
      ..write(obj.playCount)
      ..writeByte(17)
      ..write(obj.isFavorite)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(19)
      ..write(obj.notes)
      ..writeByte(20)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordingSourceTypeAdapter extends TypeAdapter<RecordingSourceType> {
  @override
  final int typeId = 1;

  @override
  RecordingSourceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordingSourceType.liveBroadcast;
      case 1:
        return RecordingSourceType.fmStation;
      case 2:
        return RecordingSourceType.program;
      case 3:
        return RecordingSourceType.podcast;
      case 4:
        return RecordingSourceType.audiobook;
      default:
        return RecordingSourceType.liveBroadcast;
    }
  }

  @override
  void write(BinaryWriter writer, RecordingSourceType obj) {
    switch (obj) {
      case RecordingSourceType.liveBroadcast:
        writer.writeByte(0);
        break;
      case RecordingSourceType.fmStation:
        writer.writeByte(1);
        break;
      case RecordingSourceType.program:
        writer.writeByte(2);
        break;
      case RecordingSourceType.podcast:
        writer.writeByte(3);
        break;
      case RecordingSourceType.audiobook:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingSourceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecordingStatusAdapter extends TypeAdapter<RecordingStatus> {
  @override
  final int typeId = 2;

  @override
  RecordingStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecordingStatus.recording;
      case 1:
        return RecordingStatus.completed;
      case 2:
        return RecordingStatus.cancelled;
      case 3:
        return RecordingStatus.failed;
      default:
        return RecordingStatus.recording;
    }
  }

  @override
  void write(BinaryWriter writer, RecordingStatus obj) {
    switch (obj) {
      case RecordingStatus.recording:
        writer.writeByte(0);
        break;
      case RecordingStatus.completed:
        writer.writeByte(1);
        break;
      case RecordingStatus.cancelled:
        writer.writeByte(2);
        break;
      case RecordingStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
