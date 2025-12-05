import 'package:flutter/material.dart';
import 'package:flutter_monaco/flutter_monaco.dart';
import '../services/code_service.dart';
import '../../../core/services/toast_service.dart';

class MonacoCodeEditor extends StatefulWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const MonacoCodeEditor({
    super.key,
    required this.filePath,
    this.onContentChanged,
  });

  @override
  State<MonacoCodeEditor> createState() => MonacoCodeEditorState();
}

class MonacoCodeEditorState extends State<MonacoCodeEditor> {
  final CodeService _codeService = CodeService();
  MonacoController? _monacoController;
  bool _isLoading = false;
  bool _disposed = false;
  String? _errorMessage;
  String _currentContent = '';

  @override
  void initState() {
    super.initState();
    debugPrint('=== MONACO CODE EDITOR INIT ===');
    debugPrint('FilePath: ${widget.filePath}');
    _loadFileAndInitializeEditor();
  }

  @override
  void dispose() {
    _disposed = true;
    _monacoController?.dispose();
    super.dispose();
  }

  Future<void> _loadFileAndInitializeEditor() async {
    if (_disposed || !mounted) return;
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      // Загружаем содержимое файла
      final content = await _codeService.loadFromFile(widget.filePath);

      if (_disposed || !mounted) return;
      
      _currentContent = content;

      // Создаем контроллер Monaco с правильным API
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final language = _detectLanguageEnum();
      
      _monacoController = await MonacoController.create(
        options: EditorOptions(
          language: language,
          theme: isDarkMode ? MonacoTheme.vsDark : MonacoTheme.vs,
          fontSize: 14,
          fontFamily: 'JetBrains Mono, Consolas, monospace',
          automaticLayout: true,
          minimap: true,
          wordWrap: language == MonacoLanguage.markdown,
          lineNumbers: true,
          scrollBeyondLastLine: false,
          renderWhitespace: RenderWhitespace.selection,
        ),
      );

      // Устанавливаем содержимое
      await _monacoController!.setValue(_currentContent);

      // Подписываемся на изменения
      _monacoController!.onContentChanged.listen((isFlush) {
        _handleContentChanged();
      });

      if (_disposed || !mounted) return;
      setState(() => _isLoading = false);
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

  Future<void> _handleContentChanged() async {
    if (_monacoController == null) return;
    try {
      final newContent = await _monacoController!.getValue();
      _currentContent = newContent;
      widget.onContentChanged?.call(newContent);
    } catch (e) {
      debugPrint('Error getting content: $e');
    }
  }

  MonacoLanguage _detectLanguageEnum() {
    final extension = widget.filePath.split('.').last.toLowerCase();
    
    switch (extension) {
      // Web
      case 'html':
      case 'htm':
        return MonacoLanguage.html;
      case 'css':
        return MonacoLanguage.css;
      case 'scss':
        return MonacoLanguage.scss;
      case 'less':
        return MonacoLanguage.less;
      case 'js':
      case 'jsx':
        return MonacoLanguage.javascript;
      case 'ts':
      case 'tsx':
        return MonacoLanguage.typescript;
      
      // Documentation
      case 'md':
      case 'markdown':
        return MonacoLanguage.markdown;
      
      // Data formats
      case 'json':
        return MonacoLanguage.json;
      case 'xml':
        return MonacoLanguage.xml;
      case 'yaml':
      case 'yml':
        return MonacoLanguage.yaml;
      
      // Programming languages
      case 'dart':
        return MonacoLanguage.dart;
      case 'py':
        return MonacoLanguage.python;
      case 'java':
        return MonacoLanguage.java;
      case 'c':
        return MonacoLanguage.c;
      case 'cpp':
      case 'h':
      case 'hpp':
        return MonacoLanguage.cpp;
      case 'cs':
        return MonacoLanguage.csharp;
      case 'php':
        return MonacoLanguage.php;
      case 'rb':
        return MonacoLanguage.ruby;
      case 'go':
        return MonacoLanguage.go;
      case 'rs':
        return MonacoLanguage.rust;
      case 'swift':
        return MonacoLanguage.swift;
      case 'kt':
        return MonacoLanguage.kotlin;
      case 'sql':
        return MonacoLanguage.sql;
      case 'sh':
      case 'bash':
        return MonacoLanguage.shell;
      case 'ps1':
        return MonacoLanguage.powershell;
      case 'bat':
      case 'cmd':
        return MonacoLanguage.bat;
      
      default:
        return MonacoLanguage.plaintext;
    }
  }

  /// Получить выделенный текст из редактора
  Future<String> getSelectedText() async {
    if (_monacoController == null) return '';
    try {
      // Пока нет простого способа получить выделенный текст из Monaco
      // Возвращаем пустую строку - будем использовать весь текст файла
      return '';
    } catch (e) {
      debugPrint('Error getting selected text: $e');
    }
    return '';
  }

  /// Получить весь текст из редактора
  Future<String> getAllText() async {
    if (_monacoController == null) return _currentContent;
    try {
      return await _monacoController!.getValue();
    } catch (e) {
      debugPrint('Error getting all text: $e');
    }
    return _currentContent;
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
              onPressed: _loadFileAndInitializeEditor,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_monacoController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _monacoController!.webViewWidget;
  }
}

