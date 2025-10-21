// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfiguration _$AppConfigurationFromJson(Map<String, dynamic> json) =>
    AppConfiguration(
      language: json['language'] as String,
      theme: json['theme'] as String,
      autoSave: json['autoSave'] as bool,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      lastOpenedProject: json['lastOpenedProject'] as String?,
    );

Map<String, dynamic> _$AppConfigurationToJson(AppConfiguration instance) =>
    <String, dynamic>{
      'language': instance.language,
      'theme': instance.theme,
      'autoSave': instance.autoSave,
      'notificationsEnabled': instance.notificationsEnabled,
      'lastOpenedProject': instance.lastOpenedProject,
    };
