import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/webview/webview_state.dart';
import '../models/webview/webview_window_state.dart';
import '../models/webview/openapi_file_info.dart';
import '../services/webview2_checker_service.dart';
import '../services/swagger_server_service.dart';
import '../../../core/utils/app_logger.dart';

/// Provider для управления состоянием WebView
class WebViewProvider extends ChangeNotifier {
  final WebViewState _state = WebViewState();
  final WebView2CheckerService _webview2CheckerService;
  final SwaggerServerService _swaggerServerService;

  
  WebViewProvider(
    this._webview2CheckerService,
    this._swaggerServerService,
  );
  
  WebViewState get state => _state;
  
  /// Инициализирует провайдер при запуске приложения
  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing WebViewProvider...');
      
      // Проверяем наличие WebView2
      final webview2Status = await _webview2CheckerService.checkAvailability();
      _state.setWebView2Status(webview2Status);
      
      if (webview2Status.isAvailable) {
        AppLogger.info('WebView2 is available for use');
      } else {
        AppLogger.warning('WebView2 not available: ${webview2Status.userMessage}');
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing WebViewProvider', error: e, stackTrace: stackTrace);
      _state.setError('Ошибка инициализации WebView: $e');
    }
  }
  
  /// Открывает OpenAPI файл в WebView
  Future<void> openOpenAPIFile(String filePath) async {
    try {
      AppLogger.info('Opening OpenAPI file: $filePath');
      
      _state.setLoading(true);
      _state.clearError();
      
      // Проверяем наличие WebView2
      final webview2Status = _state.webview2Status;
      if (webview2Status == null || webview2Status.needsFallback) {
        _state.setError('WebView2 недоступен. Используйте кнопку "Открыть в браузере".');
        return;
      }
      
      // Создаем информацию о файле
      final file = File(filePath);
      final fileInfo = OpenAPIFileInfo(
        filePath: filePath,
        fileType: filePath.toLowerCase().split('.').last,
        fileName: file.path.split(Platform.pathSeparator).last,
        fileSize: file.lengthSync(),
        lastModified: file.lastModifiedSync(),
      );
      
      if (!fileInfo.isValid()) {
        _state.setError('Неверный формат OpenAPI файла. Поддерживаются только .yaml, .yml и .json файлы.');
        return;
      }
      
      // Устанавливаем текущий файл
      _state.setCurrentOpenAPIFile(filePath);
      
      // Получаем URL для SwaggerUI
      final swaggerUrl = await _swaggerServerService.loadOpenAPISpec(filePath);
      if (swaggerUrl.isEmpty) {
        _state.setError('Не удалось получить URL для SwaggerUI');
        return;
      }
      
      AppLogger.info('Generated Swagger URL: $swaggerUrl');
      
      // Здесь будет загрузка URL в WebView2 контейнер
      // await _webview2Container.loadUrl(swaggerUrl);
      
      AppLogger.info('OpenAPI file opened successfully');
      
    } catch (e, stackTrace) {
      AppLogger.error('Error opening OpenAPI file', error: e, stackTrace: stackTrace);
      _state.setError('Ошибка открытия файла: $e');
    } finally {
      _state.setLoading(false);
    }
  }
  
  /// Закрывает текущий OpenAPI файл
  Future<void> closeOpenAPIFile() async {
    try {
      AppLogger.info('Closing OpenAPI file');
      
      _state.setCurrentOpenAPIFile(null);
      _state.clearError();
      
      // Здесь будет закрытие WebView2 контейнера
      // await _webview2Container.dispose();
      
      AppLogger.info('OpenAPI file closed successfully');
      
    } catch (e, stackTrace) {
      AppLogger.error('Error closing OpenAPI file', error: e, stackTrace: stackTrace);
      _state.setError('Ошибка закрытия файла: $e');
    }
  }
  
  /// Проверяет наличие WebView2 принудительно
  Future<void> checkWebView2Availability() async {
    try {
      AppLogger.info('Force checking WebView2 availability...');
      
      // Очищаем кэш
      await _webview2CheckerService.clearCache();
      
      // Проверяем заново
      final webview2Status = await _webview2CheckerService.checkAvailability();
      _state.setWebView2Status(webview2Status);
      
      AppLogger.info('WebView2 status updated: ${webview2Status.availability}');
      
    } catch (e, stackTrace) {
      AppLogger.error('Error checking WebView2 availability', error: e, stackTrace: stackTrace);
      _state.setError('Ошибка проверки WebView2: $e');
    }
  }
  
  /// Обновляет состояние окна WebView
  void updateWindowState(double width, double height, double x, double y, {bool isMaximized = false}) {
    try {
      final windowState = WebViewWindowState(
        width: width,
        height: height,
        x: x,
        y: y,
        isMaximized: isMaximized,
      );
      
      if (windowState.isValid()) {
        _state.setWindowState(windowState);
        AppLogger.info('WebView window state updated: $windowState');
      } else {
        AppLogger.warning('Invalid WebView window state: $windowState');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error updating WebView window state', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Сохраняет состояние окна
  Future<void> saveWindowState() async {
    try {
      final windowState = _state.windowState;
      if (windowState != null && windowState.isValid()) {
        // Здесь будет сохранение в SharedPreferences
        // await _saveWindowStateToPrefs(windowState);
        AppLogger.info('WebView window state saved: $windowState');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error saving WebView window state', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Восстанавливает состояние окна
  Future<void> restoreWindowState() async {
    try {
      // Здесь будет восстановление из SharedPreferences
      // final savedState = await _loadWindowStateFromPrefs();
      // if (savedState != null && savedState.isValid()) {
      //   _state.setWindowState(savedState);
      //   AppLogger.info('WebView window state restored: $savedState');
      // }
    } catch (e, stackTrace) {
      AppLogger.error('Error restoring WebView window state', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Сбрасывает состояние провайдера
  void reset() {
    try {
      AppLogger.info('Resetting WebViewProvider state');
      _state.reset();
    } catch (e, stackTrace) {
      AppLogger.error('Error resetting WebViewProvider', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Проверяет доступен ли WebView2
  bool get isWebView2Available {
    final status = _state.webview2Status;
    return status?.isAvailable ?? false;
  }
  
  /// Проверяет нужно ли показывать заглушку
  bool get needsFallback {
    final status = _state.webview2Status;
    return status?.needsFallback ?? true;
  }
  
  /// Получает текущий статус WebView2
  String get webview2Status {
    final status = _state.webview2Status;
    if (status == null) return 'Не проверялся';
    return status.userMessage;
  }
}