/// Коды ошибок музикации
enum MusicationErrorCode {
  // Ошибки валидации
  noApiKey,
  noAiModel,
  noContent,
  invalidApiKey,
  
  // Ошибки баланса
  insufficientFunds,
  
  // Ошибки API
  unauthorized,
  forbidden,
  notFound,
  requestNotFound,
  modelNotFound,
  tooManyRequests,
  serviceError,
  
  // Ошибки сети
  networkError,
  connectionTimeout,
  
  // Ошибки генерации
  lyricsGenerationFailed,
  emptyLyricsResponse,
  musicGenerationFailed,
  
  // Ошибки опрашивания
  pollingTimeout,
  pollingFailed,
  
  // Ошибки файловой системы
  fileDownloadFailed,
  fileSaveFailed,
  
  // Общие ошибки
  unknown,
}

/// Расширение для получения локализованного сообщения
extension MusicationErrorCodeExtension on MusicationErrorCode {
  /// Получить ключ локализации для ошибки
  String get localizationKey {
    switch (this) {
      case MusicationErrorCode.noApiKey:
        return 'musication_error_no_api_key';
      case MusicationErrorCode.noAiModel:
        return 'musication_error_no_ai_model';
      case MusicationErrorCode.noContent:
        return 'musication_error_no_content';
      case MusicationErrorCode.invalidApiKey:
        return 'musication_error_invalid_api_key';
      case MusicationErrorCode.insufficientFunds:
        return 'musication_error_insufficient_funds';
      case MusicationErrorCode.unauthorized:
        return 'musication_error_unauthorized';
      case MusicationErrorCode.forbidden:
        return 'musication_error_forbidden';
      case MusicationErrorCode.notFound:
        return 'musication_error_not_found';
      case MusicationErrorCode.requestNotFound:
        return 'musication_error_request_not_found';
      case MusicationErrorCode.modelNotFound:
        return 'musication_error_model_not_found';
      case MusicationErrorCode.tooManyRequests:
        return 'musication_error_too_many_requests';
      case MusicationErrorCode.serviceError:
        return 'musication_error_service_error';
      case MusicationErrorCode.networkError:
        return 'musication_error_network';
      case MusicationErrorCode.connectionTimeout:
        return 'musication_error_connection_timeout';
      case MusicationErrorCode.lyricsGenerationFailed:
        return 'musication_error_lyrics_generation_failed';
      case MusicationErrorCode.emptyLyricsResponse:
        return 'musication_error_empty_lyrics_response';
      case MusicationErrorCode.musicGenerationFailed:
        return 'musication_error_music_generation_failed';
      case MusicationErrorCode.pollingTimeout:
        return 'musication_error_polling_timeout';
      case MusicationErrorCode.pollingFailed:
        return 'musication_error_polling_failed';
      case MusicationErrorCode.fileDownloadFailed:
        return 'musication_error_file_download_failed';
      case MusicationErrorCode.fileSaveFailed:
        return 'musication_error_file_save_failed';
      case MusicationErrorCode.unknown:
        return 'musication_error_unknown';
    }
  }
}
