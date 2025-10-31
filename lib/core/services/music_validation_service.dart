import 'package:dio/dio.dart';
import '../../shared/models/validation_result.dart';

class MusicValidationService {
  final Dio _dio;
  
  MusicValidationService(this._dio) {
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
  
  /// Валидация API ключа gen-api.ru
  Future<ValidationResult> validateApiKey(String apiKey) async {
    if (apiKey.length < 10) {
      return ValidationResult.error('Неверный формат API ключа gen-api.ru');
    }
    
    try {
      final response = await _dio.get(
        'https://api.gen-api.ru/api/v1/user',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );
      
      if (response.statusCode == 200) {
        final userData = response.data;
        final balance = userData['balance'] ?? 0;
        final currency = userData['currency'] ?? 'RUB';
        
        return ValidationResult.success(
          'API ключ gen-api.ru действителен',
          details: 'Баланс: $balance $currency',
        );
      } else {
        return ValidationResult.error('Неверный статус ответа: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return ValidationResult.error('Неверный API ключ gen-api.ru');
      } else if (e.response?.statusCode == 403) {
        return ValidationResult.error('Доступ запрещен');
      } else if (e.response?.statusCode == 429) {
        return ValidationResult.error('Превышен лимит запросов');
      } else {
        return ValidationResult.error('Ошибка подключения: ${e.message}');
      }
    } catch (e) {
      return ValidationResult.error('Ошибка валидации: ${e.toString()}');
    }
  }
  
  /// Получение баланса пользователя
  Future<double> getBalance(String apiKey) async {
    try {
      final response = await _dio.get(
        'https://api.gen-api.ru/api/v1/user',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );
      
      if (response.statusCode == 200) {
        final userData = response.data;
        return double.tryParse(userData['balance']?.toString() ?? '0') ?? 0.0;
      } else {
        throw Exception('Failed to get balance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting balance: $e');
    }
  }
  
  /// Запуск генерации музыки
  Future<Map<String, dynamic>> generateMusic(
    String apiKey,
    String genre,
    String? title,
    String? lyrics,
  ) async {
    try {
      final response = await _dio.post(
        'https://api.gen-api.ru/api/v1/networks/suno',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
        data: {
          'prompt': lyrics ?? 'Generate $genre music',
          'tags': genre,
          'title': title ?? '$genre Music',
          'make_instrumental': false,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to start generation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting music generation: $e');
    }
  }
  
  /// Проверка статуса генерации
  Future<Map<String, dynamic>> getGenerationStatus(String apiKey, int requestId) async {
    try {
      final response = await _dio.get(
        'https://api.gen-api.ru/api/v1/request/get/$requestId',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting generation status: $e');
    }
  }
  
  /// Валидация жанра
  ValidationResult validateGenre(String genre) {
    const supportedGenres = {
      'pop': 'Поп',
      'russian rap': 'Русский рэп',
      'rock': 'Рок',
      'jazz': 'Джаз',
      'classic': 'Классика',
      'electric music': 'Электронная музыка',
      'hip-hop': 'Хип-хоп',
      'r&b': 'R&B',
    };
    
    if (supportedGenres.containsKey(genre.toLowerCase())) {
      return ValidationResult.success('Жанр поддерживается');
    } else {
      return ValidationResult.error(
        'Неподдерживаемый жанр: $genre',
        details: 'Поддерживаемые жанры: ${supportedGenres.keys.join(', ')}',
      );
    }
  }
  
  /// Получение локализованных жанров
  Map<String, String> getLocalizedGenres(String locale) {
    if (locale.startsWith('ru')) {
      return {
        'Поп': 'pop',
        'Русский рэп': 'russian rap',
        'Рок': 'rock',
        'Джаз': 'jazz',
        'Классика': 'classic',
        'Электронная музыка': 'electric music',
        'Хип-хоп': 'hip-hop',
        'R&B': 'r&b',
      };
    } else {
      return {
        'Pop Music': 'pop',
        'Russian rap': 'russian rap',
        'Rock': 'rock',
        'Jazz': 'jazz',
        'Classic': 'classic',
        'Electro music': 'electric music',
        'Hip-hop': 'hip-hop',
        'R&B': 'r&b',
      };
    }
  }
}
