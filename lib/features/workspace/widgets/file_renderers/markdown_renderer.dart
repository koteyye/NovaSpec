import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownRenderer extends StatefulWidget {
  final String filePath;
  final String content;

  const MarkdownRenderer({
    super.key,
    required this.filePath,
    required this.content,
  });

  @override
  State<MarkdownRenderer> createState() => _MarkdownRendererState();
}

class _MarkdownRendererState extends State<MarkdownRenderer> {
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
          // File info
          Row(
            children: [
              Icon(
                Icons.description,
                size: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                'Markdown',
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
        data: _textController.text,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: Theme.of(context).textTheme.bodyMedium,
          h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          h3: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          h4: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h5: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          h6: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          code: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            color: Theme.of(context).colorScheme.primary,
          ),
          codeblockDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          codeblockPadding: const EdgeInsets.all(12),
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
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          blockquotePadding: const EdgeInsets.all(8),
          listBullet: Theme.of(context).textTheme.bodyMedium,
          listIndent: 24,
          tableHead: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          tableBody: Theme.of(context).textTheme.bodyMedium,
          tableBorder: TableBorder.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          tableColumnWidth: const FlexColumnWidth(),
          tableCellsPadding: const EdgeInsets.all(8),
          tableHeadAlign: TextAlign.center,
          tableVerticalAlignment: TableCellVerticalAlignment.middle,
          a: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),

        ),
        onTapLink: (text, href, title) {
          // TODO: Handle link taps
          debugPrint('Link tapped: $href');
        },
        imageBuilder: (uri, title, alt) {
          // TODO: Handle images properly
          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Icon(
                  Icons.image,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  alt ?? 'Изображение',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (title != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
          hintText: 'Введите Markdown текст...',
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


}
