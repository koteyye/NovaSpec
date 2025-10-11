// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confluence_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfluenceSettingsAdapter extends TypeAdapter<ConfluenceSettings> {
  @override
  final int typeId = 6;

  @override
  ConfluenceSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfluenceSettings(
      type: fields[0] as String,
      baseUrl: fields[1] as String?,
      email: fields[2] as String?,
      apiToken: fields[3] as String?,
      username: fields[4] as String?,
      password: fields[5] as String?,
      spaceKey: fields[6] as String?,
      parentPageId: fields[7] as String?,
      isEnabled: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ConfluenceSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.baseUrl)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.apiToken)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.password)
      ..writeByte(6)
      ..write(obj.spaceKey)
      ..writeByte(7)
      ..write(obj.parentPageId)
      ..writeByte(8)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfluenceSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
