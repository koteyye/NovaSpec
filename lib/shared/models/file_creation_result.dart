enum FileCreationErrorType {
  none,                // Нет ошибки
  directoryNotFound,   // Директория не найдена
  permissionDenied,    // Нет прав на запись
  fileAlreadyExists,   // Файл уже существует
  invalidFileName,     // Недопустимое имя файла
  diskFull,           // Нет места на диске
  unknownError        // Неизвестная ошибка
}

class FileCreationResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final FileCreationErrorType? errorType;
  final DateTime timestamp;

  const FileCreationResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    this.errorType,
    required this.timestamp,
  });

  factory FileCreationResult.success(String filePath) {
    return FileCreationResult(
      success: true,
      filePath: filePath,
      timestamp: DateTime.now(),
    );
  }

  factory FileCreationResult.error(
    FileCreationErrorType errorType,
    String errorMessage,
  ) {
    return FileCreationResult(
      success: false,
      errorType: errorType,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileCreationResult &&
        other.success == success &&
        other.filePath == filePath &&
        other.errorMessage == errorMessage &&
        other.errorType == errorType;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        filePath.hashCode ^
        errorMessage.hashCode ^
        errorType.hashCode;
  }

  @override
  String toString() {
    return 'FileCreationResult('
        'success: $success, '
        'filePath: $filePath, '
        'errorMessage: $errorMessage, '
        'errorType: $errorType, '
        'timestamp: $timestamp)';
  }
}