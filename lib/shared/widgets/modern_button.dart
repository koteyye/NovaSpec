import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

// Современные кнопки с иерархией и состояниями

enum ButtonType {
  primary,   // Основное действие - burgundy с тенью
  secondary, // Второстепенное - outline
  tertiary,  // Вспомогательное - текстовая
  success,   // Успешное действие - зеленый
  warning,   // Предупреждение - оранжевый
  danger,    // Опасное действие - красный
}

class ModernButton extends StatelessWidget {
  final String text;
  final ButtonType type;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;
  final bool fullWidth;

  const ModernButton({
    super.key,
    required this.text,
    this.type = ButtonType.primary,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.semanticLabel,
    this.fullWidth = false,
  });

  // Получить цвета в зависимости от типа кнопки
  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return const Color(AppConstants.primaryColorValue);
      case ButtonType.secondary:
        return Colors.transparent;
      case ButtonType.tertiary:
        return Colors.transparent;
      case ButtonType.success:
        return const Color(AppConstants.successColorValue);
      case ButtonType.warning:
        return const Color(AppConstants.warningColorValue);
      case ButtonType.danger:
        return const Color(AppConstants.errorColorValue);
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.success:
      case ButtonType.warning:
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.secondary:
        return const Color(AppConstants.primaryColorValue);
      case ButtonType.tertiary:
        return const Color(AppConstants.secondaryColorValue);
    }
  }

  BorderSide _getBorderSide() {
    switch (type) {
      case ButtonType.secondary:
        return const BorderSide(color: Color(AppConstants.primaryColorValue), width: 1);
      case ButtonType.success:
        return const BorderSide(color: Color(AppConstants.successColorValue), width: 1);
      case ButtonType.warning:
        return const BorderSide(color: Color(AppConstants.warningColorValue), width: 1);
      case ButtonType.danger:
        return const BorderSide(color: Color(AppConstants.errorColorValue), width: 1);
      case ButtonType.primary:
      case ButtonType.tertiary:
        return BorderSide.none;
    }
  }

  double _getElevation() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.success:
      case ButtonType.warning:
      case ButtonType.danger:
        return 2.0;
      case ButtonType.secondary:
      case ButtonType.tertiary:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isButtonDisabled = isDisabled || isLoading || onPressed == null;
    final foregroundColor = _getForegroundColor();
    final backgroundColor = _getBackgroundColor();
    final borderSide = _getBorderSide();
    
    final buttonChild = child ?? _buildButtonContent(foregroundColor);

    // Определяем стиль кнопки
    ButtonStyle buttonStyle;
    
    if (type == ButtonType.tertiary) {
      // Проверяем, это иконковая кнопка (только иконка, без текста)
      final isIconButton = icon != null && text.isEmpty;
      
      if (isIconButton) {
        // Иконковая кнопка с гранатовым дизайном
        buttonStyle = OutlinedButton.styleFrom(
          foregroundColor: const Color(AppConstants.primaryColorValue).withValues(alpha: isButtonDisabled ? 0.5 : 1.0),
          side: const BorderSide(
            color: Color(AppConstants.primaryColorValue),
            width: 1.5,
          ),
          padding: EdgeInsets.zero, // Убираем паддинг для идеальной центрировки
          minimumSize: const Size(40, 40),
          maximumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          backgroundColor: Colors.transparent,
          alignment: Alignment.center, // Гарантируем центрирование
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (isButtonDisabled) return null;
            if (states.contains(WidgetState.hovered)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.2);
            }
            return null;
          }),
        );
        
        return SizedBox(
          width: 40,
          height: 40,
          child: OutlinedButton(
            onPressed: isButtonDisabled ? null : onPressed,
            style: buttonStyle,
            child: Icon(
              icon,
              size: 18,
              color: const Color(AppConstants.primaryColorValue).withValues(alpha: isButtonDisabled ? 0.5 : 1.0),
            ),
          ),
        );
      } else {
        // Обычная текстовая кнопка
        buttonStyle = TextButton.styleFrom(
foregroundColor: foregroundColor.withValues(alpha: isButtonDisabled ? 0.5 : 1.0),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (isButtonDisabled) return null;
            if (states.contains(WidgetState.hovered)) {
              return foregroundColor.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return foregroundColor.withValues(alpha: 0.2);
            }
            return null;
          }),
        );
        
        return SizedBox(
          width: fullWidth ? double.infinity : width,
          child: TextButton(
            onPressed: isButtonDisabled ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        );
      }
    } else if (type == ButtonType.secondary) {
      // Outline кнопка
      buttonStyle = OutlinedButton.styleFrom(
        foregroundColor: foregroundColor.withValues(alpha: isButtonDisabled ? 0.5 : 1.0),
        side: borderSide.copyWith(
          color: isButtonDisabled ? Colors.grey.shade300 : borderSide.color,
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (isButtonDisabled) return null;
          if (states.contains(WidgetState.hovered)) {
            return foregroundColor.withValues(alpha: 0.05);
          }
          return null;
        }),
      );
      
      return SizedBox(
        width: fullWidth ? double.infinity : width,
        child: OutlinedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      );
    } else {
      // Elevated кнопка (primary, success, warning, danger)
      buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: backgroundColor.withValues(alpha: isButtonDisabled ? 0.5 : 1.0),
        foregroundColor: foregroundColor,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        elevation: isButtonDisabled ? 0 : _getElevation(),
        shadowColor: Colors.black26,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (isButtonDisabled) return null;
          if (states.contains(WidgetState.hovered)) {
            return backgroundColor.withValues(alpha: 0.1);
          }
          if (states.contains(WidgetState.pressed)) {
            return backgroundColor.withValues(alpha: 0.2);
          }
          return null;
        }),
      );
      
      return SizedBox(
        width: fullWidth ? double.infinity : width,
        child: ElevatedButton(
          onPressed: isButtonDisabled ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      );
    }
  }

  Widget _buildButtonContent(Color foregroundColor) {
    if (isLoading) {
      return SizedBox(
        height: 16,
        width: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// Современный переключатель (toggle) с мягким дизайном
class ModernToggle extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final ButtonType type;

  const ModernToggle({
    super.key,
    required this.text,
    required this.isSelected,
    this.onTap,
    this.type = ButtonType.primary,
  });

  Color _getBackgroundColor() {
    if (!isSelected) return Colors.transparent;
    
    switch (type) {
      case ButtonType.primary:
        return const Color(AppConstants.primaryColorValue).withValues(alpha: 0.1);
      case ButtonType.success:
        return const Color(AppConstants.successColorValue).withValues(alpha: 0.1);
      case ButtonType.warning:
        return const Color(AppConstants.warningColorValue).withValues(alpha: 0.1);
      case ButtonType.danger:
        return const Color(AppConstants.errorColorValue).withValues(alpha: 0.1);
      case ButtonType.secondary:
      case ButtonType.tertiary:
        return const Color(AppConstants.secondaryColorValue).withValues(alpha: 0.1);
    }
  }

  Color _getForegroundColor() {
    if (!isSelected) return const Color(AppConstants.secondaryColorValue);
    
    switch (type) {
      case ButtonType.primary:
        return const Color(AppConstants.primaryColorValue);
      case ButtonType.success:
        return const Color(AppConstants.successColorValue);
      case ButtonType.warning:
        return const Color(AppConstants.warningColorValue);
      case ButtonType.danger:
        return const Color(AppConstants.errorColorValue);
      case ButtonType.secondary:
      case ButtonType.tertiary:
        return const Color(AppConstants.secondaryColorValue);
    }
  }

  Color _getBorderColor() {
    if (!isSelected) return const Color(0xFFE5E7EB);
    
    switch (type) {
      case ButtonType.primary:
        return const Color(AppConstants.primaryColorValue);
      case ButtonType.success:
        return const Color(AppConstants.successColorValue);
      case ButtonType.warning:
        return const Color(AppConstants.warningColorValue);
      case ButtonType.danger:
        return const Color(AppConstants.errorColorValue);
      case ButtonType.secondary:
      case ButtonType.tertiary:
        return const Color(AppConstants.secondaryColorValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: _getBorderColor(),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _getForegroundColor(),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
