import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../project/providers/project_provider.dart';

class TopBar extends StatelessWidget {
  final ProjectProvider projectProvider;
  final VoidCallback onNewProject;
  final VoidCallback onOpenProject;
  final VoidCallback onSaveProject;
  final VoidCallback onSaveProjectAs;
  final VoidCallback onExit;

  const TopBar({
    super.key,
    required this.projectProvider,
    required this.onNewProject,
    required this.onOpenProject,
    required this.onSaveProject,
    required this.onSaveProjectAs,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Window controls (Windows/Linux)
          if (Theme.of(context).platform != TargetPlatform.macOS)
            Row(
              children: [
                const SizedBox(width: 8),
                _buildWindowControl(context, Colors.red),
                const SizedBox(width: 6),
                _buildWindowControl(context, Colors.yellow),
                const SizedBox(width: 6),
                _buildWindowControl(context, Colors.green),
                const SizedBox(width: 16),
              ],
            ),

          // App title
          Expanded(
            child: Center(
              child: Text(
                'NovaSpec',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // Menu items
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFileMenu(context, localizations),
              const SizedBox(width: 8),
              _buildEditMenu(context, localizations),
              const SizedBox(width: 8),
              _buildStatusIndicator(context, localizations),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWindowControl(BuildContext context, Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
    );
  }

  Widget _buildFileMenu(BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showFileMenu(context, localizations),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Файл',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMenu(BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showEditMenu(context, localizations),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Редактирование',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, AppLocalizations localizations) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, child) {
        final status = projectProvider.projectStatus;
        final hasUnsavedChanges = projectProvider.hasUnsavedChanges;
        final theme = Theme.of(context);
        
        Color statusColor;
        IconData statusIcon;
        
        if (!projectProvider.hasActiveProject) {
          statusColor = Colors.grey;
          statusIcon = Icons.circle_outlined;
        } else if (hasUnsavedChanges) {
          statusColor = Colors.orange;
          statusIcon = Icons.circle;
        } else {
          statusColor = Colors.green;
          statusIcon = Icons.circle;
        }
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusIcon,
              size: 8,
              color: statusColor,
            ),
            const SizedBox(width: 6),
            Text(
              _getStatusText(status, hasUnsavedChanges, localizations),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(String status, bool hasUnsavedChanges, AppLocalizations localizations) {
    if (!projectProvider.hasActiveProject) {
      return 'Нет проекта';
    } else if (hasUnsavedChanges) {
      return 'Есть изменения';
    } else {
      return 'Сохранено';
    }
  }

  void _showFileMenu(BuildContext context, AppLocalizations localizations) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.zero,
        overlay.localToGlobal(Offset.zero) & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'new',
          onTap: onNewProject,
          child: Row(
            children: [
              const Icon(Icons.file_present_outlined, size: 18),
              const SizedBox(width: 12),
              const Text('Новый проект'),
              const Spacer(),
              Text(
                'Ctrl+N',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'open',
          onTap: onOpenProject,
          child: Row(
            children: [
              const Icon(Icons.folder_open_outlined, size: 18),
              const SizedBox(width: 12),
              const Text('Открыть'),
              const Spacer(),
              Text(
                'Ctrl+O',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'save',
          onTap: onSaveProject,
          enabled: projectProvider.hasActiveProject,
          child: Row(
            children: [
              const Icon(Icons.save_outlined, size: 18),
              const SizedBox(width: 12),
              const Text('Сохранить'),
              const Spacer(),
              Text(
                'Ctrl+S',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'saveAs',
          onTap: onSaveProjectAs,
          enabled: projectProvider.hasActiveProject,
          child: Row(
            children: [
              const Icon(Icons.save_as_outlined, size: 18),
              const SizedBox(width: 12),
              const Text('Сохранить как'),
              const Spacer(),
              Text(
                'Ctrl+Shift+S',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'exit',
          onTap: onExit,
          child: const Row(
            children: [
              Icon(Icons.exit_to_app_outlined, size: 18),
              SizedBox(width: 12),
              Text('Выход'),
              Spacer(),
              Text(
                'Ctrl+Q',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditMenu(BuildContext context, AppLocalizations localizations) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.zero,
        overlay.localToGlobal(Offset.zero) & overlay.size,
      ),
      items: [
const PopupMenuItem<String>(
          value: 'undo',
          enabled: false,
          child: Row(
            children: [
              Icon(Icons.undo_outlined, size: 18),
              SizedBox(width: 12),
              Text('Отменить'),
              Spacer(),
              Text(
                'Ctrl+Z',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
value: 'redo',
          enabled: false,
          child: Row(
            children: [
              Icon(Icons.redo_outlined, size: 18),
              SizedBox(width: 12),
              Text('Повторить'),
              Spacer(),
              Text(
                'Ctrl+Y',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
value: 'cut',
          enabled: false,
          child: Row(
            children: [
              Icon(Icons.content_cut_outlined, size: 18),
              SizedBox(width: 12),
              Text('Вырезать'),
              Spacer(),
              Text(
                'Ctrl+X',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'copy',
          enabled: false, // TODO: Implement copy functionality
          child: Row(
            children: [
              Icon(Icons.content_copy_outlined, size: 18),
              SizedBox(width: 12),
              Text('Копировать'),
              Spacer(),
              Text(
                'Ctrl+C',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'paste',
          enabled: false, // TODO: Implement paste functionality
          child: Row(
            children: [
              Icon(Icons.content_paste_outlined, size: 18),
              SizedBox(width: 12),
              Text('Вставить'),
              Spacer(),
              Text(
                'Ctrl+V',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0x99000000),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}