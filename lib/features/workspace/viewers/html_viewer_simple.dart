import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/html_service.dart';
import '../../../core/services/toast_service.dart';

class HtmlViewerSimple extends StatefulWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const HtmlViewerSimple({
    super.key,
    required this.filePath,
    this.onContentChanged,
  });

  @override
  State<HtmlViewerSimple> createState() => HtmlViewerSimpleState();
}

class HtmlViewerSimpleState extends State<HtmlViewerSimple> {
  final HtmlService _htmlService = HtmlService();

  String _content = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('=== HTML VIEWER SIMPLE INIT ===');
    debugPrint('FilePath: ${widget.filePath}');
    _loadFile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadFile() async {
    debugPrint('=== HTML VIEWER LOADING FILE ===');
    debugPrint('Loading from: ${widget.filePath}');

    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final content = await _htmlService.loadFromFile(widget.filePath);

      debugPrint('File loaded successfully');
      debugPrint('Content length: ${content.length}');
      debugPrint(
        'Content preview: ${content.substring(0, content.length > 100 ? 100 : content.length)}',
      );

      setState(() {
        _content = content;
        _isLoading = false;
      });

      debugPrint('State updated, _isLoading = false');
      debugPrint('===============================');
    } catch (e) {
      debugPrint('ERROR loading file: $e');
      debugPrint('===============================');

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      error(description: 'Ошибка загрузки файла: ${e.toString()}');
    }
  }

  Widget _buildViewer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Html(
        data: _content,
        style: {
          'body': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontFamily: 'Roboto',
            fontSize: FontSize(14),
            lineHeight: const LineHeight(1.5),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'h1': Style(
            fontSize: FontSize(24),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 16),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'h2': Style(
            fontSize: FontSize(20),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 12),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'h3': Style(
            fontSize: FontSize(18),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 8),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'p': Style(
            margin: Margins.only(bottom: 12),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'code': Style(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
            fontFamily: 'monospace',
            fontSize: FontSize(13),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'pre': Style(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            padding: HtmlPaddings.all(12),
            fontFamily: 'monospace',
            fontSize: FontSize(13),
            margin: Margins.only(bottom: 16),
            color: Theme.of(context).colorScheme.onSurface,
            whiteSpace: WhiteSpace.pre,
          ),
          'a': Style(
            color: Theme.of(context).colorScheme.primary,
            textDecoration: TextDecoration.underline,
          ),
          'ul': Style(
            margin: Margins.only(bottom: 12, left: 16),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'ol': Style(
            margin: Margins.only(bottom: 12, left: 16),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'li': Style(
            margin: Margins.only(bottom: 4),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          'blockquote': Style(
            border: Border(
              left: BorderSide(color: Theme.of(context).dividerColor, width: 4),
            ),
            padding: HtmlPaddings.only(left: 16),
            margin: Margins.only(bottom: 12),
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
            fontStyle: FontStyle.italic,
          ),
        },
        onLinkTap: (url, _, __) {
          if (url != null) {
            show(description: 'Ссылка: $url');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== HTML VIEWER BUILD ===');
    debugPrint('_isLoading: $_isLoading');
    debugPrint('_errorMessage: $_errorMessage');
    debugPrint('_content length: ${_content.length}');

    if (_isLoading) {
      debugPrint('Showing CircularProgressIndicator');
      debugPrint('========================');
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      debugPrint('Showing error message: $_errorMessage');
      debugPrint('========================');
      return Center(
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
              'Ошибка загрузки файла',
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFile,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    debugPrint('Showing viewer with content');
    debugPrint('========================');
    return _buildViewer();
  }
}
