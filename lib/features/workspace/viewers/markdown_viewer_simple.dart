import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/markdown_service.dart';
import '../../../core/services/toast_service.dart';

class MarkdownViewerSimple extends StatefulWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const MarkdownViewerSimple({
    super.key,
    required this.filePath,
    this.onContentChanged,
  });

  @override
  State<MarkdownViewerSimple> createState() => MarkdownViewerSimpleState();
}

class MarkdownViewerSimpleState extends State<MarkdownViewerSimple> {
  final MarkdownService _markdownService = MarkdownService();

  String _content = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final content = await _markdownService.loadFromFile(widget.filePath);

      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      error(description: 'Ошибка загрузки файла: ${e.toString()}');
    }
  }

  Widget _buildViewer() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Markdown(
        data: _content,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: Theme.of(context).textTheme.bodyMedium,
          h1: Theme.of(context).textTheme.displaySmall,
          h2: Theme.of(context).textTheme.headlineMedium,
          h3: Theme.of(context).textTheme.headlineSmall,
          h4: Theme.of(context).textTheme.titleLarge,
          h5: Theme.of(context).textTheme.titleMedium,
          h6: Theme.of(context).textTheme.bodyLarge,
          code: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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

    return _buildViewer();
  }
}
