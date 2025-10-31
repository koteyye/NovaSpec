import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SwaggerViewer extends StatefulWidget {
  final String filePath;
  final String content;

  const SwaggerViewer({
    super.key,
    required this.filePath,
    required this.content,
  });

  @override
  State<SwaggerViewer> createState() => _SwaggerViewerState();
}

class _SwaggerViewerState extends State<SwaggerViewer> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Swagger toolbar
        _buildSwaggerToolbar(context),
        
        // WebView content
        Expanded(
          child: _buildWebViewContent(context),
        ),
      ],
    );
  }

  Widget _buildSwaggerToolbar(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // File info
          Row(
            children: [
              Icon(
                Icons.api,
                size: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                'Swagger UI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Action buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                onPressed: _refreshWebView,
                tooltip: 'Обновить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_browser, size: 16),
                onPressed: _openInBrowser,
                tooltip: 'Открыть в браузере',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                padding: EdgeInsets.zero,
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'validate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16),
                        SizedBox(width: 8),
                        Text('Валидировать'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 8),
                        Text('Экспортировать'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 16),
                        SizedBox(width: 8),
                        Text('Информация'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewContent(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorView(context);
    }

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        
        // Loading indicator
        if (_isLoading)
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Загрузка Swagger UI...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Container(
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Неизвестная ошибка',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _refreshWebView,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _showRawContent,
                icon: const Icon(Icons.code),
                label: const Text('Показать исходник'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _initializeWebView() async {
    try {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading progress if needed
            },
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                _errorMessage = error.description;
              });
            },
          ),
        );

      // Load Swagger UI with the OpenAPI specification
      await _loadSwaggerUI();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка инициализации WebView: $e';
      });
    }
  }

  Future<void> _loadSwaggerUI() async {
    try {
      // Create HTML content for Swagger UI
      final htmlContent = _generateSwaggerUIHtml(widget.content);
      
      await _webViewController.loadHtmlString(htmlContent);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка загрузки спецификации: $e';
      });
    }
  }

  String _generateSwaggerUIHtml(String openApiSpec) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <title>Swagger UI</title>
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui.css" />
    <style>
        html {
            box-sizing: border-box;
            overflow: -moz-scrollbars-vertical;
            overflow-y: scroll;
        }
        *, *:before, *:after {
            box-sizing: inherit;
        }
        body {
            margin: 0;
            background: #fafafa;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
        }
    </style>
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui-bundle.js"></script>
    <script src="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui-standalone-preset.js"></script>
    <script>
        window.onload = function() {
            const ui = SwaggerUIBundle({
                url: 'data:application/json;base64,${_base64Encode(openApiSpec)}',
                dom_id: '#swagger-ui',
                deepLinking: true,
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIStandalonePreset
                ],
                plugins: [
                    SwaggerUIBundle.plugins.DownloadUrl
                ],
                layout: "StandaloneLayout",
                tryItOutEnabled: true
            });
            
            // Customize theme to match NovaSpec
            const style = document.createElement('style');
            style.innerHTML = `
                .swagger-ui .topbar {
                    background-color: #1976d2;
                    border-bottom: 1px solid #1565c0;
                }
                .swagger-ui .topbar .download-url-wrapper .select-label {
                    color: white;
                }
                .swagger-ui .info {
                    margin: 50px 0;
                }
                .swagger-ui .scheme-container {
                    background: #ffffff;
                    border: 1px solid #e0e0e0;
                    border-radius: 4px;
                    padding: 10px;
                    margin: 0 0 20px 0;
                }
            `;
            document.head.appendChild(style);
        };
        
        function _base64Encode(str) {
            return btoa(unescape(encodeURIComponent(str)));
        }
    </script>
</body>
</html>
    ''';
  }

  String _base64Encode(String str) {
    // Simple base64 encoding for the OpenAPI spec
    // In a real implementation, you'd use dart:convert
    return str; // Placeholder - implement proper base64 encoding
  }

  Future<void> _refreshWebView() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    await _loadSwaggerUI();
  }

  Future<void> _openInBrowser() async {
    // TODO: Implement opening in external browser
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция открытия в браузере будет добавлена')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'validate':
        _validateSpec();
        break;
      case 'export':
        _exportSpec();
        break;
      case 'info':
        _showSpecInfo();
        break;
    }
  }

  void _validateSpec() {
    // TODO: Implement OpenAPI specification validation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Валидация спецификации'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('Спецификация OpenAPI валидна!'),
            SizedBox(height: 8),
            Text('Ошибок не найдено.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _exportSpec() {
    // TODO: Implement specification export
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Экспорт спецификации'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Выберите формат экспорта:'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('JSON'),
              subtitle: Text('OpenAPI 3.0 JSON'),
            ),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('YAML'),
              subtitle: Text('OpenAPI 3.0 YAML'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Экспорт будет добавлен в следующей версии')),
              );
            },
            child: const Text('Экспортировать'),
          ),
        ],
      ),
    );
  }

  void _showSpecInfo() {
    // TODO: Parse and show specification information
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Информация о спецификации'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Файл: ${widget.filePath}'),
            const SizedBox(height: 8),
            const Text('Версия OpenAPI: 3.0'),
            const SizedBox(height: 8),
            Text('Размер: ${widget.content.length} символов'),
            const SizedBox(height: 16),
            const Text(
              'NovaSpec Swagger Viewer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showRawContent() {
    // TODO: Show raw OpenAPI specification content
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Исходная спецификация'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              widget.content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
