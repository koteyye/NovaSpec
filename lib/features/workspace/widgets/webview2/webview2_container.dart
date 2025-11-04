import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview_flutter;

import '../../../../core/utils/app_logger.dart';
import '../../../../shared/services/di_container.dart';
import '../../models/webview/openapi_file_info.dart';
import '../../services/swagger_server_service.dart';

/// Контейнер для отображения WebView2 на Windows и WebView на других платформах
class WebView2Container extends StatefulWidget {
  final OpenAPIFileInfo fileInfo;
  final double? width;
  final double? height;
  final Function(bool)? onLoadingChanged;
  final Function(String)? onError;
  final VoidCallback? onWebViewReady;

  const WebView2Container({
    super.key,
    required this.fileInfo,
    this.width,
    this.height,
    this.onLoadingChanged,
    this.onError,
    this.onWebViewReady,
  });

  @override
  State<WebView2Container> createState() => _WebView2ContainerState();
}

class _WebView2ContainerState extends State<WebView2Container> {
  // WebView2 контроллер для Windows
  WebviewController? _webviewController;

  // WebView контроллер для других платформ
  webview_flutter.WebViewController? _flutterWebViewController;

  bool _isInitialized = false;
  bool _disposed = false;
  SwaggerServerService? _swaggerService;
  StreamSubscription<LoadingState>? _loadingStateSubscription;

  @override
  void initState() {
    super.initState();
    // Получаем ссылку на сервис и увеличиваем счётчик ссылок
    _swaggerService = getIt<SwaggerServerService>();
    _swaggerService!.addReference();
    _initializeWebView();
  }

  @override
  void dispose() {
    _disposed = true;
    // Отменяем подписку на события загрузки
    _loadingStateSubscription?.cancel();
    _loadingStateSubscription = null;
    _disposeWebView();
    // Уменьшаем счётчик ссылок (сервер остановится автоматически, если это последняя ссылка)
    _swaggerService?.removeReference();
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await _initializeWebView2();
      } else {
        await _initializeFlutterWebView();
      }

      if (_disposed || !mounted) return;

      setState(() {
        _isInitialized = true;
      });

      widget.onWebViewReady?.call();

