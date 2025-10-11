import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:novaspec/data/models/app_config.dart';

/// Репозиторий для работы с конфигурацией приложения
class ConfigRepository {
  final HiveDataSource _dataSource;

  ConfigRepository(this._dataSource);

  /// Получить текущую конфигурацию
  Future<AppConfig?> getConfig() async {
    return await _dataSource.getAppConfig();
  }

  /// Сохранить конфигурацию
  Future<void> saveConfig(AppConfig config) async {
    await _dataSource.saveAppConfig(config);
  }

  /// Обновить конфигурацию
  Future<void> updateConfig(AppConfig config) async {
    await _dataSource.updateAppConfig(config);
  }

  /// Обновить путь к текущему проекту
  Future<void> updateCurrentProject({
    required String path,
    required String name,
  }) async {
    final config = await getConfig();
    if (config != null) {
      config.currentProjectPath = path;
      config.currentProjectName = name;
      await updateConfig(config);
    }
  }

  /// Обновить настройки AI провайдера
  Future<void> updateAIProvider({
    required String provider,
    String? baseUrl,
    String? token,
    String? model,
  }) async {
    final config = await getConfig();
    if (config != null) {
      config.aiProvider = provider;
      config.aiProviderBaseUrl = baseUrl;
      config.aiProviderToken = token;
      config.aiSelectedModel = model;
      await updateConfig(config);
    }
  }

  /// Обновить настройки Confluence
  Future<void> updateConfluenceSettings({
    required bool enabled,
    String? baseUrl,
    String? email,
    String? token,
    String? instanceType,
    String? space,
    String? parentPageId,
  }) async {
    final config = await getConfig();
    if (config != null) {
      config.confluenceEnabled = enabled;
      config.confluenceBaseUrl = baseUrl;
      config.confluenceEmail = email;
      config.confluenceToken = token;
      config.confluenceInstanceType = instanceType;
      config.confluenceSpace = space;
      config.confluenceParentPageId = parentPageId;
      await updateConfig(config);
    }
  }

  /// Обновить настройки музикации
  Future<void> updateMusicSettings({
    required bool enabled,
    String? token,
    String? genre,
    int? balance,
  }) async {
    final config = await getConfig();
    if (config != null) {
      config.musicEnabled = enabled;
      if (token != null) config.musicToken = token;
      if (genre != null) config.musicGenre = genre;
      if (balance != null) config.musicBalance = balance;
      await updateConfig(config);
    }
  }

  /// Обновить язык приложения
  Future<void> updateLanguage(String language) async {
    final config = await getConfig();
    if (config != null) {
      config.language = language;
      await updateConfig(config);
    }
  }

  /// Проверить, есть ли текущий проект
  Future<bool> hasCurrentProject() async {
    final config = await getConfig();
    return config?.currentProjectPath != null &&
        config!.currentProjectPath!.isNotEmpty;
  }

  /// Проверить, настроен ли AI провайдер
  Future<bool> isAIProviderConfigured() async {
    final config = await getConfig();
    return config?.aiProvider != null &&
        config!.aiProvider!.isNotEmpty &&
        config.aiProviderToken != null &&
        config.aiProviderToken!.isNotEmpty;
  }

  /// Проверить, настроен ли Confluence
  Future<bool> isConfluenceConfigured() async {
    final config = await getConfig();
    return config?.confluenceEnabled == true &&
        config!.confluenceBaseUrl != null &&
        config.confluenceBaseUrl!.isNotEmpty;
  }

  /// Проверить, настроена ли музикация
  Future<bool> isMusicConfigured() async {
    final config = await getConfig();
    return config?.musicEnabled == true &&
        config!.musicToken != null &&
        config.musicToken!.isNotEmpty;
  }

  /// Добавить шаблон
  Future<void> addTemplate(dynamic template) async {
    await _dataSource.addTemplate(template);
  }

  /// Обновить шаблон
  Future<void> updateTemplate(dynamic template) async {
    await _dataSource.updateTemplate(template);
  }

  /// Удалить шаблон
  Future<void> deleteTemplate(String templateId) async {
    await _dataSource.deleteTemplate(templateId);
  }
}
