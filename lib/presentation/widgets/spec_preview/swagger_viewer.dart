import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/domain/services/swagger_service.dart';

/// Виджет для отображения Swagger UI
///
/// Использует WebView для отображения локального Swagger UI сервера
class SwaggerViewer extends StatefulWidget {
  final String specFilePath;

  const SwaggerViewer({
    super.key,
    required this.specFilePath,
  });

  @override
  State<SwaggerViewer> createState() => _SwaggerViewerState();
}

class _SwaggerViewerState extends State<SwaggerViewer> {
  late SwaggerService _swaggerService;
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _swaggerService = SwaggerService();
    _initializeSwagger();
  }

  @override
  void didUpdateWidget(SwaggerViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.specFilePath != widget.specFilePath) {
      _initializeSwagger();
    }
  }

  Future<void> _initializeSwagger() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Запускаем или перезапускаем Swagger сервер
      final success = await _swaggerService.start(widget.specFilePath);

      if (!success) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Не удалось запустить Swagger UI сервер';
        });
        return;
      }

      // Инициализируем WebView
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Ошибка загрузки: ${error.description}';
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(_swaggerService.swaggerUrl));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Ошибка инициализации Swagger UI: $e';
      });
    }
  }

  @override
  void dispose() {
    // Останавливаем Swagger сервер при закрытии виджета
    _swaggerService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    return Stack(
      children: [
        if (!_isLoading)
          WebViewWidget(controller: _webViewController),
        if (_isLoading) _buildLoadingState(isDark),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      color: isDark ? NsColorsDark.editor : NsColorsLight.editor,
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
            ),
            const SizedBox(height: NsSpacing.md),
            Text(
              'Загрузка Swagger UI...',
              style: NsTextStyles.bodyMedium(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Container(
      color: isDark ? NsColorsDark.editor : NsColorsLight.editor,
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? NsColorsDark.destructive : NsColorsLight.destructive,
            ),
            const SizedBox(height: NsSpacing.md),
            Text(
              'Ошибка загрузки Swagger UI',
              style: NsTextStyles.h4(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NsSpacing.sm),
            Text(
              _errorMessage ?? 'Неизвестная ошибка',
              style: NsTextStyles.bodyMedium(context).copyWith(
                color: isDark
                    ? NsColorsDark.mutedForeground
                    : NsColorsLight.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NsSpacing.lg),
            ElevatedButton.icon(
              onPressed: _initializeSwagger,
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }
}
