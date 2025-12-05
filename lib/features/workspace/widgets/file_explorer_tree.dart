import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_explorer_provider.dart';
import '../providers/tab_provider.dart';
import '../models/file_explorer_node.dart';
import '../../../../core/providers/app_provider.dart';

import '../../../../shared/widgets/modern_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'create_file_dialog.dart';

class FileExplorerTree extends StatefulWidget {
  const FileExplorerTree({super.key});

  @override
  State<FileExplorerTree> createState() => _FileExplorerTreeState();
}

class _FileExplorerTreeState extends State<FileExplorerTree> {
  ThemeMode? _lastThemeMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Проверяем изменение темы и форсируем rebuild
    final appProvider = Provider.of<AppProvider>(context, listen: true);
    final currentTheme = appProvider.themeMode;

    if (_lastThemeMode != null && _lastThemeMode != currentTheme) {
      // Тема изменилась - форсируем перестройку
      setState(() {});
    }
    _lastThemeMode = currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    // Слушаем AppProvider для отслеживания изменений темы
    return Consumer2<FileExplorerProvider, AppProvider>(
      builder: (context, provider, appProvider, child) {
        if (provider.isLoading && provider.currentPath.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Используем themeMode из appProvider для перестройки при смене темы
        final currentTheme = appProvider.themeMode;

        return ListView.builder(
          key: ValueKey('file_tree_$currentTheme'),
          itemCount: provider.currentPath.length,
          itemBuilder: (context, index) {
            final node = provider.currentPath[index];
            return _buildTreeNode(context, node, provider, 0, currentTheme);
          },
        );
      },
    );
  }

