import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_provider.dart';
import '../models/workspace_tab.dart';

class OpenFilesPanel extends StatelessWidget {
  const OpenFilesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Files list
          Expanded(
            child: _buildFilesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Text(
            'Открытые файлы',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              context.read<TabProvider>().closeAllTabs();
            },
            tooltip: 'Закрыть все',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesList(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, child) {
        if (tabProvider.tabs.isEmpty) {
          return const Center(
            child: Text(
              'Нет открытых файлов',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: tabProvider.tabs.length,
          itemBuilder: (context, index) {
            final tab = tabProvider.tabs[index];
            return _buildFileItem(context, tab, tabProvider);
          },
        );
      },
    );
  }

  Widget _buildFileItem(BuildContext context, WorkspaceTab tab, TabProvider tabProvider) {
    final isActive = tab.isActive;
    final isModified = tab.isModified;
    
    return Container(
      decoration: BoxDecoration(
        color: isActive 
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          _getFileIcon(tab.path),
          size: 16,
          color: isActive 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tab.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive 
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isModified) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.circle,
                size: 6,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
        subtitle: Text(
          _getRelativePath(tab.path),
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          tabProvider.switchTab(tab.id);
        },

        trailing: IconButton(
          icon: const Icon(Icons.close, size: 14),
          onPressed: () {
            tabProvider.closeTab(tab.id);
          },
          tooltip: 'Закрыть',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
        ),
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

  String _getRelativePath(String fullPath) {
    // Simple relative path calculation - can be improved
    final parts = fullPath.split('/');
    if (parts.length > 3) {
      return '.../${parts.sublist(parts.length - 3).join('/')}';
    }
    return fullPath;
  }
}
