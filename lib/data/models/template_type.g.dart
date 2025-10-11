// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TemplateTypeAdapter extends TypeAdapter<TemplateType> {
  @override
  final int typeId = 12;

  @override
  TemplateType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateType(
      id: fields[0] as String,
      name: fields[1] as String,
      systemName: fields[2] as String,
      isDefault: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TemplateType obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.systemName)
      ..writeByte(3)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
