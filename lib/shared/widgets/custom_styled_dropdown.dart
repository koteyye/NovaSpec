import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CustomStyledDropdown<T> extends StatefulWidget {
  final T value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final Widget? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool isExpanded;
  final Color? dropdownColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Duration? animationDuration;

  const CustomStyledDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.icon,
    this.width,
    this.padding,
    this.isExpanded = false,
    this.dropdownColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.animationDuration,
  });

  @override
  State<CustomStyledDropdown<T>> createState() => _CustomStyledDropdownState<T>();
}

class _CustomStyledDropdownState<T> extends State<CustomStyledDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

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

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  // Обновляем анимацию цветов при изменении темы
  void _updateBorderColorAnimation() {
    final theme = Theme.of(context);
    _borderColorAnimation = ColorTween(
      begin: widget.borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.3),
      end: theme.colorScheme.primary.withValues(alpha: 0.8),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateBorderColorAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
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

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: _buildDropdownMenu(),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    final theme = Theme.of(context);
    final effectiveDropdownColor = widget.dropdownColor ?? theme.colorScheme.surface;
    final effectiveTextColor = widget.textColor ?? theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _toggleDropdown,
        behavior: HitTestBehavior.translucent,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: effectiveDropdownColor,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppConstants.defaultBorderRadius,
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppConstants.defaultBorderRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = item.value == widget.value;
                final isLast = index == widget.items.length - 1;

                 return _buildMenuItem(
                   item,
                   isSelected,
                   isLast,
                   effectiveTextColor,
                   theme,
                 );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    DropdownItem<T> item,
    bool isSelected,
    bool isLast,
    Color textColor,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        widget.onChanged?.call(item.value);
        _toggleDropdown();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: isLast 
              ? null 
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1.0,
                  ),
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                   color: isSelected 
                       ? theme.colorScheme.primary
                       : textColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = widget.textColor ?? theme.colorScheme.onSurface;
    final effectiveDropdownColor = widget.dropdownColor ?? theme.colorScheme.surface;

    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTap: _toggleDropdown,
                child: Focus(
                  onFocusChange: _onFocus,
                  child: Container(
                    width: widget.width,
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      boxShadow: _isHovered || _isFocused ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.items.firstWhere(
                              (item) => item.value == widget.value,
                              orElse: () => widget.items.first,
                            ).label,
                            style: TextStyle(
                              color: effectiveTextColor,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isOpen ? 0.5 : 0.0,
                          duration: AppConstants.shortAnimation,
                          child: widget.icon ?? Icon(
                            Icons.keyboard_arrow_down,
                            color: effectiveTextColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({
    required this.value,
    required this.label,
  });
}

// Удобный конструктор для dropdown настроек
class CustomSettingsDropdown extends StatefulWidget {
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String>? onChanged;
  final String? label;

  const CustomSettingsDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.label,
  });

  @override
  State<CustomSettingsDropdown> createState() => _CustomSettingsDropdownState();
}

class _CustomSettingsDropdownState extends State<CustomSettingsDropdown> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomStyledDropdown<String>(
      value: widget.value,
      isExpanded: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 8,
      borderWidth: 1.5,
      animationDuration: AppConstants.shortAnimation,
      // Используем цвета из темы вместо hardcoded
      dropdownColor: theme.colorScheme.surface,
      textColor: theme.colorScheme.onSurface,
      borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
      items: widget.items.map((item) {
        return DropdownItem<String>(
          value: item['value']!,
          label: item['label']!,
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          widget.onChanged?.call(value);
        }
      },
    );
  }
}
