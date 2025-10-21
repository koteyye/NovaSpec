import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/providers/app_provider.dart';
import 'package:provider/provider.dart';

class TopBarRefactored extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAbout;
  final VoidCallback onOpenTemplates;
  final VoidCallback onNewProject;
  final VoidCallback onOpenProject;
  final VoidCallback onSaveProject;
  final VoidCallback onSaveProjectAs;

  const TopBarRefactored({
    super.key,
    required this.onOpenSettings,
    required this.onOpenAbout,
    required this.onOpenTemplates,
    required this.onNewProject,
    required this.onOpenProject,
    required this.onSaveProject,
    required this.onSaveProjectAs,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Левая часть - Меню
            _buildMenuBar(context),
            
            const Spacer(),
            
            // Правая часть - Индикаторы статуса
            _buildStatusIndicators(context, appProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBar(BuildContext context) {
    return Row(
      children: [
        _MenuButton(
          text: 'Файл',
          menuItems: [
            _MenuItem(
              text: 'Новый проект',
              shortcut: 'Ctrl+N',
              onPressed: onNewProject,
            ),
            _MenuItem(
              text: 'Открыть проект',
              shortcut: 'Ctrl+O',
              onPressed: onOpenProject,
            ),
            _MenuItem(
              text: 'Сохранить',
              shortcut: 'Ctrl+S',
              onPressed: onSaveProject,
            ),
            _MenuItem(
              text: 'Сохранить как...',
              shortcut: 'Ctrl+Shift+S',
              onPressed: onSaveProjectAs,
            ),
          ],
        ),
        
        const SizedBox(width: 8),
        
        _MenuButton(
          text: 'Настройки',
          menuItems: [
            _MenuItem(
              text: 'Параметры',
              shortcut: 'Ctrl+,',
              onPressed: onOpenSettings,
            ),
            _MenuItem(
              text: 'Шаблоны',
              onPressed: onOpenTemplates,
            ),
          ],
        ),
        
        const SizedBox(width: 8),
        
        _MenuButton(
          text: 'О программе',
          menuItems: [
            _MenuItem(
              text: 'О NovaSpec',
              onPressed: onOpenAbout,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicators(BuildContext context, AppProvider appProvider) {
    return Row(
      children: [
        // AI Provider Indicator
        _StatusIndicator(
          icon: Icons.psychology,
          text: appProvider.aiProvider,
          isActive: appProvider.aiProvider.isNotEmpty,
          tooltip: 'AI-провайдер',
          iconColor: appProvider.aiProvider.isNotEmpty 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
        
        const SizedBox(width: 8),
        
        // Atlassian Indicator
        _StatusIndicator(
          icon: Icons.integration_instructions,
          text: '',
          isActive: appProvider.atlassianActive,
          tooltip: 'Интеграция с Confluence',
          customIcon: SvgPicture.asset(
            'assets/images/atlassian-icon.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(
              appProvider.atlassianActive 
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.outline,
              BlendMode.srcIn,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Music Indicator
        _StatusIndicator(
          icon: Icons.music_note,
          text: appProvider.musicActive 
              ? '${appProvider.musicBalance} ₽ · ${appProvider.musicGenre}'
              : '',
          isActive: appProvider.musicActive,
          tooltip: 'Музикация',
          iconColor: appProvider.musicActive 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          trailing: appProvider.musicActive 
              ? _IconButton(
                  icon: Icons.refresh,
                  onPressed: () => appProvider.refreshMusicBalance(),
                  tooltip: 'Обновить баланс',
                )
              : null,
        ),
      ],
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String text;
  final List<_MenuItem> menuItems;

  const _MenuButton({
    required this.text,
    required this.menuItems,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _showMenu(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered || _isMenuOpen
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      button.localToGlobal(Offset.zero, ancestor: overlay) & button.size,
      Offset.zero & overlay.size,
    );

    setState(() => _isMenuOpen = true);

    showMenu<String>(
      context: context,
      position: position,
      items: widget.menuItems.map((item) => PopupMenuItem<String>(
        value: item.text,
        onTap: () {
          setState(() => _isMenuOpen = false);
          item.onPressed();
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (item.shortcut.isNotEmpty) ...[
              const SizedBox(width: 16),
              Text(
                item.shortcut,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      )).toList(),
    ).then((_) {
      setState(() => _isMenuOpen = false);
    });
  }
}

class _MenuItem {
  final String text;
  final String shortcut;
  final VoidCallback onPressed;

  const _MenuItem({
    required this.text,
    this.shortcut = '',
    required this.onPressed,
  });
}

class _StatusIndicator extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String text;
  final bool isActive;
  final String tooltip;
  final Color? iconColor;
  final Widget? trailing;

  const _StatusIndicator({
    this.icon,
    this.customIcon,
    this.text = '',
    required this.isActive,
    required this.tooltip,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customIcon != null)
              customIcon!
            else if (icon != null)
              Icon(
                icon,
                size: 16,
                color: iconColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            if (text.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _IconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            icon,
            size: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}