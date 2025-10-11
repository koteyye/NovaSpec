import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';

/// Компонент карточки для NovaSpec
class NsCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;

  const NsCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark ? NsColorsDark.card : NsColorsLight.card;

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? NsColorsDark.border : NsColorsLight.border,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: isDark ? NsColorsDark.hover : NsColorsLight.hover,
        child: content,
      );
    }

    return content;
  }
}
