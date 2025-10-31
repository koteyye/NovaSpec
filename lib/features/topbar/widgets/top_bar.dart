import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../l10n/app_localizations.dart';
import '../../project/providers/project_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../settings/widgets/settings_dialog.dart';

class TopBar extends StatelessWidget {
  final ProjectProvider projectProvider;
  final SettingsProvider settingsProvider;
  final VoidCallback onNewProject;
  final VoidCallback onOpenProject;
  final VoidCallback onSaveProject;
  final VoidCallback onSaveProjectAs;
  final VoidCallback onExit;
  final VoidCallback? onOpenTemplates;
  final VoidCallback? onOpenAbout;

  const TopBar({
    super.key,
    required this.projectProvider,
    required this.settingsProvider,
    required this.onNewProject,
    required this.onOpenProject,
    required this.onSaveProject,
    required this.onSaveProjectAs,
    required this.onExit,
    this.onOpenTemplates,
    this.onOpenAbout,
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
          // Window controls (macOS only)
          if (Theme.of(context).platform == TargetPlatform.macOS)
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

          // Левая сторона - кнопки меню
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFileMenu(context, localizations),
              const SizedBox(width: 8),
              _buildSettingsMenu(context, localizations),
              const SizedBox(width: 8),
              _buildAboutMenu(context, localizations),
            ],
          ),

          // App title в центре
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

          // Правая сторона - индикаторы статуса
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIndicators(context, localizations),
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
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.files,
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

  Widget _buildSettingsMenu(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showSettingsMenu(context, localizations),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.settings,
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

  Widget _buildAboutMenu(BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onOpenAbout,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
        ),
        child: Text(
          localizations.about,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildStatusIndicators(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return ListenableBuilder(
      listenable: Listenable.merge([projectProvider, settingsProvider]),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAIProviderIndicator(context, theme),
            const SizedBox(width: 8),
            _buildConfluenceIndicator(context, theme),
            const SizedBox(width: 8),
            _buildMusicIndicator(context, theme),
          ],
        );
      },
    );
  }

  Widget _buildAIProviderIndicator(BuildContext context, ThemeData theme) {
    final provider = settingsProvider.currentProvider;
    final hasToken =
        settingsProvider.getProviderToken(provider)?.isNotEmpty == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: hasToken 
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.psychology,
            size: 16,
            color: hasToken
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          if (hasToken) ...[
            const SizedBox(width: 6),
            Text(
              _getProviderDisplayName(provider),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            const SizedBox(width: 6),
            Text(
              'Провайдер',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfluenceIndicator(BuildContext context, ThemeData theme) {
    final isActive =
        settingsProvider.confluenceEnabled &&
        settingsProvider.confluenceUrl.isNotEmpty &&
        settingsProvider.confluenceEmail.isNotEmpty &&
        settingsProvider.confluenceToken.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: isActive 
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/atlassian-icon.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              BlendMode.srcIn,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 6),
            Text(
              'Confluence',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            const SizedBox(width: 6),
            Text(
              'Confluence',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMusicIndicator(BuildContext context, ThemeData theme) {
    final isActive =
        settingsProvider.musicEnabled && settingsProvider.musicToken.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
        color: isActive 
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_note,
            size: 16,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          if (isActive) ...[
            const SizedBox(width: 6),
            Text(
              '${settingsProvider.musicBalance} ₽',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '·',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              settingsProvider.getGenreDisplayName(settingsProvider.musicGenre),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _refreshMusicBalance(),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.refresh,
                  size: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 6),
            Text(
              'Музикация',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getProviderDisplayName(AIProvider provider) {
    return provider.displayName;
  }

  void _refreshMusicBalance() async {
    // TODO: Implement music balance refresh
    // This would call the music validation service to update the balance
  }

  void _showFileMenu(BuildContext context, AppLocalizations localizations) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.zero,
        overlay.localToGlobal(Offset.zero) & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'new',
          child: Row(
            children: [
              const Icon(Icons.file_present_outlined, size: 18),
              const SizedBox(width: 12),
              Text(localizations.newProject),
              const Spacer(),
              Text(
                'Ctrl+N',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'open',
          child: Row(
            children: [
              const Icon(Icons.folder_open_outlined, size: 18),
              const SizedBox(width: 12),
              Text(localizations.openProject),
              const Spacer(),
              Text(
                'Ctrl+O',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'save',
          enabled: projectProvider.hasActiveProject,
          child: Row(
            children: [
              const Icon(Icons.save_outlined, size: 18),
              const SizedBox(width: 12),
              Text(localizations.save),
              const Spacer(),
              Text(
                'Ctrl+S',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'saveAs',
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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'exit',
          child: Row(
            children: [
              const Icon(Icons.exit_to_app_outlined, size: 18),
              const SizedBox(width: 12),
              Text(localizations.close),
              const Spacer(),
              const Text(
                'Ctrl+Q',
                style: TextStyle(fontSize: 12, color: Color(0x99000000)),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'new':
            onNewProject();
            break;
          case 'open':
            onOpenProject();
            break;
          case 'save':
            onSaveProject();
            break;
          case 'saveAs':
            onSaveProjectAs();
            break;
          case 'exit':
            onExit();
            break;
        }
      }
    });
  }

  void _showSettingsMenu(BuildContext context, AppLocalizations localizations) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.zero,
        overlay.localToGlobal(Offset.zero) & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 18),
              const SizedBox(width: 12),
              const Text('Параметры'),
              const Spacer(),
              Text(
                'Ctrl+,',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'templates',
          child: Row(
            children: [
              Icon(Icons.dashboard_outlined, size: 18),
              SizedBox(width: 12),
              Text('Шаблоны'),
            ],
          ),
        ),
      ],
    );
    
    if (value != null) {
      switch (value) {
        case 'settings':
          if (context.mounted) {
            _showSettingsDialog(context);
          }
          break;
        case 'templates':
          onOpenTemplates?.call();
          break;
      }
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(settingsProvider: settingsProvider),
    );
  }
}
