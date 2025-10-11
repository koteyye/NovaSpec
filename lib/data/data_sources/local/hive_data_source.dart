import 'package:hive/hive.dart';
import 'package:novaspec/data/models/app_config.dart';
import 'package:novaspec/data/models/chat_history.dart';
import 'package:novaspec/data/models/template.dart';
import 'package:novaspec/data/models/template_type.dart';

/// Источник данных для работы с Hive
class HiveDataSource {
  static const String _appConfigBoxName = 'app_config';
  static const String _appConfigKey = 'config';

  // ==================== AppConfig ====================

  /// Получить конфигурацию приложения
  Future<AppConfig?> getAppConfig() async {
    final box = await Hive.openBox<AppConfig>(_appConfigBoxName);
    return box.get(_appConfigKey);
  }

  /// Сохранить конфигурацию приложения
  Future<void> saveAppConfig(AppConfig config) async {
    final box = await Hive.openBox<AppConfig>(_appConfigBoxName);
    await box.put(_appConfigKey, config);
  }

  /// Обновить конфигурацию приложения
  Future<void> updateAppConfig(AppConfig config) async {
    await saveAppConfig(config);
  }

  /// Удалить конфигурацию приложения
  Future<void> deleteAppConfig() async {
    final box = await Hive.openBox<AppConfig>(_appConfigBoxName);
    await box.delete(_appConfigKey);
  }

  // ==================== ChatHistory ====================

  /// Получить все истории чатов
  Future<List<ChatHistory>> getAllChatHistories() async {
    final config = await getAppConfig();
    return config?.chatHistories ?? [];
  }

  /// Получить историю чата по ID
  Future<ChatHistory?> getChatHistoryById(String id) async {
    final histories = await getAllChatHistories();
    try {
      return histories.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Добавить новую историю чата
  Future<void> addChatHistory(ChatHistory history) async {
    final config = await getAppConfig();
    if (config != null) {
      config.chatHistories.add(history);
      await saveAppConfig(config);
    }
  }

  /// Обновить историю чата
  Future<void> updateChatHistory(ChatHistory history) async {
    final config = await getAppConfig();
    if (config != null) {
      final index = config.chatHistories.indexWhere((h) => h.id == history.id);
      if (index != -1) {
        config.chatHistories[index] = history;
        await saveAppConfig(config);
      }
    }
  }

  /// Удалить историю чата
  Future<void> deleteChatHistory(String id) async {
    final config = await getAppConfig();
    if (config != null) {
      config.chatHistories.removeWhere((h) => h.id == id);
      await saveAppConfig(config);
    }
  }

  // ==================== TemplateType ====================

  /// Получить все типы шаблонов
  Future<List<TemplateType>> getAllTemplateTypes() async {
    final config = await getAppConfig();
    return config?.templateTypes ?? [];
  }

  /// Получить тип шаблона по ID
  Future<TemplateType?> getTemplateTypeById(String id) async {
    final types = await getAllTemplateTypes();
    try {
      return types.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Добавить новый тип шаблона
  Future<void> addTemplateType(TemplateType type) async {
    final config = await getAppConfig();
    if (config != null) {
      config.templateTypes.add(type);
      await saveAppConfig(config);
    }
  }

  /// Удалить тип шаблона (только если не isDefault)
  Future<bool> deleteTemplateType(String id) async {
    final config = await getAppConfig();
    if (config != null) {
      final type = config.templateTypes.firstWhere((t) => t.id == id);
      if (type.isDefault) {
        return false; // Нельзя удалить дефолтный тип
      }
      config.templateTypes.removeWhere((t) => t.id == id);
      await saveAppConfig(config);
      return true;
    }
    return false;
  }

  // ==================== Template ====================

  /// Получить все шаблоны
  Future<List<Template>> getAllTemplates() async {
    final config = await getAppConfig();
    return config?.templates ?? [];
  }

  /// Получить шаблон по ID
  Future<Template?> getTemplateById(String id) async {
    final templates = await getAllTemplates();
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получить шаблоны по типу
  Future<List<Template>> getTemplatesByType(String typeId) async {
    final templates = await getAllTemplates();
    return templates.where((t) => t.typeId == typeId).toList();
  }

  /// Добавить новый шаблон
  Future<void> addTemplate(Template template) async {
    final config = await getAppConfig();
    if (config != null) {
      config.templates.add(template);
      await saveAppConfig(config);
    }
  }

  /// Обновить шаблон
  Future<void> updateTemplate(Template template) async {
    final config = await getAppConfig();
    if (config != null) {
      final index = config.templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        config.templates[index] = template;
        await saveAppConfig(config);
      }
    }
  }

  /// Удалить шаблон (только если не isDefault)
  Future<bool> deleteTemplate(String id) async {
    final config = await getAppConfig();
    if (config != null) {
      final template = config.templates.firstWhere((t) => t.id == id);
      if (template.isDefault) {
        return false; // Нельзя удалить дефолтный шаблон
      }
      config.templates.removeWhere((t) => t.id == id);
      await saveAppConfig(config);
      return true;
    }
    return false;
  }

  // ==================== Утилиты ====================

  /// Закрыть все boxes
  Future<void> closeAll() async {
    await Hive.close();
  }
}
