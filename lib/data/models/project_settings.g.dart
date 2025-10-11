// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectSettingsAdapter extends TypeAdapter<ProjectSettings> {
  @override
  final int typeId = 1;

  @override
  ProjectSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectSettings(
      aiProvider: fields[0] as String,
      apiKey: fields[1] as String?,
      baseUrl: fields[2] as String?,
      model: fields[3] as String?,
      temperature: fields[4] as double,
      maxTokens: fields[5] as int?,
      language: fields[6] as String,
      darkMode: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.aiProvider)
      ..writeByte(1)
      ..write(obj.apiKey)
      ..writeByte(2)
      ..write(obj.baseUrl)
      ..writeByte(3)
      ..write(obj.model)
      ..writeByte(4)
      ..write(obj.temperature)
      ..writeByte(5)
      ..write(obj.maxTokens)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.darkMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
