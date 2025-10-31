import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlRenderer extends StatefulWidget {
  final String filePath;
  final String content;

  const HtmlRenderer({
    super.key,
    required this.filePath,
    required this.content,
  });

  @override
  State<HtmlRenderer> createState() => _HtmlRendererState();
}

class _HtmlRendererState extends State<HtmlRenderer> {
  final ScrollController _scrollController = ScrollController();
  bool _isPreviewMode = true;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HTML toolbar
        _buildHtmlToolbar(context),
        
        // Content area
        Expanded(
          child: _isPreviewMode 
              ? _buildPreview(context)
              : _buildSource(context),
        ),
      ],
    );
  }

  Widget _buildHtmlToolbar(BuildContext context) {
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
                Icons.web,
                size: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                'HTML',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
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
          
          const SizedBox(width: 8),
          
          // HTML formatting buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_bold, size: 16),
                onPressed: () => _insertHtml('<strong>', '</strong>'),
                tooltip: 'Жирный',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_italic, size: 16),
                onPressed: () => _insertHtml('<em>', '</em>'),
                tooltip: 'Курсив',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_underlined, size: 16),
                onPressed: () => _insertHtml('<u>', '</u>'),
                tooltip: 'Подчеркнутый',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted, size: 16),
                onPressed: () => _insertHtml('<ul>\n  <li>', '</li>\n</ul>'),
                tooltip: 'Список',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.format_list_numbered, size: 16),
                onPressed: () => _insertHtml('<ol>\n  <li>', '</li>\n</ol>'),
                tooltip: 'Нумерованный список',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.link, size: 16),
                onPressed: () => _insertHtml('<a href="">', '</a>'),
                tooltip: 'Ссылка',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.image, size: 16),
                onPressed: () => _insertHtml('<img src="" alt="">', ''),
                tooltip: 'Изображение',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.code, size: 16),
                onPressed: () => _insertHtml('<code>', '</code>'),
                tooltip: 'Код',
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
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Html(
          data: _textController.text,
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontFamily: 'Roboto',
              fontSize: FontSize(14),
              lineHeight: const LineHeight(1.4),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            'h1': Style(
              fontSize: FontSize(24),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              margin: Margins.only(bottom: 16),
            ),
            'h2': Style(
              fontSize: FontSize(20),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              margin: Margins.only(bottom: 12),
            ),
            'h3': Style(
              fontSize: FontSize(18),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              margin: Margins.only(bottom: 8),
            ),
            'h4': Style(
              fontSize: FontSize(16),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 8),
            ),
            'h5': Style(
              fontSize: FontSize(14),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 8),
            ),
            'h6': Style(
              fontSize: FontSize(12),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 8),
            ),
            'p': Style(
              margin: Margins.only(bottom: 12),
            ),
            'strong': Style(
              fontWeight: FontWeight.bold,
            ),
            'b': Style(
              fontWeight: FontWeight.bold,
            ),
            'em': Style(
              fontStyle: FontStyle.italic,
            ),
            'i': Style(
              fontStyle: FontStyle.italic,
            ),
            'u': Style(
              textDecoration: TextDecoration.underline,
            ),
            'code': Style(
              fontFamily: 'monospace',
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
            ),
            'pre': Style(
              fontFamily: 'monospace',
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: HtmlPaddings.all(12),
              margin: Margins.only(bottom: 12),
            ),
            'blockquote': Style(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
              padding: HtmlPaddings.only(left: 12),
              margin: Margins.only(bottom: 12),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
            'ul': Style(
              margin: Margins.only(bottom: 12),
              padding: HtmlPaddings.only(left: 24),
            ),
            'ol': Style(
              margin: Margins.only(bottom: 12),
              padding: HtmlPaddings.only(left: 24),
            ),
            'li': Style(
              margin: Margins.only(bottom: 4),
            ),
            'a': Style(
              color: Theme.of(context).colorScheme.primary,
              textDecoration: TextDecoration.underline,
            ),
            'img': Style(
              margin: Margins.only(bottom: 12),
            ),
            'table': Style(
              width: Width(100, Unit.percent),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
              margin: Margins.only(bottom: 12),
            ),
            'th': Style(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              fontWeight: FontWeight.bold,
              padding: HtmlPaddings.all(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            'td': Style(
              padding: HtmlPaddings.all(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            'hr': Style(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              margin: Margins.symmetric(vertical: 16),
            ),
          },
          onLinkTap: (url, _, __) {
            // TODO: Handle link taps
            debugPrint('Link tapped: $url');
          },

        ),
      ),
    );
  }

  Widget _buildSource(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Введите HTML код...',
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontFamily: 'monospace',
          height: 1.4,
        ),
        onChanged: (value) {
          // TODO: Notify parent about content change
        },
      ),
    );
  }

  void _insertHtml(String prefix, String suffix) {
    final text = _textController.text;
    final selection = _textController.selection;
    
    if (selection.isValid) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + prefix.length + selectedText.length,
        ),
      );
    } else {
      final cursorPos = selection.baseOffset;
      final newText = text.replaceRange(
        cursorPos,
        cursorPos,
        '$prefix$suffix',
      );
      
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: cursorPos + prefix.length,
        ),
      );
    }
  }
}
