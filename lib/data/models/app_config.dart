import 'package:hive/hive.dart';
import 'package:novaspec/data/models/chat_history.dart';
import 'package:novaspec/data/models/template_type.dart';
import 'package:novaspec/data/models/template.dart';

part 'app_config.g.dart';

@HiveType(typeId: 14)
class AppConfig extends HiveObject {
  // Проект
  @HiveField(0)
  String? currentProjectPath;

  @HiveField(1)
  String? currentProjectName;

  // AI Provider
  @HiveField(2)
  String? aiProvider; // openai, openai_competitive, anthropic, cerebras, groq, lm_studio, ollama, openrouter

  @HiveField(3)
  String? aiProviderBaseUrl;

  @HiveField(4)
  String? aiProviderToken;

  @HiveField(5)
  String? aiSelectedModel;

  // Confluence
  @HiveField(6)
  bool confluenceEnabled;

  @HiveField(7)
  String? confluenceBaseUrl;

  @HiveField(8)
  String? confluenceEmail;

  @HiveField(9)
  String? confluenceToken;

  @HiveField(10)
  String? confluenceInstanceType; // cloud | datacenter

  @HiveField(20)
  String? confluenceSpace;

  @HiveField(21)
  String? confluenceParentPageId;

  // Музикация
  @HiveField(11)
  bool musicEnabled;

  @HiveField(12)
  String? musicToken;

  @HiveField(13)
  String musicGenre; // pop, russian_rap, rock, jazz, classic, electro_music, hip_hop, r&b

  @HiveField(14)
  int? musicBalance;

  // Язык
  @HiveField(15)
  String language; // ru | en

  // Модель для AI-ревью шаблонов
  @HiveField(16)
  String? templateReviewModel;

  // История чатов
  @HiveField(17)
  List<ChatHistory> chatHistories;

  // Шаблоны
  @HiveField(18)
  List<TemplateType> templateTypes;

  @HiveField(19)
  List<Template> templates;

  AppConfig({
    this.currentProjectPath,
    this.currentProjectName,
    this.aiProvider,
    this.aiProviderBaseUrl,
    this.aiProviderToken,
    this.aiSelectedModel,
    this.confluenceEnabled = false,
    this.confluenceBaseUrl,
    this.confluenceEmail,
    this.confluenceToken,
    this.confluenceInstanceType,
    this.confluenceSpace,
    this.confluenceParentPageId,
    this.musicEnabled = false,
    this.musicToken,
    this.musicGenre = 'pop',
    this.musicBalance,
    this.language = 'ru',
    this.templateReviewModel,
    List<ChatHistory>? chatHistories,
    List<TemplateType>? templateTypes,
    List<Template>? templates,
  })  : chatHistories = chatHistories ?? [],
        templateTypes = templateTypes ?? [],
        templates = templates ?? [];
}
