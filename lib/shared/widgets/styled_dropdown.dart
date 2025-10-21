import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class StyledDropdown<T> extends StatefulWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final Widget? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool isDense;
  final bool isExpanded;
  final Color? dropdownColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Duration? animationDuration;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.icon,
    this.width,
    this.padding,
    this.isDense = true,
    this.isExpanded = false,
    this.dropdownColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.animationDuration,
  });

  @override
  State<StyledDropdown<T>> createState() => _StyledDropdownState<T>();
}

class _StyledDropdownState<T> extends State<StyledDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _borderColorAnimation;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? AppConstants.mediumAnimation,
      vsync: this,
    );

    _borderAnimation = Tween<double>(
      begin: widget.borderWidth ?? 1.0,
      end: (widget.borderWidth ?? 1.0) + 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: widget.borderColor ?? Colors.grey.withValues(alpha: 0.3),
      end: const Color(AppConstants.accentColorValue).withValues(alpha: 0.8),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered || _isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onFocus(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
    if (isFocused || _isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = widget.textColor ?? theme.colorScheme.onSurface;
    final effectiveDropdownColor = widget.dropdownColor ?? theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: Focus(
            onFocusChange: _onFocus,
            child: Container(
              width: widget.width,
              padding: widget.padding,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _borderColorAnimation.value ?? 
                         (widget.borderColor ?? Colors.grey.withValues(alpha: 0.3)),
                  width: _borderAnimation.value,
                ),
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? AppConstants.defaultBorderRadius,
                ),
                color: effectiveDropdownColor,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: widget.value,
                  items: widget.items.map((item) {
                    return DropdownMenuItem<T>(
                      value: item.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: effectiveTextColor,
                                  fontSize: 14,
                                ),
                                child: item.child,
                              ),
                            ),
                            if (item.value == widget.value)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: widget.onChanged,
                  hint: widget.hint != null 
                      ? Text(
                          widget.hint!,
                          style: TextStyle(
                            color: effectiveTextColor.withValues(alpha: 0.6),
                          ),
                        )
                      : null,
                  icon: widget.icon ?? Icon(
                    Icons.keyboard_arrow_down,
                    color: effectiveTextColor,
                  ),
                  isDense: widget.isDense,
                  isExpanded: widget.isExpanded,
                  dropdownColor: effectiveDropdownColor,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: 14,
                  ),
                  selectedItemBuilder: (context) {
                    return widget.items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.centerLeft,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: effectiveTextColor,
                            fontSize: 14,
                          ),
                          child: item.child,
                        ),
                      );
                    }).toList();
                  },
                  onTap: () {
                    // Анимация при клике
                    _animationController.forward().then((_) {
                      _animationController.reverse();
                    });
                  },
                  // Кастомизация dropdown menu
                  menuMaxHeight: 200,

                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  elevation: 8,
                  underline: const SizedBox(), // Убираем стандартную underline
                  focusColor: Colors.transparent,
                  autofocus: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Удобный конструктор для dropdown настроек
class SettingsDropdown extends StatelessWidget {
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String>? onChanged;
  final String? label;

  const SettingsDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return StyledDropdown<String>(
      value: value,
      isExpanded: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      borderRadius: 8,
      borderWidth: 1.5,
      animationDuration: AppConstants.shortAnimation,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
        );
      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onChanged?.call(value);
                    }
                  },
    );
  }
}