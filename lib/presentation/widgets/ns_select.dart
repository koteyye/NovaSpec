import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Опция для NsSelect
class NsSelectOption<T> {
  final T value;
  final String label;
  final Widget? icon;

  const NsSelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Выпадающий список NovaSpec
class NsSelect<T> extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final T? value;
  final List<NsSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const NsSelect({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    required this.options,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<NsSelect<T>> createState() => _NsSelectState<T>();
}

class _NsSelectState<T> extends State<NsSelect<T>> {
  bool _isHovered = false;
  bool _isFocused = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String get _displayText {
    if (widget.value == null) {
      return widget.placeholder ?? 'Выберите...';
    }
    final option = widget.options.firstWhere((opt) => opt.value == widget.value);
    return option.label;
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_overlayEntry == null) {
      _showDropdown();
    } else {
      _hideDropdown();
    }
  }

  void _showDropdown() {
    setState(() => _isFocused = true);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: isDark ? NsColorsDark.popover : NsColorsLight.popover,
                borderRadius: NsRadius.md,
                border: Border.all(
                  color: isDark ? NsColorsDark.border : NsColorsLight.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: NsSpacing.xs),
                shrinkWrap: true,
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  final isSelected = widget.value == option.value;

                  return _SelectOptionItem<T>(
                    option: option,
                    isSelected: isSelected,
                    onTap: () {
                      widget.onChanged?.call(option.value);
                      _hideDropdown();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isFocused = false);
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  Color _getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isFocused) {
      return isDark ? NsColorsDark.ring : NsColorsLight.ring;
    }

    if (_isHovered && widget.enabled) {
      return _darken(
        isDark ? NsColorsDark.border : NsColorsLight.border,
        0.1,
      );
    }

    return isDark ? NsColorsDark.border : NsColorsLight.border;
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: NsTextStyles.bodyMedium(context).copyWith(
                fontWeight: NsFontWeights.medium,
              ),
            ),
            const SizedBox(height: NsSpacing.sm),
          ],
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: NsSpacing.inputPaddingHorizontal,
                  vertical: NsSpacing.inputPaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? (isDark ? NsColorsDark.background : NsColorsLight.background)
                      : (isDark ? NsColorsDark.muted : NsColorsLight.muted),
                  borderRadius: NsRadius.input,
                  border: Border.all(
                    color: _getBorderColor(context),
                    width: _isFocused ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _displayText,
                        style: NsTextStyles.bodyMedium(context).copyWith(
                          color: widget.value == null
                              ? (isDark
                                  ? NsColorsDark.mutedForeground
                                  : NsColorsLight.mutedForeground)
                              : (widget.enabled
                                  ? (isDark ? NsColorsDark.foreground : NsColorsLight.foreground)
                                  : (isDark
                                      ? NsColorsDark.mutedForeground
                                      : NsColorsLight.mutedForeground)),
                        ),
                      ),
                    ),
                    Icon(
                      _isFocused ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectOptionItem<T> extends StatefulWidget {
  final NsSelectOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectOptionItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SelectOptionItem<T>> createState() => _SelectOptionItemState<T>();
}

class _SelectOptionItemState<T> extends State<_SelectOptionItem<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NsSpacing.md,
            vertical: NsSpacing.sm,
          ),
          color: _isHovered || widget.isSelected
              ? (isDark ? NsColorsDark.hover : NsColorsLight.hover)
              : Colors.transparent,
          child: Row(
            children: [
              if (widget.option.icon != null) ...[
                widget.option.icon!,
                const SizedBox(width: NsSpacing.sm),
              ],
              Expanded(
                child: Text(
                  widget.option.label,
                  style: NsTextStyles.bodyMedium(context).copyWith(
                    fontWeight: widget.isSelected ? NsFontWeights.medium : NsFontWeights.regular,
                  ),
                ),
              ),
              if (widget.isSelected)
                Icon(
                  Icons.check,
                  size: 16,
                  color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
