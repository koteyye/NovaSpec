# Workspace Viewers API Contracts

**Feature**: File Format Support and Viewers  
**Version**: 1.0.0  
**Date**: 2025-11-01  

## Overview

API контракты для компонентов просмотра файлов в рабочей зоне NovaSpec. Определяют интерфейсы для Markdown/HTML рендеринга, аудиоплеера, Swagger UI и универсального редактора кода.

## Core Interfaces

### FileViewer Interface

```dart
abstract class FileViewer {
  String get supportedExtension;
  Future<void> loadFile(String filePath);
  Widget build(BuildContext context);
  void dispose();
}
```

### AudioPlayerInterface

```dart
abstract class AudioPlayerInterface {
  Future<void> loadAudio(String filePath);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<PlayerState> get playerStateStream;
}
```

### MarkdownRendererInterface

```dart
abstract class MarkdownRendererInterface {
  Future<String> renderMarkdown(String content);
  Future<void> loadMarkdownFile(String filePath);
  Widget buildMarkdownView(BuildContext context);
}
```

### SwaggerViewerInterface

```dart
abstract class SwaggerViewerInterface {
  Future<void> loadOpenAPISpec(String filePath);
  Future<void> startSwaggerServer();
  Future<void> stopSwaggerServer();
  Widget buildSwaggerView(BuildContext context);
  String? get swaggerUrl;
}
```

## Service Contracts

### MarkdownService

```dart
class MarkdownService {
  Future<String> parseMarkdown(String content);
  Future<String> loadFromFile(String filePath);
  Future<void> saveToFile(String filePath, String content);
  bool isValidMarkdownFile(String filePath);
}
```

### AudioService

```dart
class AudioService {
  Future<bool> isValidAudioFile(String filePath);
  Future<Duration> getAudioDuration(String filePath);
  Future<String> getAudioMetadata(String filePath);
  List<String> getSupportedFormats();
}
```

### OpenAPIService

```dart
class OpenAPIService {
  Future<Map<String, dynamic>> parseOpenAPISpec(String filePath);
  Future<bool> isValidOpenAPIFile(String filePath);
  Future<String> generateSwaggerHtml(String specContent);
  Future<int> findAvailablePort(int startPort);
}
```

### SwaggerServerService

```dart
class SwaggerServerService {
  Future<void> startServer(int port, String htmlContent);
  Future<void> stopServer();
  String? get serverUrl;
  bool get isRunning;
  int? get port;
  
  // Background service methods
  Future<void> initializeBackgroundServer();
  Future<void> ensureServerRunning();
}
```

## Data Models

### WorkspaceFile

```dart
class WorkspaceFile {
  final String id;
  final String name;
  final String path;
  final String extension;
  final int size;
  final DateTime lastModified;
  final FileType type;
  final Map<String, dynamic>? metadata;
  
  // Methods
  Future<String> readContent();
  Future<void> saveContent(String content);
  bool isSupported();
}
```

### AudioPlayerState

```dart
class AudioPlayerState extends ChangeNotifier {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters and methods for state management
}
```

### OpenAPISpec

```dart
class OpenAPISpec {
  final String filePath;
  final Map<String, dynamic> spec;
  final String version;
  final String? title;
  final String? description;
  final List<APIEndpoint> endpoints;
  
  // Methods for parsing and validation
}
```

## Error Handling Contracts

### ViewerException

```dart
class ViewerException implements Exception {
  final String message;
  final String? filePath;
  final ViewerErrorType type;
  final dynamic originalError;
  
  // Constructor and methods
}
```

### Error Types

```dart
enum ViewerErrorType {
  fileNotFound,
  unsupportedFormat,
  parseError,
  renderError,
  networkError,
  serverError,
}
```

## Event Contracts

### ViewerEvents

```dart
abstract class ViewerEvent {
  final String viewerId;
  final DateTime timestamp;
}

class FileLoadedEvent extends ViewerEvent {
  final String filePath;
  final int fileSize;
}

class AudioPlaybackEvent extends ViewerEvent {
  final AudioPlaybackAction action;
  final Duration? position;
}

class SwaggerServerEvent extends ViewerEvent {
  final SwaggerServerAction action;
  final String? url;
  final int? port;
}
```

## Configuration Contracts

### ViewerConfig

```dart
class ViewerConfig {
  final int maxFileSize;
  final List<String> supportedMarkdownExtensions;
  final List<String> supportedAudioExtensions;
  final List<String> supportedCodeExtensions;
  final int swaggerServerPortRange;
  final Duration serverTimeout;
  final bool enableCaching;
}
```

## Integration Points

### Existing Services Integration

```dart
// Integration with FileService
abstract class FileServiceIntegration {
  Future<WorkspaceFile> createWorkspaceFile(String path);
  Future<bool> validateFileAccess(String path);
}

// Integration with ToastService
abstract class ToastServiceIntegration {
  void showSuccess(String message);
  void showError(String message);
  void showWarning(String message);
}

// Integration with CacheService
abstract class CacheServiceIntegration {
  Future<T?> getCachedData<T>(String key);
  Future<void> setCachedData<T>(String key, T data, Duration? ttl);
}
```

## Performance Contracts

### Loading Time Guarantees

- Markdown files (<1MB): <500ms
- HTML files (<2MB): <750ms  
- Audio files (<50MB): <2s
- OpenAPI specs (<5MB): <3s
- Code files (<1MB): <300ms

### Memory Usage Limits

- Markdown viewer: <50MB per file
- HTML viewer: <100MB per file
- Audio player: <200MB per file
- Swagger UI: <150MB per spec
- Code editor: <75MB per file

## Security Contracts

### File Access Validation

```dart
abstract class FileSecurityValidator {
  Future<bool> validateFilePath(String path);
  Future<bool> validateFileContent(String content);
  Future<bool> checkPermissions(String path);
}
```

### Content Sanitization

```dart
abstract class ContentSanitizer {
  Future<String> sanitizeHtml(String html);
  Future<String> sanitizeMarkdown(String markdown);
  Future<String> sanitizeCode(String code);
}
```

## Testing Contracts

### Manual Testing Requirements

```dart
abstract class ViewerTestScenarios {
  // Markdown viewer tests
  Future<void> testMarkdownRendering();
  Future<void> testMarkdownEditing();
  
  // Audio player tests
  Future<void> testAudioPlayback();
  Future<void> testAudioControls();
  
  // Swagger UI tests
  Future<void> testSwaggerServer();
  Future<void> testOpenAPIParsing();
  
  // Code editor tests
  Future<void> testCodeEditing();
  Future<void> testSyntaxHighlighting();
}
```

## Version Compatibility

### API Versioning

- Current version: 1.0.0
- Backward compatibility: Supported until 2.0.0
- Breaking changes: Require major version increment
- Deprecation policy: 6 months notice

### Flutter Version Compatibility

- Minimum Flutter version: 3.10.0
- Minimum Dart version: 3.0.0
- Target platform: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+)

---

**Contract Status**: Ready for Implementation  
**Last Updated**: 2025-11-01  
**Next Review**: 2025-12-01