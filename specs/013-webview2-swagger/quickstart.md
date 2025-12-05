# Quick Start Guide: WebView2 SwaggerUI Integration

**Date**: 02.11.2025  
**Feature**: WebView2 SwaggerUI Integration

## Overview

Этот гайд поможет быстро начать разработку интеграции WebView2 для отображения SwaggerUI с OpenAPI файлами в Windows версии приложения.

## Prerequisites

### Development Environment
- Flutter 3.x
- Windows 10/11 с Visual Studio 2019+
- Microsoft Edge WebView2 (для тестирования)
- Git

### Project Dependencies
Убедитесь что в `pubspec.yaml` есть:
```yaml
dependencies:
  webview_windows: ^0.2.2
  webview_flutter: ^4.4.2
  provider: ^6.0.5
  get_it: ^7.2.0
  win32: ^5.0.6
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

## Project Structure

```
lib/
├── features/workspace/
│   ├── providers/
│   │   ├── webview_provider.dart          # Создать
│   │   └── openapi_file_provider.dart     # Существующий
│   ├── services/
│   │   ├── webview2_checker_service.dart  # Создать
│   │   └── swagger_server_service.dart    # Существующий
│       ├── widgets/
│       │   ├── webview2_container.dart        # Создать
│       │   ├── webview_container.dart         # Обновить
│       │   └── fallback_webview_widget.dart   # Обновить (существующий, изменить текст)
│   └── models/
│       ├── webview_state.dart             # Создать
│       └── openapi_file_info.dart         # Создать
└── shared/services/
    └── di_container.dart                  # Обновить
```

## Implementation Steps

### Step 1: Create Core Models

Создайте `lib/features/workspace/models/webview_state.dart`:

```dart
import 'package:flutter/foundation.dart';

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
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void setError(String? error) {
    _hasError = error != null;
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
  
  void setWindowState(WebViewWindowState? state) {
    _windowState = state;
    notifyListeners();
  }
  
  void setCurrentOpenAPIFile(String? filePath) {
    _currentOpenAPIFile = filePath;
    notifyListeners();
  }
}
```

### Step 2: Create WebView2 Checker Service

Создайте `lib/features/workspace/services/webview2_checker_service.dart`:

```dart
import 'package:webview_windows/webview_windows.dart';
import 'package:win32/win32.dart';

class WebView2CheckerService {
  static const String _cacheKey = 'webview2_status';
  static const Duration _cacheTimeout = Duration(hours: 24);
  
  Future<WebView2Status> checkWebView2Availability() async {
    try {
      // Проверяем кэш
      final cachedStatus = await _getCachedStatus();
      if (cachedStatus != null) {
        return cachedStatus;
      }
      
      // Проверяем через webview_windows
      final version = await WebviewController.getWebViewVersion();
      if (version != null) {
        final status = WebView2Status.available(version);
        await _cacheStatus(status);
        return status;
      }
      
      // Fallback проверка через реестр
      final registryStatus = await _checkRegistry();
      await _cacheStatus(registryStatus);
      return registryStatus;
      
    } catch (e) {
      final status = WebView2Status.error(e.toString());
      await _cacheStatus(status);
      return status;
    }
  }
  
  Future<WebView2Status?> _getCachedStatus() async {
    // Реализация кэширования через SharedPreferences
    return null; // Заглушка
  }
  
  Future<void> _cacheStatus(WebView2Status status) async {
    // Реализация сохранения в SharedPreferences
  }
  
  Future<WebView2Status> _checkRegistry() async {
    // Реализация проверки реестра Windows
    return WebView2Status.notInstalled();
  }
}
```

### Step 3: Create WebView Provider

Создайте `lib/features/workspace/providers/webview_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../models/webview_state.dart';
import '../services/webview2_checker_service.dart';
import '../services/swagger_server_service.dart'; // Существующий сервис

class WebViewProvider extends ChangeNotifier {
  final WebViewState _state = WebViewState();
  final WebView2CheckerService _checkerService;
  final SwaggerServerService _swaggerServerService; // Существующий сервис
  
  WebViewProvider(
    this._checkerService,
    this._swaggerServerService,
  );
  
  WebViewState get state => _state;
  
