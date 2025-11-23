import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/logs/musication_log.dart';
import '../models/requests/musication_request.dart';
import '../models/responses/musication_api_response.dart';
import '../../musication/providers/musication_provider.dart';
import '../../../core/providers/settings_provider.dart';

class MusicationService {
  static const String _logsKey = 'musication_logs';
  static const String _pendingRequestKey = 'pending_musication_request';

  final Dio _dio;
  final SharedPreferences _prefs;
  final SettingsProvider _settingsProvider;
  final StreamController<MusicationLog> _logController =
      StreamController.broadcast();
  Timer? _pollingTimer;
  Timer? _timeoutTimer;

  MusicationService(this._dio, this._prefs, this._settingsProvider);

  Stream<MusicationLog> get logStream => _logController.stream;

  /// Получение базового URL API
  String get _baseApiUrl {
    final mockEnabled = _settingsProvider.mockGenApiEnabled;
    final mockUrl = _settingsProvider.mockGenApiUrl;
    
    debugPrint('🔧 _baseApiUrl: mockEnabled=$mockEnabled, mockUrl=$mockUrl');
    
    if (mockEnabled) {
      debugPrint('🔧 Returning mock URL: $mockUrl');
      return mockUrl;
    }
    
    debugPrint('🔧 Returning real API URL: https://api.gen-api.ru');
    return 'https://api.gen-api.ru';
  }

