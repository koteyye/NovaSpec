import 'musication_error_code.dart';

/// Исключение музикации с кодом ошибки
class MusicationException implements Exception {
  final MusicationErrorCode code;
  final String? technicalMessage;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const MusicationException({
    required this.code,
    this.technicalMessage,
    this.originalError,
    this.stackTrace,
  });

  /// Создать исключение из HTTP статус кода
  factory MusicationException.fromStatusCode(
    int statusCode, {
    String? message,
    dynamic originalError,
  }) {
    final code = switch (statusCode) {
      401 => MusicationErrorCode.unauthorized,
      402 => MusicationErrorCode.insufficientFunds,
      403 => MusicationErrorCode.forbidden,
      404 => MusicationErrorCode.notFound,
      419 => MusicationErrorCode.tooManyRequests,
      503 => MusicationErrorCode.serviceError,
      _ => MusicationErrorCode.unknown,
    };

    return MusicationException(
      code: code,
      technicalMessage: message ?? 'HTTP $statusCode',
      originalError: originalError,
    );
  }

  /// Создать исключение из DioException
  factory MusicationException.fromDioError(dynamic error) {
    final statusCode = error.response?.statusCode;
    
    if (statusCode != null) {
      return MusicationException.fromStatusCode(
        statusCode,
        message: error.message,
        originalError: error,
      );
    }

    // Проверяем тип ошибки
    final errorType = error.type.toString();
    final code = errorType.contains('connectionTimeout') ||
            errorType.contains('receiveTimeout')
        ? MusicationErrorCode.connectionTimeout
        : MusicationErrorCode.networkError;

    return MusicationException(
      code: code,
      technicalMessage: error.message,
      originalError: error,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('MusicationException(');
    buffer.write('code: $code');
    
    if (technicalMessage != null) {
      buffer.write(', message: $technicalMessage');
    }
    
    buffer.write(')');
    return buffer.toString();
  }
}