  Future<void> openOpenAPIFile(String filePath) async {
    _state.setLoading(true);
    _state.clearError();
    
    try {
      // Проверяем наличие WebView2
      final webview2Status = await _checkerService.checkWebView2Availability();
      
      if (webview2Status.availability != WebView2Availability.available) {
        _state.setError('WebView2 не установлен');
        return;
      }
      
      // Используем существующий SwaggerServerService для получения URL
      final swaggerUrl = await _swaggerServerService.getSwaggerUrl(filePath);
      
      // Устанавливаем текущий файл
      _state.setCurrentOpenAPIFile(filePath);
      
      // Здесь будет загрузка URL в WebView2
      // await _webview2Container.loadUrl(swaggerUrl);
      
    } catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }
}
```

### Step 4: Create WebView2 Container Widget

Создайте `lib/features/workspace/widgets/webview2_container.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:provider/provider.dart';
import '../providers/webview_provider.dart';

class WebView2Container extends StatefulWidget {
  const WebView2Container({Key? key}) : super(key: key);
  
  @override
  State<WebView2Container> createState() => _WebView2ContainerState();
}

class _WebView2ContainerState extends State<WebView2Container> {
  WebviewController? _controller;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  Future<void> _initializeWebView() async {
    try {
      _controller = WebviewController();
      
      await _controller?.initialize();
      
      // Настраиваем события
      _controller?.onLoadingStateChanged.listen((state) {
        // Обработка изменений состояния загрузки
      });
      
      _controller?.onWebMessageReceived.listen((message) {
        // Обработка сообщений от WebView
      });
      
    } catch (e) {
      // Обработка ошибок инициализации
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WebViewProvider>(
      builder: (context, provider, child) {
        if (provider.state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.state.hasError) {
          return _buildErrorWidget(provider.state.errorMessage!);
        }
        
        if (_controller == null) {
          return const Center(child: Text('WebView2 инициализируется...'));
        }
        
        return _controller != null 
          ? Webview(_controller!)
          : const SizedBox.shrink();
      },
    );
  }
  
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Ошибка: $error'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<WebViewProvider>(context, listen: false)
                .openOpenAPIFile(provider.state.currentOpenAPIFile!);
            },
            child: Text('Повторить'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

### Step 5: Update DI Container

Обновите `lib/shared/services/di_container.dart`:

```dart
import 'package:get_it/get_it.dart';
import '../../features/workspace/services/webview2_checker_service.dart';
import '../../features/workspace/services/swagger_server_service.dart'; // Существующий
import '../../features/workspace/providers/webview_provider.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Существующие сервисы...
  
  // Новый сервис для проверки WebView2
  getIt.registerSingleton<WebView2CheckerService>(
    WebView2CheckerService(),
  );
  
  // SwaggerServerService уже должен быть зарегистрирован
  
  getIt.registerFactory<WebViewProvider>(
    () => WebViewProvider(
      getIt<WebView2CheckerService>(),
      getIt<SwaggerServerService>(), // Существующий сервис
    ),
  );
}
```

### Step 6: Integration with Existing File Handler

Найдите где обрабатывается открытие OpenAPI файлов и добавьте:

```dart
// В существующем обработчике файлов
if (isOpenAPIFile(filePath)) {
  final webviewProvider = getIt<WebViewProvider>();
  await webviewProvider.openOpenAPIFile(filePath);
  return;
}
```

## Testing

### Manual Testing Checklist

1. **WebView2 Detection**
   - [ ] Установлен WebView2 - показывает WebView
   - [ ] Не установлен WebView2 - показывает fallback
   - [ ] Старая версия WebView2 - показывает fallback

2. **File Opening**
   - [ ] YAML файл открывается корректно
   - [ ] JSON файл открывается корректно
   - [ ] Некорректный файл показывает ошибку

3. **UI Functionality**
   - [ ] Изменение размера окна работает
   - [ ] Положение окна сохраняется
   - [ ] Кнопки SwaggerUI работают

4. **Error Handling**
   - [ ] Ошибки сети обрабатываются
   - [ ] Ошибки загрузки обрабатываются
   - [ ] Приложение не падает при ошибках

### Debug Mode

Добавьте в `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const bool enableWebViewDebug = kDebugMode;
  static const String webview2MinVersion = '90.0.0';
}
```

## Common Issues

### WebView2 Not Found
**Problem**: `WebView2 is not available`  
**Solution**: Установите Microsoft Edge WebView2 с официального сайта

### File Loading Issues
**Problem**: OpenAPI файл не загружается  
**Solution**: Проверьте путь к файлу и права доступа

### Performance Issues
**Problem**: Медленная загрузка  
**Solution**: Проверьте размер файла и настройки кэширования

## Next Steps

1. Реализуйте сохранение состояния окна
2. Добавьте поддержку горячих клавиш
3. Интегрируйте с существующей системой тем
4. Добавьте аналитику использования

## Support

При возникновении проблем:
1. Проверьте логи приложения
2. Убедитесь что WebView2 установлен
3. Проверьте версию Flutter и зависимостей
4. Создайте issue в репозитории проекта