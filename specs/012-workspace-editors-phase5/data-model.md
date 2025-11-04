# Data Model: File Format Support and Viewers

**Date**: 2025-11-01  
**Feature**: File Format Support and Viewers

## Core Entities

### WorkspaceFile

Представляет открытый файл в рабочей зоне с информацией о его состоянии и режиме просмотра.

```dart
class WorkspaceFile {
  final String id;                    // Уникальный идентификатор файла
  final String path;                   // Полный путь к файлу
  final String name;                   // Имя файла с расширением
  final FileExtension extension;        // Тип файла
  final DateTime lastModified;          // Время последнего изменения
  final int size;                     // Размер файла в байтах
  final FileViewMode viewMode;         // Текущий режим просмотра
  final bool isModified;              // Флаг несохраненных изменений
  final String? content;              // Содержимое файла (кэшировано)
  
  // Валидация
  bool get isValid => path.isNotEmpty && size > 0;
  bool get isLargeFile => size > 10 * 1024 * 1024; // >10MB
}
```

**Validation Rules**:
- `path` не должен быть пустым
- `size` должен быть положительным числом
- `extension` должен поддерживаться системой
- `content` кэшируется только для файлов < 1MB

### FileExtension

Поддерживаемые форматы файлов с их характеристиками.

```dart
enum FileExtension {
  markdown('.md', 'text/markdown'),
  html('.html', 'text/html'),
  json('.json', 'application/json'),
  yaml('.yaml', 'text/yaml'),
  yml('.yml', 'text/yaml'),
  mp3('.mp3', 'audio/mpeg'),
  wav('.wav', 'audio/wav'),
  txt('.txt', 'text/plain'),
  xml('.xml', 'text/xml'),
  unknown('', 'application/octet-stream');

  const FileExtension(this.extension, this.mimeType);
  
  final String extension;
  final String mimeType;
  
  bool get isDocument => [markdown, html, txt].contains(this);
  bool get isCode => [json, yaml, yml, xml].contains(this);
  bool get isAudio => [mp3, wav].contains(this);
  bool get isOpenAPISpec => [json, yaml, yml].contains(this);
}
```

### FileViewMode

Режимы просмотра файлов.

```dart
enum FileViewMode {
  render,     // Рендеринг (Markdown/HTML)
  edit,       // Редактирование (Monaco Editor)
  swagger,    // Swagger UI (OpenAPI)
  audio,      // Аудиоплеер (MP3/WAV)
  code;       // Код (остальные форматы)
}
```

### AudioPlayerState

Состояние аудиоплеера для управления воспроизведением.

```dart
class AudioPlayerState {
  final bool isPlaying;               // Воспроизводится ли аудио
  final bool isLoading;               // Загрузка аудио
  final Duration position;            // Текущая позиция
  final Duration duration;            // Общая длительность
  final double volume;                // Громкость (0.0 - 1.0)
  final PlaybackSpeed speed;          // Скорость воспроизведения
  final String? errorMessage;        // Ошибка воспроизведения
  
  // Валидация
  bool get isValid => duration.inMilliseconds > 0;
  double get progress => duration.inMilliseconds > 0 
      ? position.inMilliseconds / duration.inMilliseconds 
      : 0.0;
}

enum PlaybackSpeed { x0_5, x1_0, x1_25, x1_5, x2_0 }
```

**Validation Rules**:
- `position` не может превышать `duration`
- `volume` должен быть в диапазоне 0.0 - 1.0
- `errorMessage` очищается при успешном воспроизведении

### OpenAPISpec

Представляет OpenAPI спецификацию с результатами валидации.

```dart
class OpenAPISpec {
  final String content;                // Содержимое файла
  final OpenAPIFormat format;          // Формат (JSON/YAML)
  final ValidationResult validation;     // Результат валидации
  final Map<String, dynamic>? parsedSpec; // Распарсенная спецификация
  
  // Валидация
  bool get isValid => validation.isValid;
  bool get canShowSwagger => isValid && parsedSpec != null;
}

enum OpenAPIFormat { json, yaml, unknown }

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int? errorLine;
  final int? errorColumn;
  
  const ValidationResult(this.isValid, [this.errorMessage, this.errorLine, this.errorColumn]);
}
```

**Validation Rules**:
- Обязательные поля OpenAPI: `openapi`, `info`, `paths`
- `openapi` должен содержать версию
- `info` должен содержать `title` и `version`
- `paths` должен содержать хотя бы один путь

### MonacoEditorState

Состояние Monaco Editor для управления редактированием кода.

```dart
class MonacoEditorState {
  final String content;                // Текущее содержимое
  final String language;               // Язык подсветки
  final bool isReadOnly;              // Режим только для чтения
  final bool hasUnsavedChanges;       // Несохраненные изменения
  final EditorTheme theme;             // Тема редактора
  final int fontSize;                 // Размер шрифта
  final bool wordWrap;                // Перенос слов
  final List<String> openTabs;        // Открытые вкладки редактора
  
  // Валидация
  bool get canSave => hasUnsavedChanges && !isReadOnly;
  int get lineCount => content.split('\n').length;
}

enum EditorTheme { vs, vs-dark, hc-black }
```

**Validation Rules**:
- `fontSize` должен быть в диапазоне 8-72
- `content` не должен превышать 10MB для производительности
- `language` должен поддерживаться Monaco Editor

## State Transitions

### File Opening Flow

```
File Selected → Determine Extension → Choose Viewer → Load Content → Display
     ↓                ↓                    ↓              ↓           ↓
  Validate Path   Check Support    Select ViewMode   Cache Content  Update UI
```

### Audio Player State Flow

```
Load Audio → Initialize → Ready → Playing ↔ Paused → Stopped
     ↓           ↓          ↓        ↓         ↓          ↓
  Show Loading  Set Duration  Enable Controls  Update Position  Reset State
```

### Editor Mode Switch Flow

```
View Mode → Switch Request → Save Current → Load New Mode → Update UI
     ↓              ↓               ↓              ↓           ↓
  Check Changes  Confirm Switch   Persist State   Initialize   Refresh View
```

## Relationships

```
WorkspaceFile 1..1 FileExtension
WorkspaceFile 1..1 FileViewMode
WorkspaceFile 0..1 AudioPlayerState (только для аудио)
WorkspaceFile 0..1 OpenAPISpec (только для OpenAPI)
WorkspaceFile 0..1 MonacoEditorState (для редактирования)
```

## Data Flow

### File Content Loading

1. **File Selection** → Создание `WorkspaceFile`
2. **Extension Detection** → Определение `FileExtension`
3. **Content Loading** → Кэширование содержимого
4. **View Mode Selection** → Выбор `FileViewMode`
5. **UI Update** → Отображение соответствующего viewer

### State Synchronization

1. **File Change** → Обновление `isModified`
2. **Tab Switch** → Сохранение состояния текущего файла
3. **Mode Change** → Переключение `FileViewMode`
4. **Content Save** → Сброс `isModified` флага

## Performance Considerations

- **Content Caching**: Только для файлов < 1MB
- **Lazy Loading**: Загрузка содержимого при открытии вкладки
- **Memory Management**: Очистка кэша при закрытии вкладок
- **Async Operations**: Все операции с файлами асинхронные
- **Error Handling**: Graceful degradation при ошибках загрузки

## Security Considerations

- **Path Validation**: Проверка путей на безопасность
- **Content Sanitization**: Очистка HTML контента
- **File Size Limits**: Ограничение размера файлов
- **Access Control**: Проверка прав доступа к файлам