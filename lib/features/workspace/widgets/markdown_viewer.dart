import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownViewer extends StatefulWidget {
  const MarkdownViewer({super.key});

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  final ScrollController _scrollController = ScrollController();
  bool _isPreviewMode = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Markdown toolbar
        _buildMarkdownToolbar(context),
        
        // Content area
        Expanded(
          child: _isPreviewMode 
              ? _buildPreview(context)
              : _buildSource(context),
        ),
      ],
    );
  }

  Widget _buildMarkdownToolbar(BuildContext context) {
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
          // View mode toggle
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              children: [
                _buildModeButton(
                  context,
                  icon: Icons.visibility,
                  label: 'Предпросмотр',
                  isActive: _isPreviewMode,
                  onPressed: () => setState(() => _isPreviewMode = true),
                ),
                _buildModeButton(
                  context,
                  icon: Icons.code,
                  label: 'Исходник',
                  isActive: !_isPreviewMode,
                  onPressed: () => setState(() => _isPreviewMode = false),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Markdown formatting buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold, size: 16),
                onPressed: () => _insertMarkdown('**', '**'),
                tooltip: 'Жирный',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic, size: 16),
                onPressed: () => _insertMarkdown('*', '*'),
                tooltip: 'Курсив',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted, size: 16),
                onPressed: () => _insertMarkdown('- ', ''),
                tooltip: 'Список',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_numbered, size: 16),
                onPressed: () => _insertMarkdown('1. ', ''),
                tooltip: 'Нумерованный список',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.link, size: 16),
                onPressed: () => _insertMarkdown('[', '](url)'),
                tooltip: 'Ссылка',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.image, size: 16),
                onPressed: () => _insertMarkdown('![', '](url)'),
                tooltip: 'Изображение',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.code, size: 16),
                onPressed: () => _insertMarkdown('`', '`'),
                tooltip: 'Инлайн код',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_quote, size: 16),
                onPressed: () => _insertMarkdown('> ', ''),
                tooltip: 'Цитата',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive 
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Markdown(
        controller: _scrollController,
        data: _sampleMarkdown,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyMedium,
          h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h3: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          code: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          listBullet: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildSource(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: TextEditingController(text: _sampleMarkdown),
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Введите Markdown текст...',
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  void _insertMarkdown(String prefix, String suffix) {
    // TODO: Implement markdown insertion logic
    // This would integrate with the actual editor when Monaco is added
  }

  final String _sampleMarkdown = '''# Пример Markdown документа

Это пример **Markdown** документа с различными элементами форматирования.

## Заголовок второго уровня

### Списки

Нумерованный список:
1. Первый элемент
2. Второй элемент
3. Третий элемент

Маркированный список:
- Элемент 1
- Элемент 2
- Элемент 3

### Форматирование текста

**Жирный текст** и *курсивный текст*.

`Инлайн код` для выделения фрагментов кода.

### Блоки кода

```dart
void main() {
  print('Hello, NovaSpec!');
}
```

### Цитаты

> Это пример цитаты.
> Может состоять из нескольких строк.

### Ссылки и изображения

[Ссылка на GitHub](https://github.com)

![Пример изображения](https://via.placeholder.com/300x200)

### Таблицы

| Столбец 1 | Столбец 2 | Столбец 3 |
|-----------|-----------|-----------|
| Данные 1  | Данные 2  | Данные 3  |
| Данные 4  | Данные 5  | Данные 6  |

---

*Этот документ демонстрирует возможности Markdown просмотра в NovaSpec*''';
}
