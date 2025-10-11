import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/providers/project_provider.dart';
import 'package:novaspec/presentation/widgets/dialogs/settings_dialog.dart';
import 'package:novaspec/presentation/widgets/dialogs/templates_dialog.dart';
import 'package:novaspec/presentation/widgets/dialogs/about_dialog.dart';

/// TopBar компонент с меню и индикаторами
class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectNotifier = ref.read(projectProvider.notifier);
    final projectState = ref.watch(projectProvider);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.panel : NsColorsLight.panel,
        border: Border(
          bottom: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left side - Menus
          _MenuButton(
            label: 'Файл',
            items: [
              _MenuItem(
                label: 'Новый проект',
                shortcut: 'Ctrl+N',
                onTap: () async {
                  final success = await projectNotifier.createNewProject();
                  if (success && context.mounted) {
                    context.go('/');
                  }
                },
              ),
              _MenuItem(
                label: 'Открыть проект',
                shortcut: 'Ctrl+O',
                onTap: () async {
                  final success = await projectNotifier.openProject();
                  if (success && context.mounted) {
                    context.go('/');
                  }
                },
              ),
              _MenuItem.divider(),
              _MenuItem(
                label: 'Сохранить',
                shortcut: 'Ctrl+S',
                onTap: () async {
                  await projectNotifier.saveCurrentFile();
                },
                enabled: projectState.activeFile != null && projectState.hasUnsavedChanges,
              ),
              _MenuItem(
                label: 'Сохранить как...',
                onTap: () async {
                  await projectNotifier.saveAs();
                },
                enabled: projectState.activeFile != null,
              ),
            ],
          ),
          _MenuButton(
            label: 'Настройки',
            items: [
              _MenuItem(
                label: 'Параметры',
                shortcut: 'Ctrl+,',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SettingsDialog(),
                  );
                },
              ),
              _MenuItem(
                label: 'Шаблоны',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TemplatesDialog(),
                  );
                },
              ),
            ],
          ),
          _MenuButton(
            label: 'О программе',
            items: [
              _MenuItem(
                label: 'О NovaSpec',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const NsAboutDialog(),
                  );
                },
              ),
            ],
          ),

          const Spacer(),

          // Right side - Indicators
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NsSpacing.md),
            child: Row(
              children: [
                _StatusIndicator(
                  icon: Icons.psychology_outlined,
                  label: 'AI',
                  isActive: false,
                  tooltip: 'AI не настроен',
                  onTap: () {
                    // TODO: Open AI settings
                  },
                ),
                const SizedBox(width: NsSpacing.sm),
                _StatusIndicator(
                  icon: Icons.cloud_outlined,
                  label: 'Confluence',
                  isActive: false,
                  tooltip: 'Confluence не настроен',
                  onTap: () {
                    // TODO: Open Confluence settings
                  },
                ),
                const SizedBox(width: NsSpacing.sm),
                _StatusIndicator(
                  icon: Icons.music_note_outlined,
                  label: 'Музыка',
                  isActive: false,
                  tooltip: 'Музыка отключена',
                  onTap: () {
                    // TODO: Open Music settings
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Элемент меню
class _MenuItem {
  final String label;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool isDivider;
  final bool enabled;

  const _MenuItem({
    required this.label,
    this.shortcut,
    this.onTap,
    this.enabled = true,
  }) : isDivider = false;

  const _MenuItem.divider()
      : label = '',
        shortcut = null,
        onTap = null,
        enabled = true,
        isDivider = true;
}

/// Кнопка меню с выпадающим списком
class _MenuButton extends StatefulWidget {
  final String label;
  final List<_MenuItem> items;

  const _MenuButton({
    required this.label,
    required this.items,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;

  void _showMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<void>(
      context: context,
      position: position,
      items: widget.items.map<PopupMenuEntry<void>>((item) {
        if (item.isDivider) {
          return const PopupMenuDivider();
        }
        return PopupMenuItem<void>(
          enabled: item.enabled,
          onTap: item.enabled ? item.onTap : null,
          child: Opacity(
            opacity: item.enabled ? 1.0 : 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label),
                if (item.shortcut != null) ...[
                  const SizedBox(width: NsSpacing.xl),
                  Text(
                    item.shortcut!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: _showMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NsSpacing.md,
            vertical: NsSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? (isDark ? NsColorsDark.hover : NsColorsLight.hover)
                : Colors.transparent,
          ),
          child: Text(
            widget.label,
            style: NsTextStyles.bodyMedium(context),
          ),
        ),
      ),
    );
  }
}

/// Индикатор состояния
class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final String tooltip;
  final VoidCallback? onTap;

  const _StatusIndicator({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive
        ? (isDark ? NsColorsDark.indicatorActive : NsColorsLight.indicatorActive)
        : (isDark ? NsColorsDark.indicatorInactive : NsColorsLight.indicatorInactive);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NsSpacing.sm,
            vertical: NsSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
