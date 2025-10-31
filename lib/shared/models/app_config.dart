import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfiguration extends Equatable {
  @JsonKey(name: 'language')
  final String language;
  
  @JsonKey(name: 'theme')
  final String theme;
  
  @JsonKey(name: 'autoSave')
  final bool autoSave;
  
  @JsonKey(name: 'notificationsEnabled')
  final bool notificationsEnabled;
  
  @JsonKey(name: 'lastOpenedProject')
  final String? lastOpenedProject;
  
  const AppConfiguration({
    required this.language,
    required this.theme,
    required this.autoSave,
    required this.notificationsEnabled,
    this.lastOpenedProject,
  });
  
  factory AppConfiguration.fromJson(Map<String, dynamic> json) =>
      _$AppConfigurationFromJson(json);
  
  Map<String, dynamic> toJson() => _$AppConfigurationToJson(this);
  
  AppConfiguration copyWith({
    String? language,
    String? theme,
    bool? autoSave,
    bool? notificationsEnabled,
    String? lastOpenedProject,
  }) {
    return AppConfiguration(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoSave: autoSave ?? this.autoSave,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastOpenedProject: lastOpenedProject ?? this.lastOpenedProject,
    );
  }
  
  @override
  List<Object?> get props => [
    language,
    theme,
    autoSave,
    notificationsEnabled,
    lastOpenedProject,
  ];
}
