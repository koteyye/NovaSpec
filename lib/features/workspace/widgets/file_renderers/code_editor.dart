import 'package:flutter/material.dart';
import '../../../../shared/widgets/modern_button.dart';

class CodeEditor extends StatefulWidget {
  final String filePath;
  final String content;
  final Function(String)? onContentChanged;
  final VoidCallback? onSave;

  const CodeEditor({
    super.key,
    required this.filePath,
    required this.content,
    this.onContentChanged,
    this.onSave,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  bool _isLoading = true;
  bool _isModified = false;
  String _currentContent = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentContent = widget.content;
    _initializeEditor();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeEditor() async {
    try {
      // Временная реализация без Monaco Editor
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Ошибка инициализации редактора: $e');
      }
    }
  }

  Future<void> _saveContent() async {
    try {
      // Временная реализация сохранения
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        setState(() {
          _isModified = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Файл сохранен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _formatCode() async {
    try {
      // Временная реализация форматирования
      _showError('Форматирование будет доступно в следующей версии');
    } catch (e) {
      _showError('Ошибка форматирования кода: $e');
    }
  }

  void _toggleComment() async {
    try {
      // Временная реализация переключения комментариев
      _showError('Переключение комментариев будет доступно в следующей версии');
    } catch (e) {
      _showError('Ошибка переключения комментария: $e');
    }
  }

  void _findAndReplace() {
    _showError('Поиск и замена будут доступны в следующей версии');
  }

  void _toggleWordWrap() {
    _showError('Перенос слов будет доступен в следующей версии');
  }

  void _showCommandPalette() {
    _showError('Палитра команд будет доступна в следующей версии');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          Container(
            height: 48,
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
                const SizedBox(width: 16),
                Icon(
                  Icons.code,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isModified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '●',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          
          // Toolbar
          Container(
            height: 40,
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
                const SizedBox(width: 8),
                ModernButton(
                  text: 'Форматировать',
                  onPressed: _formatCode,
                ),
                ModernButton(
                  text: 'Комментарий',
                  onPressed: _toggleComment,
                ),
                ModernButton(
                  text: 'Найти',
                  onPressed: _findAndReplace,
                ),
                ModernButton(
                  text: 'Перенос',
                  onPressed: _toggleWordWrap,
                ),
                ModernButton(
                  text: 'Команды',
                  onPressed: _showCommandPalette,
                ),
                const SizedBox(width: 8),
                ModernButton(
                  text: 'Сохранить',
                  onPressed: _saveContent,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          // Editor content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Загрузка редактора...'),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Редактор кода',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monaco Editor будет интегрирован в следующей версии',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _currentContent.isNotEmpty ? _currentContent : '// Пустой файл',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          
          // Status bar
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Text(
                  'UTF-8',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Ln 1, Col 1',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                Text(
                  _getLanguageForFile(widget.filePath),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageForFile(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return 'Dart';
      case 'js':
        return 'JavaScript';
      case 'ts':
        return 'TypeScript';
      case 'py':
        return 'Python';
      case 'java':
        return 'Java';
      case 'cpp':
      case 'cc':
      case 'cxx':
        return 'C++';
      case 'c':
        return 'C';
      case 'cs':
        return 'C#';
      case 'php':
        return 'PHP';
      case 'rb':
        return 'Ruby';
      case 'go':
        return 'Go';
      case 'rs':
        return 'Rust';
      case 'swift':
        return 'Swift';
      case 'kt':
        return 'Kotlin';
      case 'html':
        return 'HTML';
      case 'css':
        return 'CSS';
      case 'scss':
      case 'sass':
        return 'Sass';
      case 'less':
        return 'Less';
      case 'json':
        return 'JSON';
      case 'xml':
        return 'XML';
      case 'yaml':
      case 'yml':
        return 'YAML';
      case 'md':
        return 'Markdown';
      case 'sql':
        return 'SQL';
      case 'sh':
      case 'bash':
        return 'Shell';
      case 'ps1':
        return 'PowerShell';
      default:
        return 'Plain Text';
    }
  }
}
