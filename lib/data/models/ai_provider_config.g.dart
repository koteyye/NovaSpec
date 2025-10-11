// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIProviderConfigAdapter extends TypeAdapter<AIProviderConfig> {
  @override
  final int typeId = 5;

  @override
  AIProviderConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIProviderConfig(
      provider: fields[0] as String,
      apiKey: fields[1] as String?,
      baseUrl: fields[2] as String?,
      model: fields[3] as String?,
      temperature: fields[4] as double?,
      maxTokens: fields[5] as int?,
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AIProviderConfig obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.provider)
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
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIProviderConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