      // НЕ загружаем автоматически - сервер уже запущен родительским виджетом
      // Просто загружаем URL если сервер уже работает
      if (_swaggerService!.isRunning && _swaggerService!.serverUrl != null) {
        await _loadUrl(_swaggerService!.serverUrl!);
      }
    } catch (e) {
      AppLogger.error('Failed to initialize WebView: $e');
      if (!_disposed && mounted) {
        widget.onError?.call('Failed to initialize WebView: $e');
      }
    }
  }

  Future<void> _loadUrl(String url) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await _webviewController!.loadUrl(url);
      } else {
        await _flutterWebViewController!.loadRequest(Uri.parse(url));
      }
    } catch (e) {
      AppLogger.error('Failed to load URL: $e');
      widget.onError?.call('Failed to load URL: $e');
    }
  }

  Future<void> _initializeWebView2() async {
    try {
      _webviewController = WebviewController();

      await _webviewController!.initialize();

      // Добавляем обработчики событий навигации с проверкой mounted
      _loadingStateSubscription = _webviewController!.loadingState.listen(
        (state) {
          if (_disposed || !mounted) return;
          if (state == LoadingState.loading) {
            widget.onLoadingChanged?.call(true);
          } else if (state == LoadingState.navigationCompleted) {
            widget.onLoadingChanged?.call(false);
          }
        },
        onError: (error) {
          // Игнорируем ошибки стрима
        },
        cancelOnError: false,
      );
    } catch (e) {
      AppLogger.error('Failed to initialize WebView2: $e');
      rethrow;
    }
  }

  Future<void> _initializeFlutterWebView() async {
    try {
      _flutterWebViewController = webview_flutter.WebViewController()
        ..setJavaScriptMode(webview_flutter.JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          webview_flutter.NavigationDelegate(
            onProgress: (int progress) {
              // Loading progress
            },
            onPageStarted: (String url) {
              if (!_disposed && mounted) {
                widget.onLoadingChanged?.call(true);
              }
            },
            onPageFinished: (String url) {
              if (!_disposed && mounted) {
                widget.onLoadingChanged?.call(false);
              }
            },
            onWebResourceError: (webview_flutter.WebResourceError error) {
              AppLogger.error('WebView resource error: ${error.description}');
              if (!_disposed && mounted) {
                widget.onError?.call('WebView error: ${error.description}');
              }
            },
          ),
        );
    } catch (e) {
      AppLogger.error('Failed to initialize Flutter WebView: $e');
      rethrow;
    }
  }

  Future<void> _disposeWebView() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        if (_webviewController != null) {
          await _webviewController!.dispose();
          _webviewController = null;
        }
      } else {
        // Flutter WebView автоматически освобождается при dispose виджета
        _flutterWebViewController = null;
      }
    } catch (e) {
      AppLogger.error('Error disposing WebView: $e');
    }
  }

  Future<void> loadSwaggerUI() async {
    if (!_isInitialized || _disposed) {
      return;
    }

    try {
      if (!_disposed && mounted) {
        widget.onLoadingChanged?.call(true);
      }

      // Используем существующую ссылку на SwaggerServerService
      if (_swaggerService == null) {
        throw Exception('SwaggerServerService not initialized');
      }

      final swaggerUrl = await _swaggerService!.loadOpenAPISpec(
        widget.fileInfo.filePath,
      );

      if (swaggerUrl.isEmpty) {
        throw Exception('Failed to get Swagger URL from server service');
      }

      await _loadUrl(swaggerUrl);
    } catch (e) {
      AppLogger.error('Failed to load Swagger UI: $e');
      if (!_disposed && mounted) {
        widget.onError?.call('Failed to load Swagger UI: $e');
        widget.onLoadingChanged?.call(false);
      }
    }
  }

  Future<void> reload() async {
    if (!_isInitialized || _disposed) {
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await _webviewController!.reload();
      } else {
        await _flutterWebViewController!.reload();
      }
    } catch (e) {
      AppLogger.error('Failed to reload WebView: $e');
      if (!_disposed && mounted) {
        widget.onError?.call('Failed to reload WebView: $e');
      }
    }
  }

  Future<void> goBack() async {
    if (!_isInitialized || _disposed) {
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        try {
          await _webviewController!.goBack();
        } catch (e) {
          // WebView2 goBack not available
        }
      } else {
        if (await _flutterWebViewController!.canGoBack()) {
          await _flutterWebViewController!.goBack();
        }
      }
    } catch (e) {
      AppLogger.error('Failed to go back in WebView: $e');
    }
  }

  Future<void> goForward() async {
    if (!_isInitialized || _disposed) {
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        try {
          await _webviewController!.goForward();
        } catch (e) {
          // WebView2 goForward not available
        }
      } else {
        if (await _flutterWebViewController!.canGoForward()) {
          await _flutterWebViewController!.goForward();
        }
      }
    } catch (e) {
      AppLogger.error('Failed to go forward in WebView: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[100],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing WebView...'),
            ],
          ),
        ),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return _buildWebView2();
    } else {
      return _buildFlutterWebView();
    }
  }

  Widget _buildWebView2() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _webviewController != null
          ? Webview(_webviewController!)
          : Container(
              color: Colors.grey[200],
              child: const Center(
                child: Text('WebView2 initialization failed'),
              ),
            ),
    );
  }

  Widget _buildFlutterWebView() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _flutterWebViewController != null
          ? webview_flutter.WebViewWidget(
              controller: _flutterWebViewController!,
            )
          : Container(
              color: Colors.grey[200],
              child: const Center(child: Text('WebView initialization failed')),
            ),
    );
  }
}
