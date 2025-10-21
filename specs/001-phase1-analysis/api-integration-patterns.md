# API Integration Patterns: React/TypeScript → Flutter/Dart

## Обзор

Анализ паттернов интеграции с API в TypeScript проекте и их эквиваленты во Flutter. Проект использует минимальные API интеграции в основном для мок данных.

## 1. Текущие API интеграции в TypeScript проекте

### 1.1 Анализ кода на предмет API вызовов

#### Поиск HTTP запросов
```bash
# Поиск fetch/axios/http вызовов
grep -r "fetch\|axios\|http" src/
grep -r "api\|endpoint\|request" src/
```

#### Результаты анализа
В текущем TypeScript проекте **отсутствуют реальные API вызовы**. Все данные являются моками:

```typescript
// AIAssistant.tsx - мок данные
const mockMessages: Message[] = [
  { role: "user", content: "Добавь раздел про уведомления" },
  {
    role: "assistant",
    content: "Добавляю раздел про уведомления в техническое задание.",
  },
];

const mockChatHistory: ChatHistory[] = [
  { id: "1", title: "Уведомления / Push / Настройки", messages: mockMessages },
  { id: "2", title: "Архитектура / Backend / API", messages: [] },
  { id: "3", title: "UI/UX / Дизайн / Компоненты", messages: [] },
];

const mockFiles: FileReference[] = [
  { name: "spec_v1.md", path: "/spec_v1.md" },
  { name: "spec_v2.html", path: "/spec_v2.html" },
  { name: "requirements.json", path: "/requirements.json" },
];
```

```typescript
// TextEditor.tsx - мок данные
const mockJsonContent = `{
  "projectName": "Трекер привычек",
  "version": "1.0.0",
  "requirements": {
    "functional": [
      "Создание и управление привычками",
      "Ежедневное отслеживание выполнения",
      "Визуализация прогресса"
    ],
    "technical": {
      "frontend": "React Native",
      "backend": "Node.js + Express",
      "database": "PostgreSQL"
    }
  }
}`;
```

### 1.2 Потенциальные API интеграции

#### AI Assistant API
```typescript
// Предполагаемые API вызовы для AI Assistant
const sendMessage = async (message: string, model: string) => {
  const response = await fetch('/api/ai/chat', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message,
      model,
      history: currentMessages,
    }),
  });
  
  return response.json();
};

const getModels = async () => {
  const response = await fetch('/api/ai/models');
  return response.json();
};
```

#### File System API
```typescript
// Предполагаемые API вызовы для файловой системы
const loadFiles = async () => {
  const response = await fetch('/api/files');
  return response.json();
};

const saveFile = async (path: string, content: string) => {
  const response = await fetch(`/api/files${path}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ content }),
  });
  
  return response.json();
};
```

#### Templates API
```typescript
// Предполагаемые API вызовы для шаблонов
const getTemplates = async () => {
  const response = await fetch('/api/templates');
  return response.json();
};

const createTemplate = async (template: Template) => {
  const response = await fetch('/api/templates', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(template),
  });
  
  return response.json();
};
```

#### Settings API
```typescript
// Предполагаемые API вызовы для настроек
const getSettings = async () => {
  const response = await fetch('/api/settings');
  return response.json();
};

const updateSettings = async (settings: Settings) => {
  const response = await fetch('/api/settings', {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(settings),
  });
  
  return response.json();
};
```

### 1.3 Swagger/OpenAPI интеграция

#### utils/openapi.ts
```typescript
import { mockOpenAPIJson, mockOpenAPIYaml } from "@/utils/openapi";

// Использование в SpecPreview.tsx
const isOpenAPISpec = (content: string) => {
  try {
    const parsed = JSON.parse(content);
    return parsed.openapi || parsed.swagger;
  } catch {
    return content.includes('openapi:') || content.includes('swagger:');
  }
};
```

## 2. Flutter эквиваленты и паттерны

### 2.1 HTTP клиент - dio

#### Настройка dio
```dart
// lib/core/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.novaspec.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static Dio get dio => _dio;

  // Интерцепторы
  static void setupInterceptors() {
    // Логирование запросов
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));

    // Обработка ошибок
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));

    // Добавление токена авторизации
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  static void _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        throw ApiException('Connection timeout');
      case DioErrorType.receiveTimeout:
        throw ApiException('Receive timeout');
      case DioErrorType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 401:
            throw ApiException('Unauthorized');
          case 403:
            throw ApiException('Forbidden');
          case 404:
            throw ApiException('Not found');
          case 500:
            throw ApiException('Server error');
          default:
            throw ApiException('HTTP Error: $statusCode');
        }
      default:
        throw ApiException('Network error');
    }
  }

  static Future<String?> _getAuthToken() async {
    // Получение токена из secure storage
    return await SecureStorageService.getToken();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}
