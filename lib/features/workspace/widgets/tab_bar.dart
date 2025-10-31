import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_provider.dart';
import '../models/workspace_tab.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Consumer<TabProvider>(
        builder: (context, tabProvider, child) {
          if (tabProvider.tabs.isEmpty) {
            return Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  'Нет открытых вкладок',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              // Tab list
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabProvider.tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabProvider.tabs[index];
                    return _buildTab(context, tab, tabProvider);
                  },
                ),
              ),
              
              // Tab actions
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => _showNewFileDialog(context, tabProvider),
                    tooltip: 'Новый файл',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 16),
                    onPressed: () => _showTabMenu(context, tabProvider),
                    tooltip: 'Меню вкладок',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, WorkspaceTab tab, TabProvider tabProvider) {
    final isActive = tab.isActive;
    final isModified = tab.isModified;
    
    return Container(
      margin: const EdgeInsets.only(left: 2, top: 2, bottom: 2),
      decoration: BoxDecoration(
        color: isActive 
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        border: Border.all(
          color: isActive 
              ? Theme.of(context).dividerColor
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 4),
            child: Icon(
              _getFileIcon(tab.path),
              size: 14,
              color: isActive 
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          // Tab title
          GestureDetector(
            onTap: () => tabProvider.switchTab(tab.id),
            onSecondaryTap: () => _showTabContextMenu(context, tab, tabProvider),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                tab.title,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive 
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Modified indicator
          if (isModified) ...[
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.circle,
                size: 6,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
          
          // Close button
          GestureDetector(
            onTap: () => tabProvider.closeTab(tab.id),
            child: Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.close,
                size: 14,
                color: isActive 
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewFileDialog(BuildContext context, TabProvider tabProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый файл'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Имя файла',
            labelText: 'Имя файла',
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              // TODO: Create new file and open tab
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Create new file and open tab
              Navigator.pop(context);
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _showTabMenu(BuildContext context, TabProvider tabProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Новая вкладка'),
            onTap: () {
              Navigator.pop(context);
              _showNewFileDialog(context, tabProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Закрыть все вкладки'),
            onTap: () {
              Navigator.pop(context);
              tabProvider.closeAllTabs();
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Закрыть остальные'),
            onTap: () {
              Navigator.pop(context);
              final activeTab = tabProvider.activeTab;
              if (activeTab != null) {
                tabProvider.closeOtherTabs(activeTab.id);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTabContextMenu(BuildContext context, WorkspaceTab tab, TabProvider tabProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Закрыть'),
            onTap: () {
              Navigator.pop(context);
              tabProvider.closeTab(tab.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Закрыть остальные'),
            onTap: () {
              Navigator.pop(context);
              tabProvider.closeOtherTabs(tab.id);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Сохранить'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Save file
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_as),
            title: const Text('Сохранить как'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Save file as
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Копировать путь'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Copy path to clipboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Показать в проводнике'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show in file explorer
            },
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'dart':
        return Icons.code;
      case 'js':
        return Icons.javascript;
      case 'ts':
        return Icons.code;
      case 'py':
        return Icons.psychology;
      case 'java':
        return Icons.coffee;
      case 'html':
        return Icons.web;
      case 'css':
        return Icons.palette;
      case 'json':
        return Icons.data_object;
      case 'md':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}
