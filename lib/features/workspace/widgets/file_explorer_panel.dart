import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/file_explorer_provider.dart';
import '../providers/panel_provider.dart';

import 'file_explorer_tree.dart';
import 'create_file_dialog.dart';

class FileExplorerPanel extends StatelessWidget {
  const FileExplorerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<PanelProvider>(
      builder: (context, panelProvider, child) {
        if (panelProvider.isFileExplorerCollapsed) {
          return Container(
            width: 48,
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
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, size: 16),
                      onPressed: () => panelProvider.toggleFileExplorer(),
                      tooltip: l10n.expandFileExplorerPanel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Breadcrumb
              _buildBreadcrumb(context),
              
              // File tree
              const Expanded(
                child: FileExplorerTree(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          SvgPicture.asset(
            'assets/images/novaspec-logo.svg',
            width: 80,
            height: 16,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () {
              final currentPath = context.read<FileExplorerProvider>().currentDirectory;
              CreateFileDialogHelper.showCreateFileDialog(
                context,
                initialPath: currentPath.isEmpty ? null : currentPath,
              );
            },
            tooltip: l10n.create,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: () {
              context.read<FileExplorerProvider>().refresh();
            },
            tooltip: l10n.refresh,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 16),
            onPressed: () => context.read<PanelProvider>().toggleFileExplorer(),
            tooltip: l10n.collapseFileExplorerPanel,
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

  Widget _buildBreadcrumb(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<FileExplorerProvider>(
      builder: (context, provider, child) {
        final path = provider.currentDirectory;
        if (path.isEmpty) {
          return Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.workspace,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          );
        }

        final parts = path.split('/').where((part) => part.isNotEmpty).toList();
        
        return Container(
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => provider.loadDirectory(''),
                child: const Text(
                  '🏠',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              ...parts.asMap().entries.map((entry) {
                final isLast = entry.key == parts.length - 1;
                return Row(
                  children: [
                    const Text(
                      ' / ',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    if (isLast)
                      Text(
                        entry.value,
                        style: const TextStyle(fontSize: 11),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          final newPath = parts.sublist(0, entry.key + 1).join('/');
                          provider.loadDirectory(newPath);
                        },
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }




}
