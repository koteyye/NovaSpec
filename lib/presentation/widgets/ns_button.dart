import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

enum NsButtonVariant { primary, secondary, outline, ghost, destructive }

enum NsButtonSize { small, medium, large, icon }

/// Универсальная кнопка NovaSpec с различными вариантами оформления
class NsButton extends StatefulWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final NsButtonVariant variant;
  final NsButtonSize size;
  final bool fullWidth;
  final bool disabled;
  final Widget? child;

  const NsButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.variant = NsButtonVariant.primary,
    this.size = NsButtonSize.medium,
    this.fullWidth = false,
    this.disabled = false,
    this.child,
  });

  @override
  State<NsButton> createState() => _NsButtonState();
}

class _NsButtonState extends State<NsButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case NsButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
      case NsButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 24);
      case NsButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 16, horizontal: 32);
      case NsButtonSize.icon:
        return const EdgeInsets.all(8);
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case NsButtonSize.small:
        return 32;
      case NsButtonSize.medium:
        return 40;
      case NsButtonSize.large:
        return 48;
      case NsButtonSize.icon:
        return 40;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.disabled) {
      switch (widget.variant) {
        case NsButtonVariant.primary:
          return (isDark ? NsColorsDark.primary : NsColorsLight.primary)
              .withValues(alpha: 0.5);
        case NsButtonVariant.secondary:
          return (isDark ? NsColorsDark.secondary : NsColorsLight.secondary)
              .withValues(alpha: 0.5);
        case NsButtonVariant.outline:
        case NsButtonVariant.ghost:
          return Colors.transparent;
        case NsButtonVariant.destructive:
          return (isDark ? NsColorsDark.destructive : NsColorsLight.destructive)
              .withValues(alpha: 0.5);
      }
    }

    if (_isPressed) {
      switch (widget.variant) {
        case NsButtonVariant.primary:
          return _darken(isDark ? NsColorsDark.primary : NsColorsLight.primary, 0.15);
        case NsButtonVariant.secondary:
          return _darken(isDark ? NsColorsDark.secondary : NsColorsLight.secondary, 0.1);
        case NsButtonVariant.outline:
          return isDark ? NsColorsDark.muted : NsColorsLight.muted;
        case NsButtonVariant.ghost:
          return isDark ? NsColorsDark.hover : NsColorsLight.hover;
        case NsButtonVariant.destructive:
          return _darken(isDark ? NsColorsDark.destructive : NsColorsLight.destructive, 0.15);
      }
    }

    if (_isHovered) {
      switch (widget.variant) {
        case NsButtonVariant.primary:
          return _darken(isDark ? NsColorsDark.primary : NsColorsLight.primary, 0.1);
        case NsButtonVariant.secondary:
          return _darken(isDark ? NsColorsDark.secondary : NsColorsLight.secondary, 0.05);
        case NsButtonVariant.outline:
          return (isDark ? NsColorsDark.muted : NsColorsLight.muted)
              .withValues(alpha: 0.5);
        case NsButtonVariant.ghost:
          return (isDark ? NsColorsDark.hover : NsColorsLight.hover)
              .withValues(alpha: 0.5);
        case NsButtonVariant.destructive:
          return _darken(isDark ? NsColorsDark.destructive : NsColorsLight.destructive, 0.1);
      }
    }

    switch (widget.variant) {
      case NsButtonVariant.primary:
        return isDark ? NsColorsDark.primary : NsColorsLight.primary;
      case NsButtonVariant.secondary:
        return isDark ? NsColorsDark.secondary : NsColorsLight.secondary;
      case NsButtonVariant.outline:
      case NsButtonVariant.ghost:
        return Colors.transparent;
      case NsButtonVariant.destructive:
        return isDark ? NsColorsDark.destructive : NsColorsLight.destructive;
    }
  }

  Color _getForegroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.variant) {
      case NsButtonVariant.primary:
        return isDark ? NsColorsDark.primaryForeground : NsColorsLight.primaryForeground;
      case NsButtonVariant.secondary:
        return isDark ? NsColorsDark.secondaryForeground : NsColorsLight.secondaryForeground;
      case NsButtonVariant.outline:
      case NsButtonVariant.ghost:
        return isDark ? NsColorsDark.foreground : NsColorsLight.foreground;
      case NsButtonVariant.destructive:
        return isDark ? NsColorsDark.destructiveForeground : NsColorsLight.destructiveForeground;
    }
  }

  BorderSide? _getBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.variant == NsButtonVariant.outline) {
      return BorderSide(
        color: isDark ? NsColorsDark.border : NsColorsLight.border,
      );
    }
    return null;
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.child ??
        Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              if (widget.text != null) const SizedBox(width: NsSpacing.sm),
            ],
            if (widget.text != null)
              Text(
                widget.text!,
                style: NsTextStyles.button(context).copyWith(
                  color: _getForegroundColor(context),
                ),
              ),
          ],
        );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: widget.size == NsButtonSize.icon ? _getHeight() : null,
          width: widget.fullWidth
              ? double.infinity
              : (widget.size == NsButtonSize.icon ? _getHeight() : null),
          constraints: widget.size == NsButtonSize.icon
              ? BoxConstraints.tight(Size(_getHeight(), _getHeight()))
              : null,
          child: ElevatedButton(
            onPressed: widget.disabled ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getBackgroundColor(context),
              foregroundColor: _getForegroundColor(context),
              padding: _getPadding(),
              shape: RoundedRectangleBorder(
                borderRadius: NsRadius.button,
                side: _getBorder(context) ?? BorderSide.none,
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
