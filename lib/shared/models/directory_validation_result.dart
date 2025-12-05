enum DirectoryValidationStatus {
  accessible,      // Директория доступна
  notFound,        // Директория не найдена
  permissionDenied, // Нет прав на запись
  pathTooLong,     // Путь слишком длинный
  invalidCharacters, // Недопустимые символы
  unknownError,    // Неизвестная ошибка
}

class DirectoryValidationResult {
  final bool isAccessible;
  final bool hasWritePermission;
  final String? errorMessage;
  final DirectoryValidationStatus status;
  final String directoryPath;

  const DirectoryValidationResult({
    required this.isAccessible,
    required this.hasWritePermission,
    this.errorMessage,
    required this.status,
    required this.directoryPath,
  });

  factory DirectoryValidationResult.success(String directoryPath) {
    return DirectoryValidationResult(
      isAccessible: true,
      hasWritePermission: true,
      status: DirectoryValidationStatus.accessible,
      directoryPath: directoryPath,
    );
  }

  factory DirectoryValidationResult.notFound(String directoryPath) {
    return DirectoryValidationResult(
      isAccessible: false,
      hasWritePermission: false,
      errorMessage: 'Directory not found: $directoryPath',
      status: DirectoryValidationStatus.notFound,
      directoryPath: directoryPath,
    );
  }

  factory DirectoryValidationResult.permissionDenied(String directoryPath) {
    return DirectoryValidationResult(
      isAccessible: false,
      hasWritePermission: false,
      errorMessage: 'Permission denied: $directoryPath',
      status: DirectoryValidationStatus.permissionDenied,
      directoryPath: directoryPath,
    );
  }

  factory DirectoryValidationResult.pathTooLong(String directoryPath) {
    return DirectoryValidationResult(
      isAccessible: false,
      hasWritePermission: false,
      errorMessage: 'Path too long: $directoryPath',
      status: DirectoryValidationStatus.pathTooLong,
      directoryPath: directoryPath,
    );
  }

  factory DirectoryValidationResult.invalidCharacters(String directoryPath) {
    return DirectoryValidationResult(
      isAccessible: false,
      hasWritePermission: false,
      errorMessage: 'Invalid characters in path: $directoryPath',
      status: DirectoryValidationStatus.invalidCharacters,
      directoryPath: directoryPath,
    );
  }

  factory DirectoryValidationResult.error(
    DirectoryValidationStatus status,
    String errorMessage,
    String directoryPath,
  ) {
    return DirectoryValidationResult(
      isAccessible: false,
      hasWritePermission: false,
      errorMessage: errorMessage,
      status: status,
      directoryPath: directoryPath,
    );
  }

  bool get isValid => isAccessible && hasWritePermission;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DirectoryValidationResult &&
        other.isAccessible == isAccessible &&
        other.hasWritePermission == hasWritePermission &&
        other.errorMessage == errorMessage &&
        other.status == status &&
        other.directoryPath == directoryPath;
  }

  @override
  int get hashCode {
    return isAccessible.hashCode ^
        hasWritePermission.hashCode ^
        errorMessage.hashCode ^
        status.hashCode ^
        directoryPath.hashCode;
  }

  @override
  String toString() {
    return 'DirectoryValidationResult('
        'isAccessible: $isAccessible, '
        'hasWritePermission: $hasWritePermission, '
        'errorMessage: $errorMessage, '
        'status: $status, '
        'directoryPath: $directoryPath)';
  }
}