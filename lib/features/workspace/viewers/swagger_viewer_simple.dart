import 'package:flutter/material.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/swagger_server_service.dart';
import '../models/webview/openapi_file_info.dart';
import '../widgets/webview2/webview2_container.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/widgets/modern_button.dart';

class SwaggerViewerSimple extends StatefulWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const SwaggerViewerSimple({
    super.key,
    required this.filePath,
    this.onContentChanged,
  });

  @override
  State<SwaggerViewerSimple> createState() => SwaggerViewerSimpleState();
}

class SwaggerViewerSimpleState extends State<SwaggerViewerSimple> {
  late final SwaggerServerService _swaggerService;
  WebViewController? _webViewController;

  bool _isLoading = true;
  bool _disposed = false;
  bool _isLoadingInProgress = false;
  String? _errorMessage;
  String? _serverUrl;

  // WebView2 integration
  OpenAPIFileInfo? _openAPIFileInfo;
  bool _useWebView2 = false;

  @override
  void initState() {
    super.initState();
    _swaggerService = SwaggerServerService();
    // Увеличиваем счётчик ссылок на сервер
    _swaggerService.addReference();

    // Проверяем, можно ли использовать WebView2
    _checkWebView2Availability();
    _initWebView();
    _loadSwaggerSpec();
  }

  @override
  void dispose() {
    _disposed = true;
    // Уменьшаем счётчик ссылок (сервер остановится автоматически, если это последняя ссылка)
    _swaggerService.removeReference();
    super.dispose();
  }

  void _checkWebView2Availability() {
    // Проверяем доступность WebView2 на Windows
    if (Platform.isWindows) {
      try {
        final file = File(widget.filePath);
        _openAPIFileInfo = OpenAPIFileInfo(
          filePath: file.path,
          fileType: file.path.toLowerCase().split('.').last,
          fileName: file.path.split(Platform.pathSeparator).last,
          fileSize: file.lengthSync(),
          lastModified: file.lastModifiedSync(),
        );
        _useWebView2 = true;
      } catch (e) {
        _useWebView2 = false;
      }
    }
  }

  void _initWebView() {
    // Если используем WebView2 на Windows, не инициализируем Flutter WebView
    if (_useWebView2) {
      return;
    }

    // На других платформах или fallback для Windows
    if (Platform.isWindows && !_useWebView2) {
      return;
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Page loading started
          },
          onPageFinished: (String url) {
            if (_disposed || !mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (_disposed || !mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage = 'Ошибка загрузки: ${error.description}';
            });
          },
        ),
      );
  }

  Future<void> _loadSwaggerSpec() async {
    if (_isLoadingInProgress || _disposed || !mounted) {
      return;
    }

    _isLoadingInProgress = true;
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        throw Exception('Swagger файл не найден: ${widget.filePath}');
      }

      final url = await _swaggerService.loadOpenAPISpec(widget.filePath);

      if (_disposed || !mounted) return;

      _serverUrl = url;

      // Если используем WebView2 на Windows
      if (_useWebView2 && _openAPIFileInfo != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
      // На Windows без WebView2 открываем в браузере
      else if (Platform.isWindows && !_useWebView2) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else if (_webViewController != null) {
        // На других платформах загружаем в WebView
        await _webViewController!.loadRequest(Uri.parse(url));
      }
    } catch (e) {
      if (_disposed || !mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (!_disposed && mounted) {
        error(description: 'Ошибка загрузки Swagger: ${e.toString()}');
      }
    } finally {
      _isLoadingInProgress = false;
    }
  }

  Future<void> _openInBrowser() async {
    if (_serverUrl == null) return;

    try {
      final uri = Uri.parse(_serverUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        success(description: 'Swagger UI открыт в браузере');
      } else {
        error(description: 'Не удалось открыть браузер');
      }
    } catch (e) {
      error(description: 'Ошибка открытия браузера: $e');
    }
  }

  Widget _buildWebView2Container() {
    if (_openAPIFileInfo == null) {
      return const Center(child: Text('Ошибка инициализации файла OpenAPI'));
    }

    return WebView2Container(
      fileInfo: _openAPIFileInfo!,
      width: double.infinity,
      height: double.infinity,
      onLoadingChanged: (isLoading) {
        if (_disposed || !mounted) return;
        setState(() {
          _isLoading = isLoading;
        });
      },
      onError: (error) {
        if (_disposed || !mounted) return;
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      },
      onWebViewReady: () {
        // WebView ready callback
      },
    );
  }

  Widget _buildWindowsFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.api,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Swagger UI',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Сервер запущен на:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              _serverUrl ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            ModernButton(
              text: 'Открыть в браузере',
              type: ButtonType.primary,
              onPressed: _openInBrowser,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'WebView не поддерживается на Windows.\nИспользуйте браузер для просмотра.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка загрузки Swagger UI',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // На Windows с WebView2 показываем WebView2 контейнер
    if (_useWebView2 && _openAPIFileInfo != null) {
      // Показываем WebView2 с индикатором загрузки поверх, если загружается
      return Stack(
        children: [
          _buildWebView2Container(),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Загрузка Swagger UI...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // На Windows без WebView2 показываем fallback с кнопкой открытия в браузере
    if (Platform.isWindows) {
      return _buildWindowsFallback();
    }

    // Для других платформ показываем индикатор загрузки если еще загружается
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Загрузка Swagger UI...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (_webViewController == null) {
      return const Center(child: Text('Ошибка инициализации WebView'));
    }

    return WebViewWidget(controller: _webViewController!);
  }
}
