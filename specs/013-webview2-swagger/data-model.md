# Data Model: WebView2 SwaggerUI Integration

**Date**: 02.11.2025  
**Feature**: WebView2 SwaggerUI Integration

## Core Entities

### WebViewState

Модель состояния WebView компонента для управления через Provider.

```dart
class WebViewState extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  WebViewWindowState? _windowState;
  String? _currentOpenAPIFile;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  WebViewWindowState? get windowState => _windowState;
  String? get currentOpenAPIFile => _currentOpenAPIFile;
  
  // Methods
  void setLoading(bool loading);
  void setError(String? error);
  void setWindowState(WebViewWindowState? state);
  void setCurrentOpenAPIFile(String? filePath);
  void clearError();
}
```

**Fields**:
- `isLoading`: Состояние загрузки WebView
- `hasError`: Флаг наличия ошибки
- `errorMessage`: Текст ошибки для отображения пользователю
- `windowState`: Состояние окна (размер, положение)
- `currentOpenAPIFile`: Путь к текущему OpenAPI файлу

**Validation Rules**:
- `errorMessage` не может быть пустым если `hasError` = true
- `windowState` должен содержать валидные размеры > 0
- `currentOpenAPIFile` должен существовать на файловой системе

### WebViewWindowState

Модель для сохранения состояния окна WebView между сессиями.

```dart
class WebViewWindowState {
  double width;
  double height;
  double x;
  double y;
  bool isMaximized;
  DateTime lastUpdated;
  
  WebViewWindowState({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.isMaximized = false,
  }) : lastUpdated = DateTime.now();
}
```

**Fields**:
- `width`, `height`: Размеры окна
- `x`, `y`: Положение окна
- `isMaximized`: Флаг максимизации окна
- `lastUpdated`: Время последнего обновления

**Validation Rules**:
- `width`, `height` должны быть > 100px
- `x`, `y` должны быть в пределах экрана
- `isMaximized` boolean

### OpenAPIFileInfo

Модель информации об OpenAPI файле.

```dart
class OpenAPIFileInfo {
  String filePath;
  String fileName;
  String fileType; // 'yaml' or 'json'
  int fileSize;
  DateTime lastModified;
  String? swaggerUrl;
  
  OpenAPIFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.lastModified,
    this.swaggerUrl,
  });
}
```

**Fields**:
- `filePath`: Полный путь к файлу
- `fileName`: Имя файла с расширением
- `fileType`: Тип файла ('yaml' или 'json')
- `fileSize`: Размер файла в байтах
- `lastModified`: Время последнего изменения
- `swaggerUrl`: URL для SwaggerUI (генерируется)

**Validation Rules**:
- `filePath` должен быть абсолютным путем
- `fileType` должен быть 'yaml' или 'json'
- `fileSize` должен быть > 0
- `fileName` должен заканчиваться на .yaml, .yml или .json

### WebView2Status

Результат проверки наличия WebView2 на системе.

```dart
enum WebView2Availability {
  available,
  notInstalled,
  versionTooOld,
  unknown
}

class WebView2Status {
  WebView2Availability availability;
  String? version;
  String? errorMessage;
  
  WebView2Status({
    required this.availability,
    this.version,
    this.errorMessage,
  });
}
```

**Fields**:
- `availability`: Статус доступности
- `version`: Версия WebView2 (если доступна)
- `errorMessage`: Ошибка проверки (если есть)

**Validation Rules**:
- `version` должен быть в формате semver если `availability` = available
- `errorMessage` должен быть заполнен если `availability` = unknown

## State Transitions

### WebView Lifecycle

```
Initial → Loading → Ready/Error → Disposed
    ↓         ↓        ↓         ↓
  Closed   Loading  Active   Cleanup
```

**Transitions**:
1. `Initial` → `Loading`: При открытии OpenAPI файла
2. `Loading` → `Ready`: При успешной загрузке WebView
3. `Loading` → `Error`: При ошибке загрузки
4. `Ready` → `Disposed`: При закрытии файла или приложения
5. `Error` → `Loading`: При повторной попытке загрузки

### File Processing

```
File Selected → Validation → WebView Loading → Display
      ↓              ↓              ↓            ↓
   OpenAPIFileInfo → Check WebView2 → Load URL → Ready
```

## Data Relationships

```
WebViewProvider
├── WebViewState (ChangeNotifier)
├── WebView2CheckerService
└── OpenAPIFileHandler

WebView2Container
├── Uses WebViewState
├── Uses WebViewWindowState
└── Uses OpenAPIFileInfo

FallbackWebViewWidget
├── Uses WebView2Status
└── Uses ModernButton
```

## Persistence Strategy

### SharedPreferences Structure

```json
{
  "webview_window_states": {
    "default": {
      "width": 1200.0,
      "height": 800.0,
      "x": 100.0,
      "y": 100.0,
      "isMaximized": false,
      "lastUpdated": "2025-11-02T10:30:00Z"
    }
  },
  "webview2_last_check": "2025-11-02T10:00:00Z",
  "webview2_status": "available"
}
```

### Cache Strategy

- **WebViewState**: В памяти во время сессии
- **WebViewWindowState**: В SharedPreferences между сессиями
- **WebView2Status**: Кэшируется на 24 часа в SharedPreferences
- **OpenAPIFileInfo**: В памяти во время обработки файла

## Error Handling

### Error Types

1. **WebView2NotAvailableError**: WebView2 не установлен
2. **OpenAPIValidationError**: Некорректный OpenAPI файл
3. **WebViewLoadError**: Ошибка загрузки WebView
4. **FileNotFoundError**: Файл не найден
5. **NetworkError**: Ошибка сети (если требуется)

### Error Recovery

```dart
abstract class WebViewError {
  String get message;
  String get userFriendlyMessage;
  bool get isRecoverable;
  Future<void> recover();
}
```

## Performance Considerations

### Memory Management
- Dispose WebView компонентов при закрытии
- Очистка кэша OpenAPI файлов
- Ограничение размера истории состояний

### Loading Optimization
- Асинхронная проверка WebView2 при старте
- Кэширование результатов проверки
- Предзагрузка commonly used файлов

### State Synchronization
- Минимизация notifyListeners() вызовов
- Batch обновления состояния
- Debounce для быстрых изменений размера окна