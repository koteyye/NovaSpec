import 'package:hive/hive.dart';

part 'project_settings.g.dart';

@HiveType(typeId: 1)
class ProjectSettings {
  @HiveField(0)
  String aiProvider;

  @HiveField(1)
  String? apiKey;

  @HiveField(2)
  String? baseUrl;

  @HiveField(3)
  String? model;

  @HiveField(4)
  double temperature;

  @HiveField(5)
  int? maxTokens;

  @HiveField(6)
  String language;

  @HiveField(7)
  bool darkMode;

  ProjectSettings({
    this.aiProvider = 'openai',
    this.apiKey,
    this.baseUrl,
    this.model,
    this.temperature = 0.7,
    this.maxTokens,
    this.language = 'ru',
    this.darkMode = false,
  });
}
