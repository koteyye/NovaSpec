import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';

/// Контейнер для группировки контента в NovaSpec
class NsCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool hoverable;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;

  const NsCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.hoverable = false,
    this.backgroundColor,
    this.shadows,
  });

  @override
  State<NsCard> createState() => _NsCardState();
}

class _NsCardState extends State<NsCard> {
  bool _isHovered = false;

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    if (widget.hoverable && _isHovered) {
      return isDark ? NsColorsDark.hover : NsColorsLight.hover;
    }

    return isDark ? NsColorsDark.card : NsColorsLight.card;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: widget.padding ?? const EdgeInsets.all(NsSpacing.cardPadding),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: NsRadius.card,
        border: Border.all(
          color: isDark ? NsColorsDark.border : NsColorsLight.border,
          width: 1,
        ),
        boxShadow: widget.shadows,
      ),
      child: widget.child,
    );

    if (widget.onTap != null || widget.hoverable) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
