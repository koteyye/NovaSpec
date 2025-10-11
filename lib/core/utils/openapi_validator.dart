import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';

/// Утилита для валидации OpenAPI спецификаций
class OpenApiValidator {
  static final Logger _logger = Logger();

  /// Проверить, является ли файл OpenAPI спецификацией
  ///
  /// [filePath] - путь к файлу JSON или YAML
  /// Возвращает true если файл содержит валидную OpenAPI спецификацию
  static Future<bool> isOpenApiSpec(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.w('OpenAPI Validator: файл не найден: $filePath');
        return false;
      }

      // Читаем содержимое файла
      final content = await file.readAsString();

      // Определяем формат файла по расширению
      final extension = filePath.toLowerCase().split('.').last;

      Map<String, dynamic>? parsedData;

      if (extension == 'json') {
        // Парсим JSON
        parsedData = _parseJson(content);
      } else if (extension == 'yaml' || extension == 'yml') {
        // Для YAML нужно использовать yaml пакет, но для упрощения
        // попробуем найти ключевые строки
        return _validateYamlContent(content);
      } else {
        _logger.w('OpenAPI Validator: неподдерживаемый формат файла: $extension');
        return false;
      }

      if (parsedData == null) {
        return false;
      }

      // Проверяем наличие обязательных полей OpenAPI
      return _validateOpenApiStructure(parsedData);
    } catch (e) {
      _logger.e('OpenAPI Validator: ошибка при валидации файла: $e');
      return false;
    }
  }

  /// Парсить JSON строку
  static Map<String, dynamic>? _parseJson(String content) {
    try {
      final data = json.decode(content);
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    } catch (e) {
      _logger.e('OpenAPI Validator: ошибка парсинга JSON: $e');
      return null;
    }
  }

  /// Валидировать структуру OpenAPI
  ///
  /// Проверяет наличие обязательных полей:
  /// - openapi (или swagger для OpenAPI 2.0)
  /// - info
  /// - paths
  static bool _validateOpenApiStructure(Map<String, dynamic> data) {
    // Проверяем наличие поля openapi (OpenAPI 3.x) или swagger (OpenAPI 2.0)
    final hasOpenApiVersion = data.containsKey('openapi') || data.containsKey('swagger');
    if (!hasOpenApiVersion) {
      _logger.w('OpenAPI Validator: отсутствует поле "openapi" или "swagger"');
      return false;
    }

    // Проверяем наличие поля info
    if (!data.containsKey('info')) {
      _logger.w('OpenAPI Validator: отсутствует поле "info"');
      return false;
    }

    // Проверяем наличие поля paths
    if (!data.containsKey('paths')) {
      _logger.w('OpenAPI Validator: отсутствует поле "paths"');
      return false;
    }

    // Дополнительная валидация: info должен быть объектом
    if (data['info'] is! Map) {
      _logger.w('OpenAPI Validator: поле "info" должно быть объектом');
      return false;
    }

    // Дополнительная валидация: paths должен быть объектом
    if (data['paths'] is! Map) {
      _logger.w('OpenAPI Validator: поле "paths" должно быть объектом');
      return false;
    }

    _logger.i('OpenAPI Validator: файл является валидной OpenAPI спецификацией');
    return true;
  }

  /// Валидировать YAML содержимое
  ///
  /// Упрощенная проверка для YAML файлов без парсинга
  /// Ищет ключевые строки в файле
  static bool _validateYamlContent(String content) {
    // Ищем ключевые поля OpenAPI в тексте
    final hasOpenApi = content.contains(RegExp(r'^openapi\s*:\s*\d+\.\d+', multiLine: true)) ||
        content.contains(RegExp(r'^swagger\s*:\s*\d+\.\d+', multiLine: true));

    final hasInfo = content.contains(RegExp(r'^info\s*:', multiLine: true));
    final hasPaths = content.contains(RegExp(r'^paths\s*:', multiLine: true));

    final isValid = hasOpenApi && hasInfo && hasPaths;

    if (!isValid) {
      _logger.w('OpenAPI Validator: YAML файл не содержит обязательные поля OpenAPI');
    } else {
      _logger.i('OpenAPI Validator: YAML файл является валидной OpenAPI спецификацией');
    }

    return isValid;
  }

  /// Получить версию OpenAPI спецификации
  ///
  /// Возвращает версию (например, "3.0.0") или null если не удалось определить
  static Future<String?> getOpenApiVersion(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final content = await file.readAsString();
      final extension = filePath.toLowerCase().split('.').last;

      if (extension == 'json') {
        final parsedData = _parseJson(content);
        if (parsedData != null) {
          return parsedData['openapi']?.toString() ?? parsedData['swagger']?.toString();
        }
      } else if (extension == 'yaml' || extension == 'yml') {
        // Упрощенное извлечение версии из YAML
        final match = RegExp(r'^openapi\s*:\s*(\d+\.\d+\.\d+)', multiLine: true)
            .firstMatch(content);
        if (match != null) {
          return match.group(1);
        }

        final swaggerMatch = RegExp(r'^swagger\s*:\s*(\d+\.\d+)', multiLine: true)
            .firstMatch(content);
        if (swaggerMatch != null) {
          return swaggerMatch.group(1);
        }
      }

      return null;
    } catch (e) {
      _logger.e('OpenAPI Validator: ошибка при получении версии: $e');
      return null;
    }
  }
}
