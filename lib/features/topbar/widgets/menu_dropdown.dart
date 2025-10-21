import 'package:flutter/material.dart';

class MenuDropdown<T> extends StatefulWidget {
  final T value;
  final List<MenuItem<T>> items;
  final ValueChanged<T?>? onSelected;
  final String? label;
  final Widget? icon;
  final double? width;
  final bool showShortcuts;
  final EdgeInsetsGeometry? padding;

  const MenuDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onSelected,
    this.label,
    this.icon,
    this.width,
    this.showShortcuts = true,
    this.padding,
  });

  @override
  State<MenuDropdown<T>> createState() => _MenuDropdownState<T>();
}

class _MenuDropdownState<T> extends State<MenuDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: _showMenu,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        width: widget.width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8),
            ],
            if (widget.label != null)
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }



  void _showMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);
    
    showMenu<T>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy + button.size.height, button.size.width, 0),
        Offset.zero & overlay.size,
      ),
      items: widget.items.map((item) => PopupMenuItem<T>(
        value: item.value,
        enabled: item.enabled,
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 18,
                color: item.enabled 
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: item.enabled 
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            if (widget.showShortcuts && item.shortcut != null) ...[
              const SizedBox(width: 12),
              Text(
                item.shortcut!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      )).toList(),
    ).then((value) {
      if (value != null) {
        widget.onSelected?.call(value);
      }
    });
  }
}

class MenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final String? shortcut;
  final bool enabled;

  const MenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.shortcut,
    this.enabled = true,
  });
}

// Predefined menu items for common actions
class MenuItems {
  static List<MenuItem<String>> getFileItems({
    bool hasProject = false,
    bool hasUnsavedChanges = false,
  }) {
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
    ];
  }

  static List<MenuItem<String>> getEditItems() {
    return const [
      MenuItem(
        value: 'undo',
        label: 'Отменить',
        icon: Icons.undo_outlined,
        shortcut: 'Ctrl+Z',
        enabled: false, // TODO: Implement undo functionality
      ),
      MenuItem(
        value: 'redo',
        label: 'Повторить',
        icon: Icons.redo_outlined,
        shortcut: 'Ctrl+Y',
        enabled: false, // TODO: Implement redo functionality
      ),
      const MenuItem(
        value: 'separator1',
        label: '---',
      ),
      const MenuItem(
        value: 'cut',
        label: 'Вырезать',
        icon: Icons.content_cut_outlined,
        shortcut: 'Ctrl+X',
        enabled: false, // TODO: Implement cut functionality
      ),
      const MenuItem(
        value: 'copy',
        label: 'Копировать',
        icon: Icons.content_copy_outlined,
        shortcut: 'Ctrl+C',
        enabled: false, // TODO: Implement copy functionality
      ),
      const MenuItem(
        value: 'paste',
        label: 'Вставить',
        icon: Icons.content_paste_outlined,
        shortcut: 'Ctrl+V',
        enabled: false, // TODO: Implement paste functionality
      ),
    ];
  }

  static List<MenuItem<String>> getViewItems() {
    return [
      const MenuItem(
        value: 'toggleSidebar',
        label: 'Боковая панель',
        shortcut: 'Ctrl+B',
        enabled: false, // TODO: Implement sidebar
      ),
      const MenuItem(
        value: 'toggleTheme',
        label: 'Переключить тему',
        enabled: false, // TODO: Implement theme toggle
      ),
    ];
  }
}