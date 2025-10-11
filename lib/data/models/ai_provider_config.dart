import 'package:hive/hive.dart';

part 'ai_provider_config.g.dart';

@HiveType(typeId: 5)
class AIProviderConfig {
  @HiveField(0)
  final String provider;

  @HiveField(1)
  String? apiKey;

  @HiveField(2)
  String? baseUrl;

  @HiveField(3)
  String? model;

  @HiveField(4)
  double? temperature;

  @HiveField(5)
  int? maxTokens;

  @HiveField(6)
  bool isActive;

  AIProviderConfig({
    required this.provider,
    this.apiKey,
    this.baseUrl,
    this.model,
    this.temperature,
    this.maxTokens,
    this.isActive = true,
  });
}
