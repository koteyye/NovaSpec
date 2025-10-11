import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Элемент меню NovaSpec (для TopBar, контекстных меню)
class NsMenuItem extends StatefulWidget {
  final String label;
  final Widget? icon;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool disabled;
  final bool destructive;

  const NsMenuItem({
    super.key,
    required this.label,
    this.icon,
    this.shortcut,
    this.onTap,
    this.disabled = false,
    this.destructive = false,
  });

  @override
  State<NsMenuItem> createState() => _NsMenuItemState();
}

class _NsMenuItemState extends State<NsMenuItem> {
  bool _isHovered = false;

  void _handleTap() {
    if (!widget.disabled && widget.onTap != null) {
      widget.onTap!();
    }
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.disabled) {
      return isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground;
    }

    if (widget.destructive) {
      return isDark ? NsColorsDark.destructive : NsColorsLight.destructive;
    }

    return isDark ? NsColorsDark.foreground : NsColorsLight.foreground;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: NsSpacing.sm),
          decoration: BoxDecoration(
            color: _isHovered && !widget.disabled
                ? (isDark ? NsColorsDark.hover : NsColorsLight.hover)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: _getTextColor(context),
                    size: 16,
                  ),
                  child: widget.icon!,
                ),
                const SizedBox(width: NsSpacing.sm),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: NsTextStyles.bodyMedium(context).copyWith(
                    color: _getTextColor(context),
                  ),
                ),
              ),
              if (widget.shortcut != null) ...[
                const SizedBox(width: NsSpacing.md),
                Text(
                  widget.shortcut!,
                  style: NsTextStyles.bodySmall(context).copyWith(
                    color: isDark
                        ? NsColorsDark.mutedForeground
                        : NsColorsLight.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
