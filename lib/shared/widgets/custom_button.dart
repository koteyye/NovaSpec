import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderSide? borderSide;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.height,
    this.width,
    this.padding,
    this.borderSide,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 8.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ButtonStyle buttonStyle;
    switch (variant) {
      case ButtonVariant.primary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        break;
      case ButtonVariant.secondary:
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 1,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        break;
      case ButtonVariant.outlined:
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? theme.primaryColor,
          side: borderSide ?? BorderSide(color: theme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
        break;
      case ButtonVariant.text:
        buttonStyle = TextButton.styleFrom(
          foregroundColor: foregroundColor ?? theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
        break;
    }

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ??
            (variant == ButtonVariant.outlined || variant == ButtonVariant.text
                ? theme.primaryColor
                : Colors.white),
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    Widget button;
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    if (height != null || width != null) {
      button = SizedBox(
        height: height,
        width: width,
        child: button,
      );
    }

    return button;
  }
}

// Кнопка с иконкой для панели инструментов
class IconButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  final double iconSize;

  const IconButtonCustom({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 40.0,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: onPressed != null
            ? theme.colorScheme.surface
            : theme.colorScheme.surface.withValues(alpha: 0.5),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize,
          color: color ??
              (onPressed != null
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: tooltip,
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// Плавающая кнопка действия
class FloatingActionButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const FloatingActionButtonCustom({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      child: Icon(icon),
    );
  }
}