  /// Получение баланса
  Future<int> getMusicBalance() async {
    // Используем токен из SettingsProvider вместо SharedPreferences
    final apiKey = _settingsProvider.musicToken;
    if (apiKey.isEmpty) {
      throw Exception('API ключ gen-api.ru не настроен');
    }

    final url = '$_baseApiUrl/api/v1/user';
    debugPrint('🎵 MusicationService: Запрос баланса на $url');
    debugPrint('🎵 Mock enabled: ${_settingsProvider.mockGenApiEnabled}');
    debugPrint('🎵 Mock URL: ${_settingsProvider.mockGenApiUrl}');
    debugPrint('🎵 Using token: ${apiKey.substring(0, 10)}...');

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        return userData['balance'] as int? ?? 0;
      } else {
        throw Exception('Неверный статус ответа: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Неверный API ключ gen-api.ru');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Доступ запрещен');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Превышен лимит запросов');
      } else {
        throw Exception('Ошибка подключения: ${e.message}');
      }
    } catch (e) {
      throw Exception('Ошибка получения баланса: $e');
    }
  }

  /// Обновление баланса (кэширование)
  Future<void> refreshMusicBalance() async {
    try {
      final balance = await getMusicBalance();
      // Сохраняем в кэш на 5 минут
      await _prefs.setString(
        'music_balance_cache',
        json.encode({
          'balance': balance,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (e) {
      // Если ошибка, пытаемся взять из кэша
      final cache = _prefs.getString('music_balance_cache');
      if (cache != null) {
        final data = json.decode(cache) as Map<String, dynamic>;
        final timestamp = data['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Если кэш не старше 5 минут, используем его
        if (now - timestamp < 5 * 60 * 1000) {
          return;
        }
      }
      rethrow;
    }
  }

  /// Получение кэшированного баланса
  int? getCachedBalance() {
    final cache = _prefs.getString('music_balance_cache');
    if (cache != null) {
      final data = json.decode(cache) as Map<String, dynamic>;
      final timestamp = data['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Если кэш не старше 5 минут
      if (now - timestamp < 5 * 60 * 1000) {
        return data['balance'] as int?;
      }
    }
    return null;
  }

  /// Начать музикацию
  Future<void> startMusication({
    required String projectPath,
    required String selectedText,
    required String genre,
    MusicationProvider? provider,
  }) async {
    // Используем токен из SettingsProvider
    final apiKey = _settingsProvider.musicToken;
    if (apiKey.isEmpty) {
      throw Exception('API ключ gen-api.ru не настроен');
    }

    // Проверяем баланс
    final balance = await getMusicBalance();
    if (balance <= 0) {
      throw Exception('Недостаточно средств на балансе');
    }

    // Обновляем провайдер - начинаем генерацию Lyrics
    provider?.setGeneratingLyrics();

    // Генерируем Lyrics
    final lyrics = await _generateLyrics(selectedText, genre);
    
    // Создаем запрос
    final request = MusicationRequest.create(
      projectPath: projectPath,
      selectedText: selectedText,
      genre: genre,
      lyrics: lyrics,
    );

    // Создаем лог
    final log = MusicationLog.fromRequest(request);
    await _saveLog(log);
    _logController.add(log);

    try {
      // Генерируем музыку
      final response = await _generateMusic(apiKey, genre, lyrics);

      if (response.requestId != null) {
        // Сохраняем ID запроса в лог
        final updatedLog = log.copyWith(
          fileUuid: response.requestId.toString(),
          status: 'processing',
        );
        await _saveLog(updatedLog);
        _logController.add(updatedLog);

        // Сохраняем ожидающий запрос
        await _savePendingRequest(request.id);

        // Обновляем провайдер
        provider?.setGeneratingAudio(response.requestId!);

        // Начинаем опрос статуса
        _startPolling(apiKey, response.requestId!, provider);
      } else {
        throw Exception('Не получен ID запроса от API');
      }
    } catch (e) {
      final errorLog = log.copyWith(
        status: 'failed',
        errorMessage: e.toString(),
        completedAt: DateTime.now(),
      );
      await _saveLog(errorLog);
      _logController.add(errorLog);

      provider?.setError(e.toString());
      rethrow;
    }
  }

  /// Генерация lyrics
  Future<String> _generateLyrics(String selectedText, String genre) async {
    debugPrint('🎵 Generating lyrics for genre: $genre');
    
    final selectedModel = _settingsProvider.selectedAiModel;
    if (selectedModel.isEmpty) {
      throw Exception('AI модель не выбрана. Выберите модель в AI-ассистенте.');
    }

    final provider = _settingsProvider.selectedProvider;
    
    // Debug: показать тип доступа Z.AI
    if (provider == AIProvider.zai) {
      debugPrint('🎵 Z.AI Access Type: ${_settingsProvider.zaiAccessType}');
      debugPrint('🎵 Z.AI Base URL: ${_settingsProvider.getDefaultBaseUrl()}');
    }
    
    final prompt = '''Составь текст песни, чтобы зачитать данные требования в жанре $genre.
Текст должен быть сделан в виде Lyrics пригодным для Suno.
В ответе не указывай ничего лишнего, исключительно Lyrics.

Требования: $selectedText''';

    try {
      String url;
      Map<String, dynamic> requestData;
      Map<String, String> headers;

      switch (provider) {
        case AIProvider.anthropic:
          url = '${_settingsProvider.getDefaultBaseUrl()}/v1/messages';
          headers = {
            'x-api-key': _settingsProvider.getProviderToken(provider) ?? '',
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          };
          requestData = {
            'model': selectedModel,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'max_tokens': 1024,
          };
          break;

        default:
          // Для всех остальных провайдеров используем OpenAI-совместимый формат
          url = '${_settingsProvider.getDefaultBaseUrl()}/chat/completions';
          headers = {
            'Authorization': 'Bearer ${_settingsProvider.getProviderToken(provider) ?? ''}',
            'Content-Type': 'application/json',
          };
          requestData = {
            'model': selectedModel,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'max_tokens': 2048, // Увеличен лимит для Z.AI reasoning_content
            'temperature': 0.7,
          };
          break;
      }

      debugPrint('🎵 Calling AI API: $url with model: $selectedModel');
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(minutes: 3), // Увеличен таймаут для AI генерации
        ),
        data: requestData,
      );

      if (response.statusCode == 200) {
        String? lyrics;

        // Anthropic формат
        if (provider == AIProvider.anthropic) {
          final content = response.data['content'] as List?;
          if (content != null && content.isNotEmpty) {
            lyrics = content[0]['text'] as String?;
          }
        } else {
          // OpenAI-совместимый формат
          final choices = response.data['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices[0]['message'];
            
            // Пробуем получить content
            lyrics = message['content'] as String?;
            
            // Если content пустой, проверяем reasoning_content (Z.AI)
            if (lyrics == null || lyrics.trim().isEmpty) {
              lyrics = message['reasoning_content'] as String?;
            }
          }
        }

        if (lyrics != null && lyrics.trim().isNotEmpty) {
          debugPrint('🎵 Lyrics generated successfully');
          debugPrint('🎵 Lyrics length: ${lyrics.length} characters');
          return lyrics.trim();
        }

        throw Exception('Пустой ответ от AI модели');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('🎵 Error generating lyrics: $e');
      throw Exception('Ошибка генерации lyrics: ${e.toString()}');
    }
  }

  /// Генерация музыки через gen-api.ru
  Future<MusicationApiResponse> _generateMusic(
    String apiKey,
    String genre,
    String lyrics,
  ) async {
    try {
      final response = await _dio.post(
        '$_baseApiUrl/api/v1/networks/suno',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'prompt': lyrics,
          'tags': genre,
          'title': 'NovaSpec Music',
          'make_instrumental': false,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MusicationApiResponse.fromMap(response.data);
      } else if (response.statusCode == 402) {
        throw Exception('Недостаточно средств на балансе');
      } else {
        throw Exception('Ошибка генерации музыки: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw Exception('Недостаточно средств на балансе');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Неверный API ключ gen-api.ru');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Превышен лимит запросов');
      } else {
        throw Exception('Ошибка API: ${e.message}');
      }
    } catch (e) {
      throw Exception('Ошибка генерации музыки: $e');
    }
  }

  /// Начать опрос статуса
  void _startPolling(
    String apiKey,
    int requestId,
    MusicationProvider? provider,
  ) {
    const pollingInterval = Duration(seconds: 5);
    const timeoutDuration = Duration(minutes: 10);

    _pollingTimer = Timer.periodic(pollingInterval, (timer) async {
      try {
        final response = await _checkGenerationStatus(apiKey, requestId);
        final log = await _getLogByRequestId(requestId);

        if (log != null) {
          // Обновляем прогресс
          final progress = (response.progress ?? 0) / 100.0;
          provider?.updateProgress(progress);

          if (response.isSuccess && response.hasResult) {
            // Генерация завершена
            timer.cancel();

            final completedLog = log.copyWith(
              status: 'completed',
              completedAt: DateTime.now(),
              cost: response.cost,
            );
            await _saveLog(completedLog);
            _logController.add(completedLog);

            // Скачиваем файлы
            final downloadedFiles = await _downloadGeneratedFiles(response);

            final finalLog = completedLog.copyWith(
              generatedFiles: downloadedFiles,
            );
            await _saveLog(finalLog);
            _logController.add(finalLog);

            provider?.setSavingAudio();

            // Завершаем процесс
            provider?.setCompleted();

            // Очищаем ожидающий запрос
            await _clearPendingRequest();
          } else if (response.isFailed) {
            // Ошибка генерации
            timer.cancel();

            final errorLog = log.copyWith(
              status: 'failed',
              errorMessage: response.error ?? 'Ошибка генерации',
              completedAt: DateTime.now(),
            );
            await _saveLog(errorLog);
            _logController.add(errorLog);

            provider?.setError(response.error ?? 'Ошибка генерации');

            // Очищаем ожидающий запрос
            await _clearPendingRequest();
          }
        }
      } catch (e) {
        // Ошибка при опросе - продолжаем опрос
        debugPrint('Ошибка опроса статуса: $e');
      }
    });

    // Таймаут
    _timeoutTimer = Timer(timeoutDuration, () {
      _handleTimeout(requestId, provider);
    });
  }

  /// Проверка статуса генерации
  Future<MusicationApiResponse> _checkGenerationStatus(
    String apiKey,
    int requestId,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseApiUrl/api/v1/request/get/$requestId',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      if (response.statusCode == 200) {
        return MusicationApiResponse.fromMap(response.data);
      } else {
        throw Exception('Ошибка получения статуса: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка проверки статуса: $e');
    }
  }

  /// Обработка таймаута
  void _handleTimeout(int requestId, MusicationProvider? provider) {
    _pollingTimer?.cancel();

    _markAsFailed(requestId, 'Таймаут генерации (10 минут)');

    provider?.setError('Таймаут генерации музыки');

    _clearPendingRequest();
  }

  /// Скачивание сгенерированных файлов
  Future<List<String>> _downloadGeneratedFiles(
    MusicationApiResponse response,
  ) async {
    final files = <String>[];

    if (response.result != null) {
      // Выбираем директорию для сохранения
      final directory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Выберите директорию для сохранения музыки',
      );

      if (directory != null) {
        for (final audio in response.result!) {
          try {
            final fileName = audio.fileName;
            final filePath = path.join(directory, fileName);

            // Скачиваем файл
            final dio = Dio();
            await dio.download(
              audio.url,
              filePath,
              onReceiveProgress: (received, total) {
                if (total != -1) {
                  final progress = received / total;
                  debugPrint(
                    'Скачивание $fileName: ${(progress * 100).toStringAsFixed(1)}%',
                  );
                }
              },
            );

            files.add(filePath);
          } catch (e) {
            debugPrint('Ошибка скачивания файла ${audio.title}: $e');
          }
        }
      }
    }

    return files;
  }

  /// Отмена музикации
  Future<void> cancelMusication() async {
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    await _clearPendingRequest();
  }

  /// Сохранение лога
  Future<void> _saveLog(MusicationLog log) async {
    final logs = await getLogs();
    logs.add(log);

    // Сохраняем только последние 100 логов
    if (logs.length > 100) {
      logs.removeRange(0, logs.length - 100);
    }

    final logsJson = logs.map((l) => l.toMap()).toList();
    await _prefs.setString(_logsKey, json.encode(logsJson));
  }

  /// Получение всех логов
  Future<List<MusicationLog>> getLogs() async {
    final logsJson = _prefs.getString(_logsKey);
    if (logsJson == null) return [];

    try {
      final logsList = json.decode(logsJson) as List;
      return logsList
          .map((e) => MusicationLog.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Ошибка загрузки логов музикации: $e');
      return [];
    }
  }

  /// Получение лога по ID запроса
  Future<MusicationLog?> _getLogByRequestId(int requestId) async {
    final logs = await getLogs();
    try {
      return logs.firstWhere((log) => log.fileUuid == requestId.toString());
    } catch (e) {
      return null;
    }
  }

  /// Пометить как неудачный
  Future<void> _markAsFailed(int requestId, String error) async {
    final log = await _getLogByRequestId(requestId);
    if (log != null) {
      final failedLog = log.copyWith(
        status: 'failed',
        errorMessage: error,
        completedAt: DateTime.now(),
      );
      await _saveLog(failedLog);
      _logController.add(failedLog);
    }
  }

  /// Сохранение ожидающего запроса
  Future<void> _savePendingRequest(String requestId) async {
    await _prefs.setString(_pendingRequestKey, requestId);
  }

  /// Очистка ожидающего запроса
  Future<void> _clearPendingRequest() async {
    await _prefs.remove(_pendingRequestKey);
  }

  /// Получение ожидающего запроса
  Future<String?> getPendingRequest() async {
    return _prefs.getString(_pendingRequestKey);
  }

  /// Проверка наличия ожидающей генерации при запуске
  Future<void> checkForPendingGeneration() async {
    final pendingRequestId = await getPendingRequest();
    if (pendingRequestId != null) {
      final apiKey = _settingsProvider.musicToken;
      if (apiKey.isNotEmpty) {
        // TODO: Возобновить опрос статуса
        debugPrint('Найдена ожидающая генерация: $pendingRequestId');
      }
    }
  }

  /// Очистка ресурсов
  void dispose() {
    _pollingTimer?.cancel();
    _timeoutTimer?.cancel();
    _logController.close();
  }
}
