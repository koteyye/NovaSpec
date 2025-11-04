# WebView API Contracts

**Date**: 02.11.2025  
**Feature**: WebView2 SwaggerUI Integration

## Internal API Contracts

### WebView2CheckerService

```dart
abstract class IWebView2CheckerService {
  /// Проверяет наличие и версию WebView2 на системе
  Future<WebView2Status> checkWebView2Availability();
  
  /// Проверяет версию WebView2 на совместимость
  bool isVersionCompatible(String version);
  
  /// Получает детальную информацию о WebView2
  Future<WebView2Info?> getWebView2Info();
}
```

**Implementation Requirements**:
- Использовать `webview_windows.WebviewController.getWebViewVersion()`
- Fallback на проверку реестра через `win32`
- Кэшировать результат на 24 часа

### SwaggerServerService (существующий)

Используется существующий `SwaggerServerService` для:
- Запуска локального Swagger сервера
- Генерации URL для OpenAPI файлов
- Обработки виртуальных хостов

**Integration Requirements**:
- Использовать существующие методы сервиса
- Получать URL через существующий API
- Не создавать дублирующую функциональность

### IWebViewContainer

```dart
abstract class IWebViewContainer {
  /// Загружает URL в WebView
  Future<void> loadUrl(String url);
  
  /// Устанавливает размер окна
  Future<void> setWindowSize(double width, double height);
  
  /// Устанавливает положение окна
  Future<void> setWindowPosition(double x, double y);
  
  /// Показывает/скрывает WebView
  Future<void> setVisible(bool visible);
  
  /// Возвращает текущее состояние окна
  Future<WebViewWindowState> getWindowState();
  
  /// Уничтожает WebView
  Future<void> dispose();
}
```

**Platform Implementations**:
- `WebView2Container`: Windows с `webview_windows`
- `WebViewContainer`: Другие платформы с `webview_flutter`

## Event Contracts

### WebView Events

```dart
abstract class IWebViewEventHandler {
  /// Вызывается при начале загрузки
  void onLoadStart(String url);
  
  /// Вызывается при завершении загрузки
  void onLoadFinish(String url, bool success);
  
  /// Вызывается при ошибке загрузки
  void onLoadError(String url, String error);
  
  /// Вызывается при изменении размера окна
  void onWindowResize(double width, double height);
  
  /// Вызывается при изменении положения окна
  void onWindowMove(double x, double y);
}
```

### Provider Events

```dart
abstract class IWebViewStateListener {
  /// Вызывается при изменении состояния загрузки
  void onLoadingChanged(bool isLoading);
  
  /// Вызывается при изменении состояния ошибки
  void onErrorChanged(String? error);
  
  /// Вызывается при изменении текущего файла
  void onCurrentFileChanged(String? filePath);
  
  /// Вызывается при изменении состояния окна
  void onWindowStateChanged(WebViewWindowState? state);
}
```

## Data Transfer Objects

### WebView2Status

```dart
class WebView2Status {
  final WebView2Availability availability;
  final String? version;
  final String? errorMessage;
  final DateTime checkedAt;
  
  const WebView2Status({
    required this.availability,
    this.version,
    this.errorMessage,
    required this.checkedAt,
  });
  
  factory WebView2Status.available(String version) {
    return WebView2Status(
      availability: WebView2Availability.available,
      version: version,
      checkedAt: DateTime.now(),
    );
  }
  
  factory WebView2Status.notInstalled() {
    return WebView2Status(
      availability: WebView2Availability.notInstalled,
      checkedAt: DateTime.now(),
    );
  }
  
  factory WebView2Status.error(String errorMessage) {
    return WebView2Status(
      availability: WebView2Availability.unknown,
      errorMessage: errorMessage,
      checkedAt: DateTime.now(),
    );
  }
}
```

### WebViewWindowConfig

```dart
class WebViewWindowConfig {
  final double width;
  final double height;
  final double x;
  final double y;
  final bool resizable;
  final bool minimizable;
  final bool maximizable;
  
  const WebViewWindowConfig({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.resizable = true,
    this.minimizable = true,
    this.maximizable = true,
  });
  
  static const WebViewWindowConfig defaultConfig = WebViewWindowConfig(
    width: 1200,
    height: 800,
    x: 100,
    y: 100,
  );
}
```

## Error Contracts

### WebViewError

```dart
abstract class WebViewError implements Exception {
  String get message;
  String get userFriendlyMessage;
  bool get isRecoverable;
  WebViewErrorType get type;
}

enum WebViewErrorType {
  webview2NotAvailable,
  fileNotFound,
  invalidOpenAPI,
  networkError,
  unknown;
}

class WebView2NotAvailableError implements WebViewError {
  @override
  String get message => 'WebView2 is not available on this system';
  
  @override
  String get userFriendlyMessage => 'WebView2 не установлен. Пожалуйста, установите Microsoft Edge WebView2 или откройте файл во внешнем браузере.';
  
  @override
  bool get isRecoverable => true;
  
  @override
  WebViewErrorType get type => WebViewErrorType.webview2NotAvailable;
}
```

## Configuration Contracts

### WebViewConfig

```dart
class WebViewConfig {
  final Duration checkTimeout;
  final Duration cacheTimeout;
  final int maxCacheSize;
  final bool enableDebugMode;
  final String fallbackBrowser;
  
  const WebViewConfig({
    this.checkTimeout = const Duration(seconds: 5),
    this.cacheTimeout = const Duration(hours: 24),
    this.maxCacheSize = 100,
    this.enableDebugMode = false,
    this.fallbackBrowser = 'default',
  });
}
```

### PersistenceConfig

```dart
class PersistenceConfig {
  final String windowStateKey;
  final String webview2StatusKey;
  final String lastCheckKey;
  final Duration stateSaveInterval;
  
  const PersistenceConfig({
    this.windowStateKey = 'webview_window_states',
    this.webview2StatusKey = 'webview2_status',
    this.lastCheckKey = 'webview2_last_check',
    this.stateSaveInterval = const Duration(seconds: 1),
  });
}
```

## Integration Points

### File System Integration

Используется существующий `OpenAPIFileHandler` для:
- Обработки OpenAPI файлов
- Валидации структуры файлов
- Извлечения метаданных

**Integration Requirements**:
- Интегрироваться с существующим обработчиком файлов
- Использовать существующую логику валидации
- Не дублировать функциональность

### Platform Integration

```dart
abstract class IPlatformDetector {
  /// Определяет текущую платформу
  PlatformType getCurrentPlatform();
  
  /// Проверяет поддерживается ли WebView2 на текущей платформе
  bool supportsWebView2();
  
  /// Возвращает соответствующую реализацию IWebViewContainer
  IWebViewContainer createWebViewContainer();
}

enum PlatformType { windows, macos, linux, unknown }
```

## Testing Contracts

### Mock Implementations

```dart
class MockWebView2CheckerService implements IWebView2CheckerService {
  WebView2Status _mockStatus;
  
  MockWebView2CheckerService(this._mockStatus);
  
  @override
  Future<WebView2Status> checkWebView2Availability() async {
    return _mockStatus;
  }
  
  // ... другие методы
}
```

### Test Scenarios

```dart
abstract class IWebViewTestScenario {
  /// Настраивает тестовое окружение
  Future<void> setUp();
  
  /// Выполняет тестовый сценарий
  Future<void> execute();
  
  /// Проверяет результаты
  Future<void> verify();
  
  /// Очищает тестовое окружение
  Future<void> tearDown();
}
```