import 'dart:async';
import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

enum NsTooltipPosition { top, bottom, left, right }

/// Всплывающая подсказка NovaSpec
class NsTooltip extends StatefulWidget {
  final String message;
  final Widget child;
  final NsTooltipPosition position;
  final Duration delay;

  const NsTooltip({
    super.key,
    required this.message,
    required this.child,
    this.position = NsTooltipPosition.top,
    this.delay = const Duration(milliseconds: 500),
  });

  @override
  State<NsTooltip> createState() => _NsTooltipState();
}

class _NsTooltipState extends State<NsTooltip> {
  OverlayEntry? _overlayEntry;
  Timer? _timer;
  final LayerLink _layerLink = LayerLink();

  void _showTooltip() {
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (!mounted) return;

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: _getOffset(size),
            child: _TooltipContent(
              message: widget.message,
              position: widget.position,
              isDark: isDark,
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  void _hideTooltip() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Offset _getOffset(Size size) {
    switch (widget.position) {
      case NsTooltipPosition.top:
        return Offset(0, -8);
      case NsTooltipPosition.bottom:
        return Offset(0, size.height + 8);
      case NsTooltipPosition.left:
        return Offset(-8, size.height / 2);
      case NsTooltipPosition.right:
        return Offset(size.width + 8, size.height / 2);
    }
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => _showTooltip(),
        onExit: (_) => _hideTooltip(),
        child: widget.child,
      ),
    );
  }
}

class _TooltipContent extends StatelessWidget {
  final String message;
  final NsTooltipPosition position;
  final bool isDark;

  const _TooltipContent({
    required this.message,
    required this.position,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: (isDark ? NsColorsDark.popover : NsColorsLight.popover)
              .withValues(alpha: 0.95),
          borderRadius: NsRadius.md,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: NsTextStyles.bodySmall(context).copyWith(
            color: isDark
                ? NsColorsDark.popoverForeground
                : NsColorsLight.popoverForeground,
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment() {
    switch (position) {
      case NsTooltipPosition.top:
        return Alignment.bottomCenter;
      case NsTooltipPosition.bottom:
        return Alignment.topCenter;
      case NsTooltipPosition.left:
        return Alignment.centerRight;
      case NsTooltipPosition.right:
        return Alignment.centerLeft;
    }
  }
}
