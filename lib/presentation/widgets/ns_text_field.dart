import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Поле ввода текста NovaSpec
class NsTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const NsTextField({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.focusNode,
  });

  @override
  State<NsTextField> createState() => _NsTextFieldState();
}

class _NsTextFieldState extends State<NsTextField> {
  bool _isFocused = false;
  bool _isHovered = false;
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  Color _getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.errorText != null) {
      return isDark ? NsColorsDark.destructive : NsColorsLight.destructive;
    }

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
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: NsRadius.input,
              border: Border.all(
                color: _getBorderColor(context),
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _internalFocusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              readOnly: widget.readOnly,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              style: NsTextStyles.bodyMedium(context).copyWith(
                color: widget.enabled
                    ? (isDark ? NsColorsDark.foreground : NsColorsLight.foreground)
                    : (isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground),
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: NsTextStyles.bodyMedium(context).copyWith(
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                filled: true,
                fillColor: widget.enabled
                    ? (isDark ? NsColorsDark.background : NsColorsLight.background)
                    : (isDark ? NsColorsDark.muted : NsColorsLight.muted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: NsSpacing.inputPaddingHorizontal,
                  vertical: NsSpacing.inputPaddingVertical,
                ),
              ),
            ),
          ),
          if (widget.helperText != null || widget.errorText != null) ...[
            const SizedBox(height: NsSpacing.xs),
            Text(
              widget.errorText ?? widget.helperText!,
              style: NsTextStyles.bodySmall(context).copyWith(
                color: widget.errorText != null
                    ? (isDark ? NsColorsDark.destructive : NsColorsLight.destructive)
                    : (isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
