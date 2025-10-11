import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Модель вкладки
class NsTab {
  final String label;
  final Widget? icon;
  final bool closable;

  const NsTab({
    required this.label,
    this.icon,
    this.closable = false,
  });
}

/// Панель вкладок NovaSpec
class NsTabBar extends StatelessWidget {
  final List<NsTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;
  final ValueChanged<int>? onTabClosed;

  const NsTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
    this.onTabClosed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return _NsTabItem(
            tab: tabs[index],
            isSelected: index == selectedIndex,
            onTap: () => onTabSelected?.call(index),
            onClose: tabs[index].closable ? () => onTabClosed?.call(index) : null,
          );
        },
      ),
    );
  }
}

class _NsTabItem extends StatefulWidget {
  final NsTab tab;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const _NsTabItem({
    required this.tab,
    required this.isSelected,
    this.onTap,
    this.onClose,
  });

  @override
  State<_NsTabItem> createState() => _NsTabItemState();
}

class _NsTabItemState extends State<_NsTabItem> {
  bool _isHovered = false;

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isSelected) {
      return isDark ? NsColorsDark.editor : NsColorsLight.editor;
    }

    if (_isHovered) {
      return _lighten(
        isDark ? NsColorsDark.muted : NsColorsLight.muted,
        0.05,
      );
    }

    return isDark ? NsColorsDark.muted : NsColorsLight.muted;
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isSelected) {
      return isDark ? NsColorsDark.foreground : NsColorsLight.foreground;
    }

    return isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground;
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightened = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: NsSpacing.md),
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(NsBorderRadius.lg),
              topRight: Radius.circular(NsBorderRadius.lg),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.tab.icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: _getTextColor(context),
                    size: 16,
                  ),
                  child: widget.tab.icon!,
                ),
                const SizedBox(width: NsSpacing.xs),
              ],
              Text(
                widget.tab.label,
                style: NsTextStyles.bodyMedium(context).copyWith(
                  color: _getTextColor(context),
                  fontWeight: widget.isSelected ? NsFontWeights.medium : NsFontWeights.regular,
                ),
              ),
              if (widget.onClose != null) ...[
                const SizedBox(width: NsSpacing.xs),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: _getTextColor(context),
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
