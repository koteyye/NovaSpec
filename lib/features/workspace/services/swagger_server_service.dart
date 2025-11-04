import 'dart:io';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'openapi_service.dart';

class SwaggerServerService {
  // Singleton pattern
  static final SwaggerServerService _instance =
      SwaggerServerService._internal();
  factory SwaggerServerService() => _instance;
  SwaggerServerService._internal();

  HttpServer? _server;
  String? _serverUrl;
  int? _port;
  bool _isRunning = false;
  String? _currentSpecPath;
  String? _currentHtmlContent;
  int _referenceCount = 0;

  /// Увеличивает счётчик ссылок на сервер
  void addReference() {
    _referenceCount++;
  }

  /// Уменьшает счётчик ссылок на сервер и останавливает его, если ссылок не осталось
  Future<void> removeReference() async {
    if (_referenceCount > 0) {
      _referenceCount--;

      if (_referenceCount == 0) {
        await stopServer();
      }
    }
  }

  Future<void> initializeBackgroundServer() async {
    // Если сервер уже запущен, просто возвращаемся
    if (_isRunning && _server != null) {
      return;
    }

    // Если сервер был запущен но потерялся, останавливаем его
    if (_isRunning && _server == null) {
      _isRunning = false;
    }

    // Пробуем создать сервер напрямую без предварительного тестирования
    HttpServer? createdServer;
    int? selectedPort;
    Exception? lastError;

    for (int port = 8080; port <= 8180; port++) {
      try {
        createdServer = await HttpServer.bind('localhost', port, shared: false);
        selectedPort = port;
        break;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        continue;
      }
    }

    if (createdServer == null || selectedPort == null) {
      throw Exception(
        'Failed to initialize Swagger server: No available ports found in range 8080-8180. Last error: $lastError',
      );
    }

    try {
      _server = createdServer;
      _port = selectedPort;
      _serverUrl = 'http://localhost:$_port';
      _isRunning = true;

      // Start listening for requests
      unawaited(_serveRequests());
    } catch (e) {
      // Если что-то пошло не так после создания, закрываем сервер
      await createdServer.close(force: true);
      _isRunning = false;
      _server = null;
      _serverUrl = null;
      _port = null;
      throw Exception('Failed to initialize Swagger server: $e');
    }
  }

  Future<void> ensureServerRunning() async {
    if (!_isRunning || _server == null) {
      await initializeBackgroundServer();
    }
  }

  Future<String> loadOpenAPISpec(String filePath) async {
    try {
      // Если этот файл уже загружен, просто возвращаем URL
      if (_currentSpecPath == filePath && _isRunning && _serverUrl != null) {
        return _serverUrl!;
      }

      await ensureServerRunning();

      final fileContent = await File(filePath).readAsString();

      // Определяем URL спецификации в зависимости от расширения
      final extension = filePath.toLowerCase().split('.').last;
      final specUrl = (extension == 'yaml' || extension == 'yml')
          ? '/spec.yaml'
          : '/spec.json';

      final openAPIService = OpenAPIService();
      final htmlContent = await openAPIService.generateSwaggerHtml(
        fileContent,
        specUrl: specUrl,
      );

      _currentSpecPath = filePath;
      _currentHtmlContent = htmlContent;

      return _serverUrl!;
    } catch (e) {
      throw Exception('Failed to load OpenAPI spec: $e');
    }
  }

  Future<void> stopServer() async {
    if (!_isRunning && _server == null) {
      return;
    }

    // Проверяем, есть ли ещё активные ссылки
    if (_referenceCount > 0) {
      return;
    }

    try {
      if (_server != null) {
        await _server!.close(force: true);
        _server = null;

        // Даём время ОС полностью освободить порт и все сокеты
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      // Игнорируем ошибки закрытия
    } finally {
      _isRunning = false;
      _serverUrl = null;
      _port = null;
      _currentSpecPath = null;
      _currentHtmlContent = null;
    }
  }

  /// Принудительная остановка сервера без проверки счётчика ссылок
  Future<void> forceStopServer() async {
    _referenceCount = 0;
    await stopServer();
  }

  Future<void> _serveRequests() async {
    if (_server == null) return;

    await for (final HttpRequest request in _server!) {
      try {
        // Convert HttpRequest to shelf Request
        final headers = <String, String>{};
        request.headers.forEach((name, values) {
          headers[name] = values.join(', ');
        });

        final shelfRequest = Request(
          request.method,
          request.requestedUri,
          protocolVersion: '1.1',
          headers: headers,
          body: request,
          context: {},
        );

        final handler = _handleRequest;

        final response = await handler(shelfRequest);

        // Set response headers and status
        request.response.statusCode = response.statusCode;
        response.headers.forEach((name, value) {
          request.response.headers.set(name, value);
        });

        // Write response body
        try {
          final body = await response.readAsString();
          request.response.write(body);
        } catch (e) {
          // Response might not have a body or might not be readable
        }

        await request.response.close();
      } catch (e) {
        request.response.statusCode = 500;
        request.response.write('Internal Server Error: $e');
        await request.response.close();
      }
    }
  }

  Future<Response> _handleRequest(Request request) async {
    try {
      final path = request.url.path;

      if (path.isEmpty || path == '/') {
        // Serve Swagger UI HTML
        if (_currentHtmlContent != null) {
          return Response.ok(
            _currentHtmlContent!,
            headers: {
              'Content-Type': 'text/html; charset=utf-8',
              'Access-Control-Allow-Origin': '*',
            },
          );
        }
        return Response.notFound('OpenAPI spec not loaded');
      } else if (path == 'spec.json' ||
          path == '/spec.json' ||
          path == 'spec.yaml' ||
          path == '/spec.yaml') {
        // Serve OpenAPI spec
        if (_currentSpecPath != null) {
          try {
            final file = File(_currentSpecPath!);
            if (await file.exists()) {
              final content = await file.readAsString();

              // Определяем формат файла и соответствующий Content-Type
              final extension = _currentSpecPath!.toLowerCase().split('.').last;
              String contentType;

              if (extension == 'json') {
                contentType = 'application/json; charset=utf-8';
              } else if (extension == 'yaml' || extension == 'yml') {
                contentType = 'application/x-yaml; charset=utf-8';
              } else {
                contentType = 'application/json; charset=utf-8';
              }

              return Response.ok(
                content,
                headers: {
                  'Content-Type': contentType,
                  'Access-Control-Allow-Origin': '*',
                },
              );
            }
          } catch (e) {
            return Response.internalServerError(
              body: 'Failed to read spec file: $e',
            );
          }
        }
        return Response.notFound('OpenAPI spec not loaded');
      } else if (path.startsWith('/static/')) {
        // Serve static files (CSS, JS for Swagger UI)
        return _serveStaticFile(path);
      } else if (request.method == 'OPTIONS') {
        // Handle CORS preflight requests
        return Response.ok(
          null,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          },
        );
      } else {
        return Response.notFound('Not found');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Internal server error: $e');
    }
  }

  Future<Response> _serveStaticFile(String path) async {
    // For now, return a simple response for static files
    // In a real implementation, you would serve actual static files
    return Response.notFound('Static file not found: $path');
  }

  // Getters
  String? get serverUrl => _serverUrl;
  bool get isRunning => _isRunning;
  int? get port => _port;
  String? get currentSpecPath => _currentSpecPath;
  int get referenceCount => _referenceCount;
}

// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally not awaiting the future
}
