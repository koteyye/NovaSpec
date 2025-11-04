enum DirectoryValidationStatus {
  accessible,      // Директория доступна
  notFound,        // Директория не найдена
  permissionDenied, // Нет прав на запись
  pathTooLong,     // Путь слишком длинный
  invalidCharacters, // Недопустимые символы
  unknownError,    // Неизвестная ошибка
}