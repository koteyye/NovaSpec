import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/toast_service.dart';
import '../../project/providers/project_provider.dart';
import '../widgets/menu_dropdown.dart';

class FileMenu extends StatelessWidget {
  final ProjectProvider projectProvider;
  final VoidCallback? onNewProject;
  final VoidCallback? onOpenProject;
  final VoidCallback? onSaveProject;
  final VoidCallback? onSaveProjectAs;
  final VoidCallback? onExit;

  const FileMenu({
    super.key,
    required this.projectProvider,
    this.onNewProject,
    this.onOpenProject,
    this.onSaveProject,
    this.onSaveProjectAs,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, child) {
        final menuItems = _getMenuItems(localizations);

        return MenuDropdown<String>(
          value: 'file',
          label: 'Файл',
          items: menuItems,
          onSelected: _handleMenuAction,
          width: 120,
        );
      },
    );
  }

  List<MenuItem<String>> _getMenuItems(AppLocalizations localizations) {
    final hasProject = projectProvider.hasActiveProject;
    final hasUnsavedChanges = projectProvider.hasUnsavedChanges;

return [
      const MenuItem(
        value: 'new',
        label: 'Новый',
        icon: Icons.add_circle_outline,
        shortcut: 'Ctrl+N',
      ),
      const MenuItem(
        value: 'open',
        label: 'Открыть',
        icon: Icons.folder_open_outlined,
        shortcut: 'Ctrl+O',
      ),
      const MenuItem(
        value: 'separator1',
        label: '---',
      ),
      MenuItem(
        value: 'save',
        label: 'Сохранить',
        icon: Icons.save_outlined,
        shortcut: 'Ctrl+S',
        enabled: hasProject && hasUnsavedChanges,
      ),
      MenuItem(
        value: 'saveAs',
        label: 'Сохранить как',
        icon: Icons.save_as_outlined,
        shortcut: 'Ctrl+Shift+S',
        enabled: hasProject,
      ),
      const MenuItem(
        value: 'separator2',
        label: '---',
      ),
      const MenuItem(
        value: 'exit',
        label: 'Выход',
        icon: Icons.exit_to_app_outlined,
      ),
      const MenuItem(
        value: 'open',
        label: 'Открыть',
        icon: Icons.folder_open_outlined,
        shortcut: 'Ctrl+O',
      ),
      const MenuItem(
        value: 'separator1',
        label: '---',
      ),
      MenuItem(
        value: 'save',
        label: 'Сохранить',
        icon: Icons.save_outlined,
        shortcut: 'Ctrl+S',
        enabled: hasProject && hasUnsavedChanges,
      ),
      MenuItem(
        value: 'saveAs',
        label: 'Сохранить как',
        icon: Icons.save_as_outlined,
        shortcut: 'Ctrl+Shift+S',
        enabled: hasProject,
      ),
      const MenuItem(
        value: 'separator2',
        label: '---',
      ),
      MenuItem(
        value: 'recentProjects',
        label: 'Недавние проекты',
        icon: Icons.history_outlined,
        enabled: projectProvider.recentProjects.isNotEmpty,
      ),
      const MenuItem(
        value: 'separator3',
        label: '---',
      ),
      const MenuItem(
        value: 'exit',
        label: 'Выход',
        icon: Icons.exit_to_app_outlined,
      ),
    ];
  }

  void _handleMenuAction(String? action) {
    if (action == null || action == '---') return;

    switch (action) {
      case 'new':
        onNewProject?.call();
        break;
      case 'open':
        onOpenProject?.call();
        break;
      case 'save':
        onSaveProject?.call();
        break;
      case 'saveAs':
        onSaveProjectAs?.call();
        break;
      case 'recentProjects':
        _showRecentProjects();
        break;
      case 'exit':
        onExit?.call();
        break;
    }
  }

  void _showRecentProjects() {
    // TODO: Implement recent projects dialog
    // This would show a list of recent projects from projectProvider.recentProjects
  }
}

// File menu action handler for easier integration
class FileMenuActionHandler {
  final ProjectProvider projectProvider;
  final BuildContext context;
  final VoidCallback? onNewProjectCallback;
  final VoidCallback? onOpenProjectCallback;
  final VoidCallback? onSaveProjectCallback;
  final VoidCallback? onSaveProjectAsCallback;
  final VoidCallback? onExitCallback;

  FileMenuActionHandler({
    required this.projectProvider,
    required this.context,
    this.onNewProjectCallback,
    this.onOpenProjectCallback,
    this.onSaveProjectCallback,
    this.onSaveProjectAsCallback,
    this.onExitCallback,
  });

  Future<void> handleNewProject() async {
    onNewProjectCallback?.call();
  }

  Future<void> handleOpenProject() async {
    onOpenProjectCallback?.call();
  }

  Future<void> handleSaveProject() async {
    if (projectProvider.hasActiveProject && projectProvider.hasUnsavedChanges) {
      if (onSaveProjectCallback != null) {
        onSaveProjectCallback!();
      }
    }
  }

  Future<void> handleSaveProjectAs() async {
    if (projectProvider.hasActiveProject) {
      if (onSaveProjectAsCallback != null) {
        onSaveProjectAsCallback!();
      }
    }
  }

  Future<void> handleRecentProjects() async {
    await _showRecentProjectsDialog();
  }

  Future<void> handleExit() async {
    // Check for unsaved changes
    if (projectProvider.hasUnsavedChanges) {
      final shouldExit = await _showUnsavedChangesDialog();
      if (shouldExit == true) {
        onExitCallback?.call();
      }
    } else {
      onExitCallback?.call();
    }
  }

  Future<void> _showRecentProjectsDialog() async {
    final recentProjects = projectProvider.recentProjects;

    if (recentProjects.isEmpty) {
      show(description: 'Нет недавних проектов');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Недавние проекты'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemCount: recentProjects.length,
            itemBuilder: (context, index) {
              final project = recentProjects[index];
              return ListTile(
                leading: Icon(
                  project.isAccessible ? Icons.description_outlined : Icons.error_outline,
                  color: project.isAccessible ? null : Colors.red,
                ),
                title: Text(project.name),
                subtitle: Text(
                  project.filePath,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: Text(
                  _formatDate(project.lastModified),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                enabled: project.isAccessible,
                onTap: () {
                  Navigator.of(context).pop();
                  // Open the selected project
                  onOpenProjectCallback?.call();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Несохраненные изменения'),
        content: const Text('У вас есть несохраненные изменения. Сохранить их перед выходом?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Не сохранять'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              if (onSaveProjectCallback != null) {
                onSaveProjectCallback!();
              }
            },
            child: const Text('Сохранить'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Вчера, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
