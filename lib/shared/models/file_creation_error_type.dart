enum FileCreationErrorType {
  none,                // Нет ошибки
  directoryNotFound,   // Директория не найдена
  permissionDenied,    // Нет прав на запись
  fileAlreadyExists,   // Файл уже существует
  invalidFileName,     // Недопустимое имя файла
  diskFull,           // Нет места на диске
  unknownError        // Неизвестная ошибка
}