import 'package:dio/dio.dart';
import '../../shared/models/validation_result.dart';
import '../../core/providers/settings_provider.dart';

class ConfluenceValidationService {
  final Dio _dio;
  
  ConfluenceValidationService(this._dio) {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'NovaSpec/1.0',
        'Accept': 'application/json',
      },
    );
  }
  
  /// Автоопределение типа Confluence по URL
  ConfluenceAuthMethod detectConfluenceType(String url) {
    try {
      final uri = Uri.parse(url.toLowerCase());
      if (uri.host.endsWith('atlassian.net') && uri.path.contains('/wiki')) {
        return ConfluenceAuthMethod.apiToken; // Cloud использует API токен
      } else {
        return ConfluenceAuthMethod.basicAuth; // Data Center использует Basic Auth
      }
    } catch (e) {
      return ConfluenceAuthMethod.basicAuth; // По умолчанию
    }
  }
  
  /// Построение URL для API запросов
  String buildApiUrl(String userUrl) {
    try {
      final uri = Uri.parse(userUrl);
      final type = detectConfluenceType(userUrl);
      
      if (type == ConfluenceAuthMethod.apiToken) {
        // Cloud: https://example.atlassian.net/wiki/rest/api
        return 'https://${uri.host}/wiki/rest/api';
      } else {
        // Data Center: https://confluence.company.com/rest/api
        final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
        return '${uri.scheme}://${uri.host}${path}rest/api';
      }
    } catch (e) {
      throw ArgumentError('Неверный формат URL: $userUrl');
    }
  }
  
  /// Упрощенная валидация подключения к Confluence
  Future<ValidationResult> validateConnectionSimple(
    String url,
    String email,
    String token,
  ) async {
    try {
      final authMethod = detectConfluenceType(url);
      return await validateConnection(url, authMethod, email, token);
    } catch (e) {
      return ValidationResult.error('Ошибка валидации: ${e.toString()}');
    }
  }
  
  /// Валидация подключения к Confluence
  Future<ValidationResult> validateConnection(
    String url,
    ConfluenceAuthMethod authMethod,
    String username,
    String token,
  ) async {
    try {
      final apiUrl = buildApiUrl(url);
      
      Options options;
      if (authMethod == ConfluenceAuthMethod.apiToken) {
        // Cloud: Bearer token
        options = Options(
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        // Data Center: Basic auth
        final credentials = '$username:$token';
        final basicAuth = 'Basic ${Uri.encodeComponent(credentials)}';
        options = Options(
          headers: {'Authorization': basicAuth},
        );
      }
      
      // Тестовый запрос для получения пространств
      final response = await _dio.get(
        '$apiUrl/space?limit=1',
        options: options,
      );
      
      if (response.statusCode == 200) {
        return ValidationResult.success(
          'Подключение к Confluence успешно',
          details: 'Доступно пространств: ${response.data['size']}',
        );
      } else {
        return ValidationResult.error('Неверный статус ответа: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Ошибка аутентификации: неверные учетные данные');
      } else if (e.response?.statusCode == 403) {
        return ValidationResult.error('Доступ запрещен: недостаточно прав');
      } else if (e.response?.statusCode == 404) {
        return ValidationResult.error('Confluence не найден по указанному URL');
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    } catch (e) {
      return ValidationResult.error('Ошибка валидации: ${e.toString()}');
    }
  }
  
  /// Получение списка пространств
  Future<List<Map<String, dynamic>>> getSpaces(
    String url,
    ConfluenceAuthMethod authMethod,
    String username,
    String token,
  ) async {
    try {
      final apiUrl = buildApiUrl(url);
      
      Options options;
      if (authMethod == ConfluenceAuthMethod.apiToken) {
        options = Options(
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        final credentials = '$username:$token';
        final basicAuth = 'Basic ${Uri.encodeComponent(credentials)}';
        options = Options(
          headers: {'Authorization': basicAuth},
        );
      }
      
      final response = await _dio.get(
        '$apiUrl/space?limit=50',
        options: options,
      );
      
      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((space) => {
          'id': space['id'],
          'key': space['key'],
          'name': space['name'],
          'type': space['type'],
          'description': space['description']?['plain']?['value'],
        }).toList();
      } else {
        throw Exception('Failed to fetch spaces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching spaces: $e');
    }
  }
  
  /// Проверка доступности пространства
  Future<ValidationResult> validateSpace(
    String url,
    ConfluenceAuthMethod authMethod,
    String username,
    String token,
    String spaceKey,
  ) async {
    try {
      final apiUrl = buildApiUrl(url);
      
      Options options;
      if (authMethod == ConfluenceAuthMethod.apiToken) {
        options = Options(
          headers: {'Authorization': 'Bearer $token'},
        );
      } else {
        final credentials = '$username:$token';
        final basicAuth = 'Basic ${Uri.encodeComponent(credentials)}';
        options = Options(
          headers: {'Authorization': basicAuth},
        );
      }
      
      final response = await _dio.get(
        '$apiUrl/space/$spaceKey',
        options: options,
      );
      
      if (response.statusCode == 200) {
        final space = response.data;
        return ValidationResult.success(
          'Пространство "${space['name']}" доступно',
          details: 'Ключ: ${space['key']}, Тип: ${space['type']}',
        );
      } else if (response.statusCode == 404) {
        return ValidationResult.error('Пространство с ключом "$spaceKey" не найдено');
      } else {
        return ValidationResult.error('Ошибка доступа к пространству: ${response.statusCode}');
      }
    } catch (e) {
      return ValidationResult.error('Ошибка проверки пространства: ${e.toString()}');
    }
  }
}