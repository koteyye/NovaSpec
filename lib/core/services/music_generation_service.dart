import 'dart:async';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

import '../services/file_service.dart';
import '../../shared/models/storage_result.dart';
import '../../shared/models/app_error.dart';

enum MusicGenerationStatus {
  idle,
  generatingLyrics,
  generatingMusic,
  processing,
  success,
  failed,
  cancelled,
}

class MusicGenerationRequest {
  final String requestId;
  final String filePath;
  final String genre;
  final DateTime createdAt;
  MusicGenerationStatus status;
  final List<String> generatedFiles;
  final String? error;

  MusicGenerationRequest({
    required this.requestId,
    required this.filePath,
    required this.genre,
    required this.createdAt,
    this.status = MusicGenerationStatus.idle,
    this.generatedFiles = const [],
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'filePath': filePath,
      'genre': genre,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString(),
      'generatedFiles': generatedFiles,
      'error': error,
    };
  }

  factory MusicGenerationRequest.fromJson(Map<String, dynamic> json) {
    return MusicGenerationRequest(
      requestId: json['requestId'],
      filePath: json['filePath'],
      genre: json['genre'],
      createdAt: DateTime.parse(json['createdAt']),
      status: MusicGenerationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MusicGenerationStatus.idle,
      ),
      generatedFiles: List<String>.from(json['generatedFiles'] ?? []),
      error: json['error'],
    );
  }
}

class MusicGenerationService {
  final ApiService _apiService;
  final FileService _fileService;
  final SettingsProvider _settingsProvider;

  Timer? _statusCheckTimer;
  MusicGenerationRequest? _currentRequest;
  final StreamController<MusicGenerationRequest> _statusController =
      StreamController<MusicGenerationRequest>.broadcast();

  static const String _logFileName = 'music_generation_log.json';
  static const Duration _statusCheckInterval = Duration(seconds: 2);
  static const String _genApiBaseUrl = 'https://api.gen-api.ru';

  MusicGenerationService({
    required ApiService apiService,
    required FileService fileService,
    required SettingsProvider settingsProvider,
  }) : _apiService = apiService,
       _fileService = fileService,
       _settingsProvider = settingsProvider;

  Stream<MusicGenerationRequest> get statusStream => _statusController.stream;

  MusicGenerationRequest? get currentRequest => _currentRequest;

  Future<void> initialize() async {
    await _checkForPendingGeneration();
  }

