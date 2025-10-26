import 'package:dio/dio.dart';
import '../../shared/models/validation_result.dart';
import '../../core/providers/settings_provider.dart';

class AIValidationService {
  final Dio _dio;

  AIValidationService(this._dio) {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'User-Agent': 'NovaSpec/1.0',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Отключаем проверку SSL для отладки
      validateStatus: (status) => status != null && status < 600,
    );

    // Включим детальное логирование для отладки
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (obj) {
          print('DIO DEBUG: $obj');
        },
      ),
    );
  }

  /// Валидация API ключа для указанного провайдера по имени
  Future<ValidationResult> validateProvider(
    String providerName,
    String apiKey, {
    String? baseUrl,
  }) async {
    try {
      final provider = AIProvider.values.firstWhere(
        (p) => p.name == providerName,
        orElse: () => AIProvider.openai,
      );
      return await validateApiKey(provider, apiKey, baseUrl);
    } catch (e) {
      return ValidationResult.error('Ошибка валидации: ${e.toString()}');
    }
  }

  /// Валидация API ключа для указанного провайдера
  Future<ValidationResult> validateApiKey(
    AIProvider provider,
    String apiKey,
    String? baseUrl,
  ) async {
    try {
      switch (provider) {
        case AIProvider.openai:
          return await _validateOpenAI(apiKey, baseUrl);
        case AIProvider.anthropic:
          return await _validateAnthropic(apiKey, baseUrl);
        case AIProvider.cerebras:
          return await _validateCerebras(apiKey, baseUrl);
        case AIProvider.groq:
          return await _validateGroq(apiKey, baseUrl);
        case AIProvider.openrouter:
          return await _validateOpenRouter(apiKey, baseUrl);
        case AIProvider.openaiCompetitive:
          return await _validateOpenAICompetitive(apiKey, baseUrl);
        case AIProvider.lmStudio:
          return await _validateLMStudio(apiKey, baseUrl);
        case AIProvider.ollama:
          return await _validateOllama(apiKey, baseUrl);
        case AIProvider.zai:
          return await _validateZAI(apiKey, baseUrl);
      }
    } catch (e) {
      return ValidationResult.error('Ошибка валидации: ${e.toString()}');
    }
  }

  /// Валидация OpenAI API ключа
  Future<ValidationResult> _validateOpenAI(
    String apiKey,
    String? baseUrl,
  ) async {
    if (!apiKey.startsWith('sk-') || apiKey.length < 20) {
      return ValidationResult.error('Неверный формат API ключа OpenAI');
    }

    try {
      final url = '${baseUrl ?? 'https://api.openai.com/v1'}/models';
      final response = await _dio.getUri(
        Uri.parse(url),
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      if (response.statusCode == 200) {
        final models = response.data['data'] as List;
        return ValidationResult.success(
          'API ключ OpenAI действителен',
          details: 'Доступно моделей: ${models.length}',
        );
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ OpenAI');
      } else if (e.response?.statusCode == 429) {
        return ValidationResult.error('Превышен лимит запросов');
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    }
  }

  /// Валидация Anthropic API ключа
  Future<ValidationResult> _validateAnthropic(
    String apiKey,
    String? baseUrl,
  ) async {
    if (!apiKey.startsWith('sk-ant-') || apiKey.length < 30) {
      return ValidationResult.error('Неверный формат API ключа Anthropic');
    }

    try {
      final response = await _dio.get(
        '${baseUrl ?? 'https://api.anthropic.com/v1'}/models',
        options: Options(
          headers: {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'},
        ),
      );

      if (response.statusCode == 200) {
        final models = response.data['data'] as List;
        return ValidationResult.success(
          'API ключ Anthropic действителен',
          details: 'Доступно моделей: ${models.length}',
        );
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ Anthropic');
      } else if (e.response?.statusCode == 429) {
        return ValidationResult.error('Превышен лимит запросов');
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    }
  }

  /// Валидация Cerebras API ключа
  Future<ValidationResult> _validateCerebras(
    String apiKey,
    String? baseUrl,
  ) async {
    if (apiKey.isEmpty) {
      return ValidationResult.error('API ключ Cerebras не может быть пустым');
    }

    try {
      // Cerebras использует OpenAI-совместимый эндпоинт
      final url = '${baseUrl ?? 'https://api.cerebras.ai'}/v1/models';
      print('DEBUG: Cerebras Request URL: $url');
      print('DEBUG: Cerebras Request Headers: {"Authorization": "Bearer $apiKey"}');

      final response = await _dio.getUri(
        Uri.parse(url),
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      print('DEBUG: Cerebras Response Status: ${response.statusCode}');
      print('DEBUG: Cerebras Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final models = data['data'] as List;
          return ValidationResult.success(
            'API ключ Cerebras действителен',
            details: 'Доступно моделей: ${models.length}',
          );
        } else {
          return ValidationResult.success(
            'API ключ Cerebras действителен',
            details: 'Подключено успешно',
          );
        }
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DEBUG: Cerebras DioException: ${e.message}');
      print('DEBUG: Cerebras Error Type: ${e.type}');
      print('DEBUG: Cerebras Status Code: ${e.response?.statusCode}');
      print('DEBUG: Cerebras Response Data: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ Cerebras');
      } else if (e.response?.statusCode == 403) {
        return ValidationResult.error(
          'Доступ запрещен. Проверьте API ключ и права доступа',
        );
      } else if (e.response?.statusCode == 429) {
        return ValidationResult.error('Превышен лимит запросов');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return ValidationResult.error(
          'Тайм-аут подключения. Проверьте интернет-соединение',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return ValidationResult.error(
          'Ошибка подключения. Проверьте URL и интернет-соединение',
        );
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    } catch (e) {
      print('DEBUG: Cerebras General Exception: ${e.toString()}');
      return ValidationResult.error(
        'Ошибка валидации Cerebras: ${e.toString()}',
      );
    }
  }

  /// Валидация Groq API ключа
  Future<ValidationResult> _validateGroq(String apiKey, String? baseUrl) async {
    if (apiKey.length < 20) {
      return ValidationResult.error('Неверный формат API ключа Groq');
    }

    try {
      final url = '${baseUrl ?? 'https://api.groq.com/openai/v1'}/models';
      final response = await _dio.getUri(
        Uri.parse(url),
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      if (response.statusCode == 200) {
        final models = response.data['data'] as List;
        return ValidationResult.success(
          'API ключ Groq действителен',
          details: 'Доступно моделей: ${models.length}',
        );
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ Groq');
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    }
  }

  /// Валидация OpenRouter API ключа
  Future<ValidationResult> _validateOpenRouter(
    String apiKey,
    String? baseUrl,
  ) async {
    if (apiKey.isEmpty) {
      return ValidationResult.error('API ключ OpenRouter не может быть пустым');
    }

    try {
      final url = (baseUrl == null || baseUrl.isEmpty) 
          ? 'https://openrouter.ai/api/v1/models' 
          : '$baseUrl/models';
      print('DEBUG: OpenRouter Request URL: $url');
      print('DEBUG: OpenRouter Request Headers: {"Authorization": "Bearer $apiKey"}');

      final response = await _dio.getUri(
        Uri.parse(url),
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );

      print('DEBUG: OpenRouter Response Status: ${response.statusCode}');
      print('DEBUG: OpenRouter Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final models = data['data'] as List;
          return ValidationResult.success(
            'API ключ OpenRouter действителен',
            details: 'Доступно моделей: ${models.length}',
          );
        } else {
          return ValidationResult.success(
            'API ключ OpenRouter действителен',
            details: 'Подключено успешно',
          );
        }
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ OpenRouter');
      } else if (e.response?.statusCode == 403) {
        return ValidationResult.error(
          'Доступ запрещен. Проверьте API ключ и права доступа',
        );
      } else if (e.response?.statusCode == 429) {
        return ValidationResult.error('Превышен лимит запросов');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return ValidationResult.error(
          'Тайм-аут подключения. Проверьте интернет-соединение',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        print('DEBUG: OpenRouter Connection Error: ${e.message}');
        print('DEBUG: OpenRouter Error Type: ${e.type}');
        print('DEBUG: OpenRouter Error Response: ${e.response}');
        return ValidationResult.error(
          'Ошибка подключения. Проверьте URL и интернет-соединение',
        );
      } else {
        print('DEBUG: OpenRouter Unknown Error: ${e.message}');
        print('DEBUG: OpenRouter Error Type: ${e.type}');
        print('DEBUG: OpenRouter Error Response: ${e.response}');
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    } catch (e) {
      print('DEBUG: OpenRouter Exception: ${e.toString()}');
      return ValidationResult.error(
        'Ошибка валидации OpenRouter: ${e.toString()}',
      );
    }
  }

  /// Валидация OpenAI Compatible API ключа
  Future<ValidationResult> _validateOpenAICompetitive(
    String apiKey,
    String? baseUrl,
  ) async {
    if (baseUrl == null || baseUrl.isEmpty) {
      return ValidationResult.error(
        'Базовый URL обязателен для OpenAI Compatible',
      );
    }

    if (apiKey.length < 10) {
      return ValidationResult.error('Неверный формат API ключа');
    }

    try {
      final url = '$baseUrl/models';
      final response = await _dio.getUri(
        Uri.parse(url),
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      if (response.statusCode == 200) {
        final models = response.data['data'] as List?;
        return ValidationResult.success(
          'OpenAI Compatible API действителен',
          details: models != null
              ? 'Доступно моделей: ${models.length}'
              : 'Подключено успешно',
        );
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ');
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    }
  }

  /// Валидация LM Studio
  Future<ValidationResult> _validateLMStudio(
    String apiKey,
    String? baseUrl,
  ) async {
    if (baseUrl == null || baseUrl.isEmpty) {
      return ValidationResult.error('Базовый URL обязателен для LM Studio');
    }

    try {
      final url = '$baseUrl/v1/models';
      final response = await _dio.getUri(
        Uri.parse(url),
        options: apiKey.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $apiKey'})
          : null,
      );

      if (response.statusCode == 200) {
        final models = response.data['data'] as List?;
        return ValidationResult.success(
          'LM Studio доступен',
          details: models != null
              ? 'Загружено моделей: ${models.length}'
              : 'Подключено успешно',
        );
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ValidationResult.error(
        'Ошибка подключения к LM Studio: ${e.message}',
      );
    }
  }

  /// Валидация Ollama
  Future<ValidationResult> _validateOllama(
    String apiKey,
    String? baseUrl,
  ) async {
    if (baseUrl == null || baseUrl.isEmpty) {
      return ValidationResult.error('Базовый URL обязателен для Ollama');
    }

    try {
      final url = '$baseUrl/api/tags';
      final response = await _dio.getUri(
        Uri.parse(url),
        options: apiKey.isNotEmpty
          ? Options(headers: {'Authorization': 'Bearer $apiKey'})
          : null,
      );

      if (response.statusCode == 200) {
        final models = response.data['models'] as List?;
        return ValidationResult.success(
          'Ollama доступен',
          details: models != null
              ? 'Доступно моделей: ${models.length}'
              : 'Подключено успешно',
        );
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return ValidationResult.error(
        'Ошибка подключения к Ollama: ${e.message}',
      );
    }
  }

  /// Валидация Z.AI API ключа
  Future<ValidationResult> _validateZAI(String apiKey, String? baseUrl) async {
    if (apiKey.length < 10) {
      return ValidationResult.error('Неверный формат API ключа Z.AI');
    }

    try {
      // Используем правильный эндпоинт /models вместо /user
      final url = '${baseUrl ?? 'https://api.z.ai/api/paas/v4'}/models';
      final response = await _dio.getUri(
        Uri.parse(url),
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      if (response.statusCode == 200) {
        final models = response.data['data'] as List?;
        return ValidationResult.success(
          'API ключ Z.AI действителен',
          details: models != null ? 'Доступно моделей: ${models.length}' : 'Подключено успешно',
        );
      } else {
        return ValidationResult.error(
          'Неверный статус ответа: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ Z.AI');
      } else if (e.response?.statusCode == 403) {
        return ValidationResult.error('Доступ запрещен. Проверьте API ключ и права доступа');
      } else if (e.response?.statusCode == 429) {
        return ValidationResult.error('Превышен лимит запросов');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return ValidationResult.error('Тайм-аут подключения. Проверьте интернет-соединение');
      } else if (e.type == DioExceptionType.connectionError) {
        return ValidationResult.error('Ошибка подключения. Проверьте URL и интернет-соединение');
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    }
  }
}