  Widget _buildTreeNode(
    BuildContext context,
    FileExplorerNode node,
    FileExplorerProvider provider,
    int depth,
    ThemeMode currentTheme,
  ) {
    final isExpanded = provider.isNodeExpanded(node.id);
    final children = provider.getNodeChildren(node.id);
    final isLoading = provider.isNodeLoading(node.id);

    return Container(
      decoration: BoxDecoration(
        border: depth == 0
            ? null
            : Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
      ),
      child: Column(
        children: [
          // Node row
          GestureDetector(
            onTap: () => _handleNodeTap(context, node, provider),
            onSecondaryTapDown: (details) => _showContextMenu(
              context,
              details.globalPosition,
              node,
              provider,
            ),
            child: Container(
              padding: EdgeInsets.only(
                left: depth * 20.0 + 12.0,
                right: 12.0,
                top: 4.0,
                bottom: 4.0,
              ),
              child: Row(
                children: [
                  // Expand/collapse icon
                  if (node.isFolder)
                    GestureDetector(
                      onTap: () => _toggleNodeExpansion(node, provider),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: isLoading
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                node.isExpanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_right,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                      ),
                    ),

                  const SizedBox(width: 8),

                  // File/folder icon
                  Icon(
                    _getFileIcon(node),
                    size: 16,
                    color: _getFileIconColor(node, context),
                  ),

                  const SizedBox(width: 8),

                  // Name
                  Expanded(
                    child: Text(
                      node.name,
                      key: ValueKey('${node.id}_text_$currentTheme'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: node.isFolder
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Actions
                  if (node.isRenaming)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: Icon(
                        Icons.edit,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    PopupMenuButton<FileExplorerNode>(
                      icon: const Icon(Icons.more_vert, size: 16),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: node,
                          child: const Row(
                            children: [
                              Icon(Icons.add, size: 16),
                              SizedBox(width: 8),
                              Text('Создать'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: node,
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('переименовать'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: node,
                          child: const Row(
                            children: [
                              Icon(Icons.content_copy, size: 16),
                              SizedBox(width: 8),
                              Text('копировать'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: node,
                          child: const Row(
                            children: [
                              Icon(Icons.content_cut, size: 16),
                              SizedBox(width: 8),
                              Text('вырезать'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: node,
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 16),
                              SizedBox(width: 8),
                              Text('удалить'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (selectedNode) {
                        if (selectedNode == node) {
                          _showActionMenu(context, node, provider);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),

          // Children (if expanded)
          if (node.isFolder && isExpanded && children.isNotEmpty)
            ...children.map(
              (child) => _buildTreeNode(
                context,
                child,
                provider,
                depth + 1,
                currentTheme,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(FileExplorerNode node) {
    if (node.isFolder) {
      return node.isExpanded ? Icons.folder_open : Icons.folder;
    }

    final extension = node.name.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return Icons.code;
      case 'js':
      case 'ts':
        return Icons.javascript;
      case 'html':
        return Icons.web;
      case 'css':
        return Icons.css;
      case 'json':
        return Icons.data_object;
      case 'md':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileIconColor(FileExplorerNode node, BuildContext context) {
    if (node.isFolder) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.7);
    }

    // Используем адаптивные цвета для темной/светлой темы
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final extension = node.name.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'js':
      case 'ts':
        return isDark ? Colors.yellow.shade300 : Colors.yellow.shade700;
      case 'html':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case 'css':
        return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case 'json':
        return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
      case 'md':
        return isDark ? Colors.blueGrey.shade300 : Colors.blueGrey.shade700;
      case 'txt':
        return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'pdf':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'zip':
      case 'rar':
      case '7z':
        return isDark ? Colors.brown.shade300 : Colors.brown.shade700;
      default:
        return onSurface.withValues(alpha: 0.6);
    }
  }

  void _toggleNodeExpansion(
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    provider.toggleNodeExpansion(node.id);
  }

  Future<void> _handleNodeTap(
    BuildContext context,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) async {
    if (node.isFolder) {
      _toggleNodeExpansion(node, provider);
    } else {
      // Open file in tab
      final tabProvider = context.read<TabProvider>();
      await tabProvider.openTab(node.path, title: node.name);
    }
  }

  void _showContextMenu(
    BuildContext context,
    Offset position,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 200,
        position.dy + 300,
      ),
      items: [
        PopupMenuItem(
          value: 'create',
          child: Row(
            children: [
              const Icon(Icons.add, size: 16),
              const SizedBox(width: 8),
              Text(l10n.create),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              const Icon(Icons.edit, size: 16),
              const SizedBox(width: 8),
              Text(l10n.rename),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.content_copy, size: 16),
              const SizedBox(width: 8),
              Text(l10n.copy),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'cut',
          child: Row(
            children: [
              const Icon(Icons.content_cut, size: 16),
              const SizedBox(width: 8),
              Text(l10n.cut),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, size: 16),
              const SizedBox(width: 8),
              Text(l10n.delete),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null && context.mounted) {
        _handleContextMenuAction(context, value, node, provider);
      }
    });
  }

  void _showActionMenu(
    BuildContext context,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 300, 400),
      items: [
        PopupMenuItem(
          value: 'create_file',
          child: Row(
            children: [
              const Icon(Icons.note_add, size: 16),
              const SizedBox(width: 8),
              Text(l10n.createFile),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'create_folder',
          child: Row(
            children: [
              const Icon(Icons.create_new_folder, size: 16),
              const SizedBox(width: 8),
              Text(l10n.createFolder),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              const Icon(Icons.edit, size: 16),
              const SizedBox(width: 8),
              Text(l10n.rename),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.content_copy, size: 16),
              const SizedBox(width: 8),
              Text(l10n.copy),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'cut',
          child: Row(
            children: [
              const Icon(Icons.content_cut, size: 16),
              const SizedBox(width: 8),
              Text(l10n.cut),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, size: 16),
              const SizedBox(width: 8),
              Text(l10n.delete),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null && context.mounted) {
        _handleActionMenuAction(context, value, node, provider);
      }
    });
  }

  void _handleContextMenuAction(
    BuildContext context,
    String action,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    switch (action) {
      case 'create':
        _showCreateDialog(context, node);
        break;
      case 'rename':
        _showRenameDialog(context, node, provider);
        break;
      case 'copy':
        provider.copyNode(node);
        break;
      case 'cut':
        provider.cutNode(node);
        break;
      case 'delete':
        _showDeleteDialog(context, node, provider);
        break;
    }
  }

  void _handleActionMenuAction(
    BuildContext context,
    String action,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    switch (action) {
      case 'create_file':
        CreateFileDialogHelper.showCreateFileDialog(
          context,
          initialPath: node.path,
        );
        break;
      case 'create_folder':
        _showCreateFolderDialog(context, node, provider);
        break;
      case 'rename':
        _showRenameDialog(context, node, provider);
        break;
      case 'copy':
        provider.copyNode(node);
        break;
      case 'cut':
        provider.cutNode(node);
        break;
      case 'delete':
        _showDeleteDialog(context, node, provider);
        break;
    }
  }

  void _showCreateDialog(BuildContext context, FileExplorerNode node) {
    CreateFileDialogHelper.showCreateFileDialog(
      context,
      initialPath: node.path,
    );
  }

  void _showRenameDialog(
    BuildContext context,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rename),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.newName),
        ),
        actions: [
          ModernButton(
            text: l10n.cancel,
            type: ButtonType.secondary,
            onPressed: () => Navigator.pop(context),
          ),
          ModernButton(
            text: l10n.rename,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.renameNode(node, controller.text.trim());
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(
    BuildContext context,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createFolder),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.folderName),
        ),
        actions: [
          ModernButton(
            text: l10n.cancel,
            type: ButtonType.secondary,
            onPressed: () => Navigator.pop(context),
          ),
          ModernButton(
            text: l10n.create,
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.createFolderInDirectory(
                  node.path,
                  controller.text.trim(),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    FileExplorerNode node,
    FileExplorerProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(
          l10n.confirmDelete(
            node.isFolder ? l10n.folder : l10n.file,
            node.name,
          ),
        ),
        actions: [
          ModernButton(
            text: l10n.cancel,
            type: ButtonType.secondary,
            onPressed: () => Navigator.pop(context),
          ),
          ModernButton(
            text: l10n.delete,
            type: ButtonType.danger,
            onPressed: () {
              provider.deleteNode(node);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
