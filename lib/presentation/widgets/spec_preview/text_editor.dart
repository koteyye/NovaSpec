import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';

/// Продвинутый текстовый редактор с подсветкой синтаксиса
class TextEditor extends StatefulWidget {
  final String content;
  final String? filePath;
  final ValueChanged<String> onChanged;
  final bool readOnly;

  const TextEditor({
    super.key,
    required this.content,
    this.filePath,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late CodeController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(TextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем контроллер только если изменился путь или контент извне
    if (oldWidget.filePath != widget.filePath ||
        (oldWidget.content != widget.content && widget.content != _controller.text)) {
      _controller.dispose();
      _initializeController();
    }
  }

  void _initializeController() {
    final language = _getLanguageMode(widget.filePath);

    _controller = CodeController(
      text: widget.content,
      language: language,
    );

    _controller.addListener(() {
      if (_controller.text != widget.content) {
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Определить режим подсветки на основе расширения файла
  dynamic _getLanguageMode(String? filePath) {
    if (filePath == null) return null;

    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'dart':
        return dart;
      case 'json':
        return json;
      case 'yaml':
      case 'yml':
        return yaml;
      case 'md':
      case 'markdown':
        return markdown;
      default:
        return null; // Plain text
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CodeTheme(
      data: CodeThemeData(
        styles: isDark ? vs2015Theme : githubTheme,
      ),
      child: SingleChildScrollView(
        child: CodeField(
          controller: _controller,
          readOnly: widget.readOnly,
          textStyle: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
          ),
          gutterStyle: GutterStyle(
            width: 48,
            textStyle: TextStyle(
              fontSize: 12,
              color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
            ),
            background: isDark ? NsColorsDark.muted : NsColorsLight.muted,
          ),
          background: isDark ? NsColorsDark.editor : NsColorsLight.editor,
          cursorColor: isDark ? NsColorsDark.primary : NsColorsLight.primary,
          lineNumberBuilder: (index, style) {
            return TextSpan(
              text: '${index + 1}'.padLeft(3),
              style: style,
            );
          },
        ),
      ),
    );
  }
}
