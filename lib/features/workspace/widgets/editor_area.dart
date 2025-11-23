import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_provider.dart';
import '../../project/providers/project_provider.dart';
import '../../musication/widgets/musication_button.dart';
import '../../musication/widgets/musication_indicator.dart';
import '../../musication/widgets/musication_balance_indicator.dart';

class EditorArea extends StatefulWidget {
  const EditorArea({super.key});

  @override
  EditorAreaState createState() => EditorAreaState();
}

class EditorAreaState extends State<EditorArea> {
  final TextEditingController _textController = TextEditingController(
    text: 'Пример текста для музикации',
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TabProvider, ProjectProvider>(
      builder: (context, tabProvider, projectProvider, child) {
        final activeTab = tabProvider.activeTab;

        if (activeTab == null) {
          return _buildEmptyState(context);
        }

        return _buildEditor(context, activeTab, _textController, projectProvider);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет открытых файлов',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Откройте файл для начала работы',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Open file dialog
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('Открыть файл'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(
    BuildContext context,
    activeTab,
    TextEditingController controller,
    ProjectProvider projectProvider,
  ) {
    return Column(
      children: [
        // Editor toolbar
        _buildEditorToolbar(context, activeTab, controller, projectProvider),

        // Editor content (placeholder for Monaco)
        Expanded(child: _buildEditorContent(context, activeTab, controller)),
      ],
    );
  }

  Widget _buildEditorToolbar(
    BuildContext context,
    activeTab,
    TextEditingController controller,
    ProjectProvider projectProvider,
  ) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Language indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              activeTab.language.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Editor actions
          IconButton(
            icon: const Icon(Icons.undo, size: 16),
            onPressed: () {
              // TODO: Undo
            },
            tooltip: 'Отменить',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 16),
            onPressed: () {
              // TODO: Redo
            },
            tooltip: 'Повторить',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            icon: const Icon(Icons.save, size: 16),
            onPressed: () {
              // TODO: Save file
            },
            tooltip: 'Сохранить',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            icon: const Icon(Icons.find_replace, size: 16),
            onPressed: () {
              // TODO: Find and replace
            },
            tooltip: 'Найти и заменить',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),

          // Musication button for .md and .html files
          if (activeTab.path.endsWith('.md') || activeTab.path.endsWith('.html')) ...[
            const SizedBox(width: 8),

            MusicationButton(
              projectPath: projectProvider.currentProject?.directory ?? '',
              selectedText: controller.selection.textInside(controller.text),
              filePath: activeTab.path,
            ),

            const SizedBox(width: 8),

            const MusicationIndicator(),

            const SizedBox(width: 8),

            const MusicationBalanceIndicator(),
          ],

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildEditorContent(
    BuildContext context,
    activeTab,
    TextEditingController controller,
  ) {
    // Placeholder for Monaco Editor with text field
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Редактор для файла: ${activeTab.title}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                hintText: 'Введите текст для музикации...',
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будет интегрирован Monaco Editor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}