  Future<StorageResult<int>> getBalance() async {
    try {
      final token = _settingsProvider.musicApiKey;
      if (token.isEmpty) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            code: 'NO_TOKEN',
            message: 'Music API token not configured',
            timestamp: DateTime.now(),
          ),
        );
      }

      final result = await _apiService.get(
        '$_genApiBaseUrl/api/v1/user',
        headers: {
          'Authorization': 'Bearer $token',
          'User-Agent': 'NovaSpec/1.0',
        },
      );

      if (result.isSuccess) {
        final balance = result.data?['balance'] as int? ?? 0;
        return StorageResult.success(balance);
      } else {
        return StorageResult.failure(result.error!);
      }
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.unknown,
          severity: ErrorSeverity.high,
          code: 'BALANCE_CHECK_ERROR',
          message: 'Failed to check balance',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<StorageResult<bool>> validateIntegration() async {
    final balanceResult = await getBalance();
    return balanceResult.isSuccess
        ? StorageResult.success(true)
        : StorageResult.failure(balanceResult.error!);
  }

  Future<StorageResult<String>> generateMusicForFile(String filePath) async {
    if (_currentRequest != null && _currentRequest!.status != MusicGenerationStatus.failed) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.validation,
          severity: ErrorSeverity.medium,
          code: 'GENERATION_IN_PROGRESS',
          message: 'Music generation already in progress',
          timestamp: DateTime.now(),
        ),
      );
    }

    try {
      final fileContent = await _fileService.readFile(filePath);
      if (!fileContent.isSuccess) {
        return StorageResult.failure(fileContent.error!);
      }

      final genre = _settingsProvider.musicProvider;
      if (genre.isEmpty) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            code: 'NO_GENRE',
            message: 'Music genre not configured',
            timestamp: DateTime.now(),
          ),
        );
      }

      _currentRequest = MusicGenerationRequest(
        requestId: '',
        filePath: filePath,
        genre: genre,
        createdAt: DateTime.now(),
        status: MusicGenerationStatus.generatingLyrics,
      );

      _statusController.add(_currentRequest!);
      await _saveGenerationLog();

      final lyricsResult = await _generateLyrics(fileContent.data!, genre);
      if (!lyricsResult.isSuccess) {
        _currentRequest!.status = MusicGenerationStatus.failed;
        _currentRequest = MusicGenerationRequest(
          requestId: _currentRequest!.requestId,
          filePath: _currentRequest!.filePath,
          genre: _currentRequest!.genre,
          createdAt: _currentRequest!.createdAt,
          status: MusicGenerationStatus.failed,
          error: lyricsResult.error?.message,
        );
        _statusController.add(_currentRequest!);
        await _saveGenerationLog();
        return StorageResult.failure(lyricsResult.error!);
      }

      _currentRequest!.status = MusicGenerationStatus.generatingMusic;
      _statusController.add(_currentRequest!);
      await _saveGenerationLog();

      final musicResult = await _generateMusic(lyricsResult.data!, genre);
      if (!musicResult.isSuccess) {
        _currentRequest = MusicGenerationRequest(
          requestId: _currentRequest!.requestId,
          filePath: _currentRequest!.filePath,
          genre: _currentRequest!.genre,
          createdAt: _currentRequest!.createdAt,
          status: MusicGenerationStatus.failed,
          error: musicResult.error?.message,
        );
        _statusController.add(_currentRequest!);
        await _saveGenerationLog();
        return StorageResult.failure(musicResult.error!);
      }

      _currentRequest = MusicGenerationRequest(
        requestId: musicResult.data!,
        filePath: _currentRequest!.filePath,
        genre: _currentRequest!.genre,
        createdAt: _currentRequest!.createdAt,
        status: MusicGenerationStatus.processing,
      );
      _statusController.add(_currentRequest!);
      await _saveGenerationLog();

      _startStatusChecking();

      return StorageResult.success(musicResult.data!);
    } catch (e) {
      _currentRequest = MusicGenerationRequest(
        requestId: _currentRequest?.requestId ?? '',
        filePath: filePath,
        genre: _settingsProvider.musicProvider,
        createdAt: DateTime.now(),
        status: MusicGenerationStatus.failed,
        error: e.toString(),
      );
      _statusController.add(_currentRequest!);
      await _saveGenerationLog();
      return StorageResult.failure(
        AppError(
          type: ErrorType.unknown,
          severity: ErrorSeverity.high,
          code: 'GENERATION_ERROR',
          message: 'Failed to generate music',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<StorageResult<String>> _generateLyrics(String content, String genre) async {
    try {
      final prompt = '''Составь текст песни, чтобы зачитать данные требования в жанре $genre.
Текст должен быть сделан в виде Lyrics пригодным для Suno
В ответе не указывай ничего лишнего, исключительно Lyrics
Требования: $content''';

      final result = await _apiService.post(
        '${_settingsProvider.openaiBaseUrl}/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo', // Используем модель по умолчанию
          'messages': [{'role': 'user', 'content': prompt}],
          'max_tokens': 500,
          'temperature': 0.7,
        },
        headers: {
          'Authorization': 'Bearer ${_settingsProvider.openaiApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (result.isSuccess) {
        final lyrics = result.data?['choices']?[0]?['message']?['content'] as String?;
        if (lyrics != null && lyrics.isNotEmpty) {
          return StorageResult.success(lyrics);
        }
      }

      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'LYRICS_GENERATION_FAILED',
          message: 'Failed to generate lyrics',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.system,
          severity: ErrorSeverity.high,
          code: 'LYRICS_GENERATION_ERROR',
          message: 'Error generating lyrics',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<StorageResult<String>> _generateMusic(String lyrics, String genre) async {
    try {
      final token = _settingsProvider.musicApiKey;
      if (token.isEmpty) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.validation,
            severity: ErrorSeverity.medium,
            code: 'NO_TOKEN',
            message: 'Music API token not configured',
            timestamp: DateTime.now(),
          ),
        );
      }

      final result = await _apiService.post(
        '$_genApiBaseUrl/api/v1/networks/suno',
        data: {
          'title': 'NovaSpec Generated Track',
          'tags': genre,
          'prompt': lyrics,
          'translate_input': false,
          'model': 'v5',
        },
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (result.isSuccess) {
        final requestId = result.data?['request_id'] as String?;
        if (requestId != null && requestId.isNotEmpty) {
          return StorageResult.success(requestId);
        }
      }

      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'MUSIC_GENERATION_FAILED',
          message: 'Failed to start music generation',
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'MUSIC_GENERATION_ERROR',
          message: 'Error generating music',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _startStatusChecking() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(_statusCheckInterval, (_) async {
      if (_currentRequest?.requestId != null) {
        await _checkGenerationStatus();
      }
    });
  }

  Future<void> _checkGenerationStatus() async {
    if (_currentRequest?.requestId == null) return;

    try {
      final token = _settingsProvider.musicApiKey;
      final result = await _apiService.get(
        '$_genApiBaseUrl/api/v1/request/get/${_currentRequest!.requestId}',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (result.isSuccess) {
        final status = result.data?['status'] as String?;
        final resultUrls = result.data?['result'] as List<dynamic>?;

        switch (status) {
          case 'processing':
            _currentRequest!.status = MusicGenerationStatus.processing;
            break;
          case 'success':
            _currentRequest!.status = MusicGenerationStatus.success;
            if (resultUrls != null) {
              await _downloadGeneratedFiles(List<String>.from(resultUrls));
            }
            _statusCheckTimer?.cancel();
            break;
          case 'failed':
            _currentRequest!.status = MusicGenerationStatus.failed;
            _currentRequest = MusicGenerationRequest(
              requestId: _currentRequest!.requestId,
              filePath: _currentRequest!.filePath,
              genre: _currentRequest!.genre,
              createdAt: _currentRequest!.createdAt,
              status: MusicGenerationStatus.failed,
              error: result.data?['error'] as String?,
            );
            _statusCheckTimer?.cancel();
            break;
          case 'cancelled':
            _currentRequest!.status = MusicGenerationStatus.cancelled;
            _statusCheckTimer?.cancel();
            break;
        }

        _statusController.add(_currentRequest!);
        await _saveGenerationLog();
      }
    } catch (e) {
      // Log error but don't stop checking
    }
  }

  Future<void> _downloadGeneratedFiles(List<String> urls) async {
    final projectPath = _settingsProvider.defaultProjectLocation;
    if (projectPath.isEmpty) return;

    final musicDir = Directory('$projectPath/music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }

    final downloadedFiles = <String>[];

    for (int i = 0; i < urls.length; i++) {
      try {
        final url = urls[i];
        final fileName = 'generated_track_${DateTime.now().millisecondsSinceEpoch}_$i.mp3';
        final savePath = '$musicDir/$fileName';

        final downloadResult = await _apiService.downloadFile(url, savePath);
        if (downloadResult.isSuccess) {
          downloadedFiles.add(savePath);
        }
      } catch (e) {
        // Continue with other files even if one fails
      }
    }

    _currentRequest = MusicGenerationRequest(
      requestId: _currentRequest!.requestId,
      filePath: _currentRequest!.filePath,
      genre: _currentRequest!.genre,
      createdAt: _currentRequest!.createdAt,
      status: MusicGenerationStatus.success,
      generatedFiles: downloadedFiles,
    );
    _statusController.add(_currentRequest!);
    await _saveGenerationLog();
  }

  Future<void> _saveGenerationLog() async {
    if (_currentRequest == null) return;

    try {
      final projectPath = _settingsProvider.defaultProjectLocation;
      if (projectPath.isEmpty) return;

      final logFile = File('$projectPath/$_logFileName');
      final logData = _currentRequest!.toJson();
      await logFile.writeAsString(logData.toString());
    } catch (e) {
      // Log error but don't fail the operation
    }
  }

  Future<void> _checkForPendingGeneration() async {
    try {
      final projectPath = _settingsProvider.defaultProjectLocation;
      if (projectPath.isEmpty) return;

      final logFile = File('$projectPath/$_logFileName');
      if (!await logFile.exists()) return;

      final logContent = await logFile.readAsString();
      if (logContent.isEmpty) return;

      // Parse the JSON log content
      // This is a simplified parser - in production, use dart:convert
      final logData = <String, dynamic>{};

      _currentRequest = MusicGenerationRequest.fromJson(logData);

      if (_currentRequest!.status == MusicGenerationStatus.processing) {
        _startStatusChecking();
      }

      _statusController.add(_currentRequest!);
    } catch (e) {
      // Log error but don't fail initialization
    }
  }

  Future<void> cancelGeneration() async {
    _statusCheckTimer?.cancel();
    if (_currentRequest != null) {
      _currentRequest!.status = MusicGenerationStatus.cancelled;
      _statusController.add(_currentRequest!);
      await _saveGenerationLog();
    }
  }

  Future<void> clearGenerationLog() async {
    try {
      final projectPath = _settingsProvider.defaultProjectLocation;
      if (projectPath.isEmpty) return;

      final logFile = File('$projectPath/$_logFileName');
      if (await logFile.exists()) {
        await logFile.delete();
      }
    } catch (e) {
      // Log error but don't fail the operation
    }
  }

  void dispose() {
    _statusCheckTimer?.cancel();
    _statusController.close();
  }

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
        'Electro music': 'electro music',
        'Hip-hop': 'hip-hop',
        'R&B': 'r&b',
      };
    }
  }

  String getGenreDisplayName(String genreKey, String locale) {
    final genres = getLocalizedGenres(locale);
    final entry = genres.entries.where((e) => e.value == genreKey).firstOrNull;
    return entry?.key ?? genreKey;
  }
}
