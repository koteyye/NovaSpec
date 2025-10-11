import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';

/// Варианты кнопок
enum ButtonVariant {
  primary,
  secondary,
  destructive,
  ghost,
}

/// Размеры кнопок
enum ButtonSize {
  small,
  medium,
  large,
}

/// Компонент кнопки для NovaSpec
class NsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool fullWidth;
  final bool loading;
  final bool enabled;

  const NsButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Определяем цвета в зависимости от варианта
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = isDark ? NsColorsDark.primary : NsColorsLight.primary;
        foregroundColor = isDark ? NsColorsDark.primaryForeground : NsColorsLight.primaryForeground;
        borderColor = null;
        break;
      case ButtonVariant.secondary:
        backgroundColor = isDark ? NsColorsDark.secondary : NsColorsLight.secondary;
        foregroundColor = isDark ? NsColorsDark.secondaryForeground : NsColorsLight.secondaryForeground;
        borderColor = isDark ? NsColorsDark.border : NsColorsLight.border;
        break;
      case ButtonVariant.destructive:
        backgroundColor = isDark ? NsColorsDark.destructive : NsColorsLight.destructive;
        foregroundColor = isDark ? NsColorsDark.destructiveForeground : NsColorsLight.destructiveForeground;
        borderColor = null;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? NsColorsDark.foreground : NsColorsLight.foreground;
        borderColor = null;
        break;
    }

    // Определяем размеры
    double height;
    double horizontalPadding;
    double fontSize;

    switch (size) {
      case ButtonSize.small:
        height = 32;
        horizontalPadding = NsSpacing.md;
        fontSize = 12;
        break;
      case ButtonSize.medium:
        height = 40;
        horizontalPadding = NsSpacing.lg;
        fontSize = 14;
        break;
      case ButtonSize.large:
        height = 48;
        horizontalPadding = NsSpacing.xl;
        fontSize = 16;
        break;
    }

    return SizedBox(
      height: height,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: (loading || !enabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        ),
        child: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: NsSpacing.sm),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
