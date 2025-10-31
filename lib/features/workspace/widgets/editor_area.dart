import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_provider.dart';

class EditorArea extends StatelessWidget {
  const EditorArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, child) {
        final activeTab = tabProvider.activeTab;
        
        if (activeTab == null) {
          return _buildEmptyState(context);
        }

        return _buildEditor(context, activeTab);
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
              // TODO: Show file picker
            },
            icon: const Icon(Icons.folder_open),
            label: const Text('Открыть файл'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, activeTab) {
    // TODO: Replace with actual Monaco Editor integration
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Editor toolbar
          _buildEditorToolbar(context, activeTab),
          
          // Editor content (placeholder for Monaco)
          Expanded(
            child: _buildEditorContent(context, activeTab),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorToolbar(BuildContext context, activeTab) {
    return Container(
      height: 32,
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
          
          const Spacer(),
          
          // Editor actions
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo, size: 16),
                onPressed: () {
                  // TODO: Undo
                },
                tooltip: 'Отменить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 16),
                onPressed: () {
                  // TODO: Redo
                },
                tooltip: 'Повторить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save, size: 16),
                onPressed: () {
                  // TODO: Save file
                },
                tooltip: 'Сохранить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.find_replace, size: 16),
                onPressed: () {
                  // TODO: Find and replace
                },
                tooltip: 'Найти и заменить',
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

  Widget _buildEditorContent(BuildContext context, activeTab) {
    // Placeholder for Monaco Editor
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
          Text(
            'Путь: ${activeTab.path}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Здесь будет интегрирован Monaco Editor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Язык: ${activeTab.language}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (activeTab.isModified) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Файл изменен',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
