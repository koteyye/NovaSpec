import 'dart:io';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с Swagger UI
///
/// Запускает локальный Shelf-сервер на 127.0.0.1:4001
/// для отображения OpenAPI спецификаций через Swagger UI
class SwaggerService {
  final Logger _logger = Logger();
  HttpServer? _server;
  String? _currentSpecPath;

  /// Порт для Swagger UI сервера
  static const int port = 4001;

  /// Хост для Swagger UI сервера
  static const String host = '127.0.0.1';

  /// URL для доступа к Swagger UI
  String get swaggerUrl => 'http://$host:$port/';

  /// Проверить, запущен ли сервер
  bool get isRunning => _server != null;

  /// Текущий путь к спецификации
  String? get currentSpecPath => _currentSpecPath;

  /// Запустить Swagger UI сервер
  ///
  /// [specFilePath] - путь к файлу OpenAPI спецификации (JSON или YAML)
  /// Возвращает true если сервер успешно запущен
  Future<bool> start(String specFilePath) async {
    try {
      // Проверяем существование файла
      final file = File(specFilePath);
      if (!await file.exists()) {
        _logger.e('Swagger: файл спецификации не найден: $specFilePath');
        return false;
      }

      // Останавливаем существующий сервер если есть
      if (isRunning) {
        await stop();
      }

      // Создаем обработчик для Swagger UI
      final handler = SwaggerUI('/api-spec', title: 'NovaSpec API Documentation');

      // Создаем роутер с обработчиком спецификации
      final cascadeHandler = shelf.Cascade()
          .add((request) async {
            if (request.url.path == 'api-spec') {
              // Отдаем файл спецификации
              final content = await File(specFilePath).readAsString();
              final contentType = specFilePath.endsWith('.json')
                  ? 'application/json'
                  : 'application/x-yaml';
              return shelf.Response.ok(
                content,
                headers: {'Content-Type': contentType},
              );
            }
            return shelf.Response.notFound('Not Found');
          })
          .add(handler.call)
          .handler;

      // Добавляем CORS заголовки
      final pipeline = const shelf.Pipeline()
          .addMiddleware(_corsMiddleware())
          .addHandler(cascadeHandler);

      // Запускаем сервер
      _server = await shelf_io.serve(
        pipeline,
        host,
        port,
      );

      _currentSpecPath = specFilePath;
      _logger.i('Swagger UI сервер запущен на $swaggerUrl');

      return true;
    } catch (e) {
      _logger.e('Ошибка при запуске Swagger UI сервера: $e');
      return false;
    }
  }

  /// Перезапустить сервер с новой спецификацией
  ///
  /// [specFilePath] - путь к новому файлу спецификации
  /// Возвращает true если сервер успешно перезапущен
  Future<bool> restart(String specFilePath) async {
    _logger.i('Перезапуск Swagger UI сервера с новой спецификацией...');
    return await start(specFilePath);
  }

  /// Остановить Swagger UI сервер
  ///
  /// Возвращает true если сервер успешно остановлен
  Future<bool> stop() async {
    try {
      if (_server != null) {
        await _server!.close(force: true);
        _server = null;
        _currentSpecPath = null;
        _logger.i('Swagger UI сервер остановлен');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Ошибка при остановке Swagger UI сервера: $e');
      return false;
    }
  }

  /// Middleware для добавления CORS заголовков
  shelf.Middleware _corsMiddleware() {
    return shelf.createMiddleware(
      responseHandler: (shelf.Response response) {
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        });
      },
    );
  }

  /// Освободить ресурсы при удалении сервиса
  Future<void> dispose() async {
    await stop();
  }
}
