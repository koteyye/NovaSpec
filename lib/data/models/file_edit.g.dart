// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_edit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileEditAdapter extends TypeAdapter<FileEdit> {
  @override
  final int typeId = 4;

  @override
  FileEdit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileEdit(
      filePath: fields[0] as String,
      action: fields[1] as String,
      oldContent: fields[2] as String?,
      newContent: fields[3] as String?,
      lineStart: fields[4] as int?,
      lineEnd: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FileEdit obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.oldContent)
      ..writeByte(3)
      ..write(obj.newContent)
      ..writeByte(4)
      ..write(obj.lineStart)
      ..writeByte(5)
      ..write(obj.lineEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileEditAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
