// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 14;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig(
      currentProjectPath: fields[0] as String?,
      currentProjectName: fields[1] as String?,
      aiProvider: fields[2] as String?,
      aiProviderBaseUrl: fields[3] as String?,
      aiProviderToken: fields[4] as String?,
      aiSelectedModel: fields[5] as String?,
      confluenceEnabled: fields[6] as bool,
      confluenceBaseUrl: fields[7] as String?,
      confluenceEmail: fields[8] as String?,
      confluenceToken: fields[9] as String?,
      confluenceInstanceType: fields[10] as String?,
      confluenceSpace: fields[20] as String?,
      confluenceParentPageId: fields[21] as String?,
      musicEnabled: fields[11] as bool,
      musicToken: fields[12] as String?,
      musicGenre: fields[13] as String,
      musicBalance: fields[14] as int?,
      language: fields[15] as String,
      templateReviewModel: fields[16] as String?,
      chatHistories: (fields[17] as List?)?.cast<ChatHistory>(),
      templateTypes: (fields[18] as List?)?.cast<TemplateType>(),
      templates: (fields[19] as List?)?.cast<Template>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.currentProjectPath)
      ..writeByte(1)
      ..write(obj.currentProjectName)
      ..writeByte(2)
      ..write(obj.aiProvider)
      ..writeByte(3)
      ..write(obj.aiProviderBaseUrl)
      ..writeByte(4)
      ..write(obj.aiProviderToken)
      ..writeByte(5)
      ..write(obj.aiSelectedModel)
      ..writeByte(6)
      ..write(obj.confluenceEnabled)
      ..writeByte(7)
      ..write(obj.confluenceBaseUrl)
      ..writeByte(8)
      ..write(obj.confluenceEmail)
      ..writeByte(9)
      ..write(obj.confluenceToken)
      ..writeByte(10)
      ..write(obj.confluenceInstanceType)
      ..writeByte(20)
      ..write(obj.confluenceSpace)
      ..writeByte(21)
      ..write(obj.confluenceParentPageId)
      ..writeByte(11)
      ..write(obj.musicEnabled)
      ..writeByte(12)
      ..write(obj.musicToken)
      ..writeByte(13)
      ..write(obj.musicGenre)
      ..writeByte(14)
      ..write(obj.musicBalance)
      ..writeByte(15)
      ..write(obj.language)
      ..writeByte(16)
      ..write(obj.templateReviewModel)
      ..writeByte(17)
      ..write(obj.chatHistories)
      ..writeByte(18)
      ..write(obj.templateTypes)
      ..writeByte(19)
      ..write(obj.templates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
