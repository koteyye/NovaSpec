import 'package:flutter/material.dart';
import '../services/code_service.dart';
import '../../../core/services/toast_service.dart';

class CodeEditorSimple extends StatefulWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const CodeEditorSimple({
    super.key,
    required this.filePath,
    this.onContentChanged,
  });

  @override
  State<CodeEditorSimple> createState() => CodeEditorSimpleState();
}

class CodeEditorSimpleState extends State<CodeEditorSimple> {
  final TextEditingController _textController = TextEditingController();
  final CodeService _codeService = CodeService();
  bool _isLoading = false;
  bool _disposed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint('=== CODE EDITOR SIMPLE INIT ===');
    debugPrint('FilePath: ${widget.filePath}');
    _loadFile();
  }

  @override
  void dispose() {
    _disposed = true;
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    if (_disposed || !mounted) return;
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final content = await _codeService.loadFromFile(widget.filePath);

      if (_disposed || !mounted) return;
      setState(() {
        _textController.text = content;
        _isLoading = false;
      });
    } catch (e) {
      if (_disposed || !mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (!_disposed && mounted) {
        error(description: 'Ошибка загрузки файла: ${e.toString()}');
      }
    }
  }

  void _onTextChanged(String content) {
    widget.onContentChanged?.call(content);
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

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onChanged: _onTextChanged,
      ),
    );
  }
}
