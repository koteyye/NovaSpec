import 'package:flutter/widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../models/musication_error_code.dart';
import '../models/musication_exception.dart';

/// Утилита для обработки ошибок музикации
class MusicationErrorHandler {
  /// Получить локализованное сообщение об ошибке
  static String getLocalizedMessage(
    BuildContext context,
    MusicationException exception,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    // Получаем локализованное сообщение по коду ошибки
    // используя switch на enum
    switch (exception.code) {
      case MusicationErrorCode.noApiKey:
        return l10n.musication_error_no_api_key;
      case MusicationErrorCode.noAiModel:
        return l10n.musication_error_no_ai_model;
      case MusicationErrorCode.noContent:
        return l10n.musication_error_no_content;
      case MusicationErrorCode.invalidApiKey:
        return l10n.musication_error_invalid_api_key;
      case MusicationErrorCode.insufficientFunds:
        return l10n.musication_error_insufficient_funds;
      case MusicationErrorCode.unauthorized:
        return l10n.musication_error_unauthorized;
      case MusicationErrorCode.forbidden:
        return l10n.musication_error_forbidden;
      case MusicationErrorCode.notFound:
        return l10n.musication_error_not_found;
      case MusicationErrorCode.requestNotFound:
        return l10n.musication_error_request_not_found;
      case MusicationErrorCode.modelNotFound:
        return l10n.musication_error_model_not_found;
      case MusicationErrorCode.tooManyRequests:
        return l10n.musication_error_too_many_requests;
      case MusicationErrorCode.serviceError:
        return l10n.musication_error_service_error;
      case MusicationErrorCode.networkError:
        return l10n.musication_error_network;
      case MusicationErrorCode.connectionTimeout:
        return l10n.musication_error_connection_timeout;
      case MusicationErrorCode.lyricsGenerationFailed:
        return l10n.musication_error_lyrics_generation_failed;
      case MusicationErrorCode.emptyLyricsResponse:
        return l10n.musication_error_empty_lyrics_response;
      case MusicationErrorCode.musicGenerationFailed:
        return l10n.musication_error_music_generation_failed;
      case MusicationErrorCode.pollingTimeout:
        return l10n.musication_error_polling_timeout;
      case MusicationErrorCode.pollingFailed:
        return l10n.musication_error_polling_failed;
      case MusicationErrorCode.fileDownloadFailed:
        return l10n.musication_error_file_download_failed;
      case MusicationErrorCode.fileSaveFailed:
        return l10n.musication_error_file_save_failed;
      case MusicationErrorCode.unknown:
        return l10n.musication_error_unknown;
    }
  }

  /// Обработать любую ошибку и вернуть MusicationException
  static MusicationException handleError(dynamic error) {
    if (error is MusicationException) {
      return error;
    }

    // Если это DioException
    if (error.runtimeType.toString().contains('DioException')) {
      return MusicationException.fromDioError(error);
    }

    // Неизвестная ошибка
    return MusicationException(
      code: MusicationErrorCode.unknown,
      technicalMessage: error.toString(),
      originalError: error,
    );
  }
}
