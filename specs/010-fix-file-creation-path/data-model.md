# Data Model: Исправление пути создания файлов

**Feature**: Исправление пути создания файлов  
**Date**: 31.10.2025  
**Status**: Complete  

## Core Entities

### FileCreationContext
Контекст создания файла, содержащий всю необходимую информацию для операции.

```dart
class FileCreationContext {
  final String fileName;           // Имя файла с расширением
  final String currentDirectory;    // Текущая директория из FileExplorerProvider
  final String projectRoot;         // Корневая директория проекта
  final String fullPath;            // Полный путь для создания файла
  final DateTime timestamp;         // Время создания контекста
  
  // Validation
  bool get isValid => _validatePath();
  String? get validationError => _getValidationError();
}
```

### DirectoryValidationResult
Результат валидации директории для создания файла.

```dart
class DirectoryValidationResult {
  final bool isAccessible;          // Доступна ли директория
  final bool hasWritePermission;    // Есть ли права на запись
  final String? errorMessage;       // Сообщение об ошибке
  final DirectoryValidationStatus status; // Статус валидации
}

enum DirectoryValidationStatus {
  accessible,      // Директория доступна
  notFound,        // Директория не найдена
  permissionDenied, // Нет прав на запись
  pathTooLong,     // Путь слишком длинный
  invalidCharacters // Недопустимые символы
}
```

### FileCreationResult
Результат операции создания файла.

```dart
class FileCreationResult {
  final bool success;               // Успешность операции
  final String? filePath;          // Путь созданного файла
  final String? errorMessage;      // Сообщение об ошибке
  final FileCreationErrorType? errorType; // Тип ошибки
}

enum FileCreationErrorType {
  none,                // Нет ошибки
  directoryNotFound,   // Директория не найдена
  permissionDenied,    // Нет прав на запись
  fileAlreadyExists,   // Файл уже существует
  invalidFileName,     // Недопустимое имя файла
  diskFull,           // Нет места на диске
  unknownError        // Неизвестная ошибка
}
```

## Data Flow

### 1. Context Creation
```
User Action → CreateFileDialog → FileCreationContext
```

**Input**: 
- fileName из диалога
- currentDirectory из FileExplorerProvider
- projectRoot из ProjectProvider

**Processing**:
- Валидация имени файла
- Построение полного пути
- Создание контекста операции

### 2. Directory Validation
```
FileCreationContext → DirectoryValidationResult
```

**Validation Steps**:
1. Проверка существования директории
2. Проверка прав на запись
3. Валидация длины пути
4. Проверка символов

### 3. File Creation
```
FileCreationContext + DirectoryValidationResult → FileCreationResult
```

**Process**:
- Создание файла через WorkspaceFileService
- Обработка ошибок
- Возврат результата

## State Management

### FileExplorerProvider Updates
```dart
class FileExplorerProvider extends ChangeNotifier {
  String _currentDirectory = '';
  String get currentDirectory => _currentDirectory;
  
  void setCurrentDirectory(String path) {
    _currentDirectory = path;
    notifyListeners();
  }
  
  // Новый метод для валидации директории
  Future<DirectoryValidationResult> validateDirectory(String path) async {
    // Реализация валидации
  }
}
```

### CreateFileDialog State
```dart
class _CreateFileDialogState extends State<CreateFileDialog> {
  FileCreationContext? _creationContext;
  DirectoryValidationResult? _validationResult;
  bool _isCreating = false;
  
  // Методы для управления состоянием
  void _updateContext(String fileName) { /* ... */ }
  Future<void> _validateCurrentDirectory() async { /* ... */ }
  Future<void> _createFile() async { /* ... */ }
}
```

## Validation Rules

### File Name Validation
- **Length**: 1-255 символов
- **Characters**: Буквы, цифры, подчеркивания, дефисы, точки
- **Forbidden**: `< > : " | ? * \ /`
- **Reserved Names**: CON, PRN, AUX, NUL, COM1-COM9, LPT1-LPT9

### Path Validation
- **Max Length**: 260 символов (Windows)
- **Depth**: Максимум 10 уровней вложенности
- **Characters**: Запрещены управляющие символы
- **Network Paths**: Не поддерживаются

### Directory Validation
- **Existence**: Директория должна существовать
- **Accessibility**: Должна быть доступна для чтения
- **Write Permission**: Должны быть права на запись
- **Not System**: Не должна быть системной директорией

## Error Handling

### Error Categories
1. **User Input Errors**: Недопустимое имя файла
2. **System Errors**: Проблемы с доступом к файловой системе
3. **Permission Errors**: Отсутствие прав на запись
4. **Resource Errors**: Нет места на диске

### Error Messages
Все сообщения должны быть локализованы через AppLocalizations:

```dart
// Примеры локализованных сообщений
AppLocalizations.of(context)!.fileCreationErrorInvalidFileName(fileName)
AppLocalizations.of(context)!.fileCreationErrorPermissionDenied(directory)
AppLocalizations.of(context)!.fileCreationErrorDirectoryNotFound(directory)
```

## Integration Points

### WorkspaceFileService Interface
```dart
class WorkspaceFileService {
  // Новый метод для создания файла с контекстом
  Future<FileCreationResult> createFileWithContext(
    FileCreationContext context
  ) async {
    // Реализация создания файла
  }
  
  // Существующий метод (для обратной совместимости)
  Future<void> createFile(String path, String content) async {
    // Существующая реализация
  }
}
```

### ToastService Integration
```dart
class ToastService {
  static void success(String description) { /* ... */ }
  static void error(String description) { /* ... */ }
  static void warning(String description) { /* ... */ }
}
```

## Performance Considerations

### Caching Strategy
- Кэширование результатов валидации директории (5 минут TTL)
- Ленивая загрузка FileExplorerProvider
- Минимальные операции с файловой системой

### Async Operations
- Все файловые операции асинхронны
- Non-blocking UI во время валидации
- Таймауты для файловых операций (5 секунд)

## Security Considerations

### Path Traversal Prevention
```dart
bool _isPathSafe(String basePath, String targetPath) {
  final baseDir = Directory(basePath).absolute;
  final targetDir = Directory(targetPath).absolute;
  
  return targetDir.path.startsWith(baseDir.path);
}
```

### Input Sanitization
- Экранирование специальных символов
- Нормализация путей
- Проверка на символические ссылки