```

### 2.2 AI Assistant API сервис

#### AI API сервис
```dart
// lib/features/ai_assistant/services/ai_api_service.dart
import 'package:dio/dio.dart';
import '../models/message.dart';
import '../models/chat_history.dart';
import '../../../core/services/api_service.dart';

class AiApiService {
  final Dio _dio = ApiService.dio;

  Future<List<String>> getModels() async {
    try {
      final response = await _dio.get('/ai/models');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((model) => model.toString()).toList();
      } else {
        throw ApiException('Failed to load models');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<String> sendMessage({
    required String message,
    required String model,
    required List<Message> history,
  }) async {
    try {
      final response = await _dio.post('/ai/chat', data: {
        'message': message,
        'model': model,
        'history': history.map((m) => m.toJson()).toList(),
      });

      if (response.statusCode == 200) {
        return response.data['response'] as String;
      } else {
        throw ApiException('Failed to send message');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<String> generateFromTemplate({
    required String templateId,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      final response = await _dio.post('/ai/template', data: {
        'templateId': templateId,
        'parameters': parameters,
      });

      if (response.statusCode == 200) {
        return response.data['content'] as String;
      } else {
        throw ApiException('Failed to generate from template');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Stream<String> sendMessageStream({
    required String message,
    required String model,
    required List<Message> history,
  }) async* {
    try {
      final response = await _dio.post(
        '/ai/chat/stream',
        data: {
          'message': message,
          'model': model,
          'history': history.map((m) => m.toJson()).toList(),
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream;
      await for (final chunk in stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data.isNotEmpty && data != '[DONE]') {
              yield data;
            }
          }
        }
      }
    } on DioError catch (e) {
      throw ApiException('Stream error: ${e.message}');
    }
  }
}
```

### 2.3 File System API сервис

#### File API сервис
```dart
// lib/features/file_explorer/services/file_api_service.dart
import 'package:dio/dio.dart';
import '../models/file_node.dart';
import '../models/file_reference.dart';
import '../../../core/services/api_service.dart';

class FileApiService {
  final Dio _dio = ApiService.dio;

  Future<List<FileNode>> loadFiles() async {
    try {
      final response = await _dio.get('/files');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FileNode.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load files');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<String> loadFileContent(String path) async {
    try {
      final response = await _dio.get('/files/content', queryParameters: {
        'path': path,
      });

      if (response.statusCode == 200) {
        return response.data['content'] as String;
      } else {
        throw ApiException('Failed to load file content');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<void> saveFile(String path, String content) async {
    try {
      final response = await _dio.put('/files', data: {
        'path': path,
        'content': content,
      });

      if (response.statusCode != 200) {
        throw ApiException('Failed to save file');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<void> createFile(String path, String content) async {
    try {
      final response = await _dio.post('/files', data: {
        'path': path,
        'content': content,
      });

      if (response.statusCode != 201) {
        throw ApiException('Failed to create file');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final response = await _dio.delete('/files', queryParameters: {
        'path': path,
      });

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete file');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<List<FileReference>> searchFiles(String query) async {
    try {
      final response = await _dio.get('/files/search', queryParameters: {
        'q': query,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FileReference.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to search files');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }
}
```

### 2.4 Templates API сервис

#### Templates API сервис
```dart
// lib/features/templates/services/template_api_service.dart
import 'package:dio/dio.dart';
import '../models/template.dart';
import '../../../core/services/api_service.dart';

class TemplateApiService {
  final Dio _dio = ApiService.dio;

  Future<List<Template>> getTemplates() async {
    try {
      final response = await _dio.get('/templates');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Template.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load templates');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<Template> getTemplate(String id) async {
    try {
      final response = await _dio.get('/templates/$id');
      
      if (response.statusCode == 200) {
        return Template.fromJson(response.data);
      } else {
        throw ApiException('Failed to load template');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<Template> createTemplate(Template template) async {
    try {
      final response = await _dio.post('/templates', data: template.toJson());

      if (response.statusCode == 201) {
        return Template.fromJson(response.data);
      } else {
        throw ApiException('Failed to create template');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<Template> updateTemplate(String id, Template template) async {
    try {
      final response = await _dio.put('/templates/$id', data: template.toJson());

      if (response.statusCode == 200) {
        return Template.fromJson(response.data);
      } else {
        throw ApiException('Failed to update template');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      final response = await _dio.delete('/templates/$id');

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete template');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }
}
```

### 2.5 Settings API сервис

#### Settings API сервис
```dart
// lib/features/settings/services/settings_api_service.dart
import 'package:dio/dio.dart';
import '../models/settings.dart';
import '../../../core/services/api_service.dart';

class SettingsApiService {
  final Dio _dio = ApiService.dio;

  Future<Settings> getSettings() async {
    try {
      final response = await _dio.get('/settings');
      
      if (response.statusCode == 200) {
        return Settings.fromJson(response.data);
      } else {
        throw ApiException('Failed to load settings');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<Settings> updateSettings(Settings settings) async {
    try {
      final response = await _dio.put('/settings', data: settings.toJson());

      if (response.statusCode == 200) {
        return Settings.fromJson(response.data);
      } else {
        throw ApiException('Failed to update settings');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<void> resetSettings() async {
    try {
      final response = await _dio.post('/settings/reset');

      if (response.statusCode != 200) {
        throw ApiException('Failed to reset settings');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }
}
```

## 3. Repository паттерн

### 3.1 Базовый Repository
```dart
// lib/core/repositories/base_repository.dart
import 'package:dio/dio.dart';
import '../services/api_service.dart';

abstract class BaseRepository {
  final Dio _dio = ApiService.dio;

  Future<T> _executeRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await request();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return parser(response.data);
      } else {
        throw ApiException('Request failed with status: ${response.statusCode}');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<List<T>> _executeListRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await request();
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => parser(item)).toList();
      } else {
        throw ApiException('Request failed with status: ${response.statusCode}');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }

  Future<void> _executeVoidRequest(Future<Response> Function() request) async {
    try {
      final response = await request();
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException('Request failed with status: ${response.statusCode}');
      }
    } on DioError catch (e) {
      throw ApiException('Network error: ${e.message}');
    }
  }
}
```

### 3.2 AI Assistant Repository
```dart
// lib/features/ai_assistant/repositories/ai_repository.dart
import '../models/message.dart';
import '../models/chat_history.dart';
import '../services/ai_api_service.dart';
import '../../../core/repositories/base_repository.dart';

class AiRepository extends BaseRepository {
  final AiApiService _apiService = AiApiService();

  Future<List<String>> getModels() async {
    return _executeListRequest(
      () => _apiService._dio.get('/ai/models'),
      (data) => data.toString(),
    );
  }

  Future<String> sendMessage({
    required String message,
    required String model,
    required List<Message> history,
  }) async {
    return _executeRequest(
      () => _apiService._dio.post('/ai/chat', data: {
        'message': message,
        'model': model,
        'history': history.map((m) => m.toJson()).toList(),
      }),
      (data) => data['response'] as String,
    );
  }

  Stream<String> sendMessageStream({
    required String message,
    required String model,
    required List<Message> history,
  }) async* {
    yield* _apiService.sendMessageStream(
      message: message,
      model: model,
      history: history,
    );
  }
}
```

## 4. State Management с API

### 4.1 Repository с Provider
```dart
// lib/features/ai_assistant/providers/ai_provider.dart
import 'package:flutter/foundation.dart';
import '../repositories/ai_repository.dart';
import '../models/message.dart';
import '../models/chat_history.dart';

class AiProvider extends ChangeNotifier {
  final AiRepository _repository = AiRepository();

  List<String> _models = [];
  List<String> get models => _models;

  List<ChatHistory> _chatHistory = [];
  List<ChatHistory> get chatHistory => _chatHistory;

  List<Message> _currentMessages = [];
  List<Message> get currentMessages => _currentMessages;

  String _selectedModel = "GPT-5";
  String get selectedModel => _selectedModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadModels() async {
    _setLoading(true);
    _clearError();

    try {
      _models = await _repository.getModels();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendMessage(String message) async {
    _setLoading(true);
    _clearError();

    try {
      final userMessage = Message(role: 'user', content: message);
      _currentMessages.add(userMessage);
      notifyListeners();

      final response = await _repository.sendMessage(
        message: message,
        model: _selectedModel,
        history: _currentMessages,
      );

      final assistantMessage = Message(role: 'assistant', content: response);
      _currentMessages.add(assistantMessage);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  void createNewChat(String title) {
    _chatHistory.add(ChatHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      messages: List.from(_currentMessages),
    ));
    _currentMessages.clear();
    notifyListeners();
  }

  void loadChat(String chatId) {
    final chat = _chatHistory.firstWhere((c) => c.id == chatId);
    _currentMessages = List.from(chat.messages);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
```

## 5. Офлайн поддержка и кэширование

### 5.1 Local storage сервис
```dart
// lib/core/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  Future<void> saveObject(String key, Map<String, dynamic> value) async {
    await _prefs?.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getObject(String key) async {
    final value = await _prefs?.getString(key);
    if (value != null) {
      return jsonDecode(value);
    }
    return null;
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
```

### 5.2 Кэширующий Repository
```dart
// lib/core/repositories/caching_repository.dart
import '../services/storage_service.dart';

abstract class CachingRepository extends BaseRepository {
  final StorageService _storage = StorageService();

  Future<T?> _getCachedData<T>(String key, T Function(dynamic) parser) async {
    try {
      final data = await _storage.getObject(key);
      if (data != null) {
        return parser(data);
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  Future<void> _cacheData(String key, dynamic data) async {
    try {
      await _storage.saveObject(key, data);
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<void> _clearCache(String key) async {
    try {
      await _storage.remove(key);
    } catch (e) {
      // Ignore cache errors
    }
  }
}
```

## 6. WebSocket интеграция

### 6.1 WebSocket сервис
```dart
// lib/core/services/websocket_service.dart
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static StreamController? _controller;

  static Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _controller = StreamController.broadcast();

      _channel!.stream.listen(
        (data) {
          _controller?.add(data);
        },
        onError: (error) {
          _controller?.addError(error);
        },
        onDone: () {
          _controller?.close();
        },
      );
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  static Stream<dynamic> get stream => _controller?.stream ?? Stream.empty();

  static void send(dynamic data) {
    _channel?.sink.add(data);
  }

  static Future<void> disconnect() async {
    await _channel?.sink.close();
    await _controller?.close();
  }
}
```

## 7. Тестирование API

### 7.1 Mock API сервис
```dart
// lib/core/services/mock_api_service.dart
import 'package:dio/dio.dart';
import 'api_service.dart';

class MockApiService {
  static Dio createMockDio() {
    final dio = Dio();
    
    // Mock adapter
    dio.httpClientAdapter = MockAdapter();
    
    return dio;
  }
}

class MockAdapter extends HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? onCancel,
  ) async {
    // Mock responses based on path and method
    switch (options.path) {
      case '/ai/models':
        return ResponseBody.fromString(
          jsonEncode(['GPT-5', 'GPT-5 Mini', 'Claude 4']),
          200,
          headers: {'content-type': 'application/json'},
        );
      
      case '/ai/chat':
        return ResponseBody.fromString(
          jsonEncode({'response': 'Mock AI response'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      
      default:
        return ResponseBody.fromString(
          jsonEncode({'error': 'Not found'}),
          404,
          headers: {'content-type': 'application/json'},
        );
    }
  }
}
```

### 7.2 Unit тесты для Repository
```dart
// test/features/ai_assistant/repositories/ai_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:novaspec/features/ai_assistant/repositories/ai_repository.dart';
import 'package:novaspec/features/ai_assistant/services/ai_api_service.dart';

class MockAiApiService extends Mock implements AiApiService {}

void main() {
  group('AiRepository', () {
    late AiRepository repository;
    late MockAiApiService mockApiService;

    setUp(() {
      mockApiService = MockAiApiService();
      repository = AiRepository();
    });

    test('should get models successfully', () async {
      // Arrange
      final expectedModels = ['GPT-5', 'GPT-5 Mini'];
      
      // Act
      final result = await repository.getModels();
      
      // Assert
      expect(result, expectedModels);
    });

    test('should throw exception on network error', () async {
      // Arrange
      when(mockApiService.getModels()).thenThrow(Exception('Network error'));
      
      // Act & Assert
      expect(
        () => repository.getModels(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
```

## 8. Резюме и рекомендации

### 8.1 Текущее состояние
- **Нет реальных API вызовов** в TypeScript проекте
- Все данные являются **моками**
- Потенциальные интеграции: AI, File System, Templates, Settings

### 8.2 Рекомендуемый стек для Flutter
- **HTTP клиент**: dio
- **State management**: Provider + Repository
- **Local storage**: shared_preferences
- **Secure storage**: flutter_secure_storage
- **WebSocket**: web_socket_channel
- **Caching**: Repository pattern + local storage

### 8.3 План реализации
1. **Настроить dio** с интерцепторами
2. **Создать Repository** для каждого домена
3. **Интегрировать с Provider** для состояния
4. **Добавить кэширование** для офлайн поддержки
5. **Реализовать WebSocket** для real-time функций
6. **Написать тесты** для всех API сервисов

### 8.4 Оценка трудозатрат
- **Настройка API сервиса**: 8-12 часов
- **Repository реализация**: 16-24 часа
- **Provider интеграция**: 8-12 часов
- **Кэширование и офлайн**: 12-16 часов
- **WebSocket интеграция**: 8-12 часов
- **Тестирование**: 16-20 часов

**Итого**: 68-96 часов на полную реализацию API интеграций