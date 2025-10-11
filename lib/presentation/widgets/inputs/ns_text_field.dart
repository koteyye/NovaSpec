import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';

/// Компонент текстового поля для NovaSpec
class NsTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const NsTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
            ),
          ),
          const SizedBox(height: NsSpacing.sm),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onTap: onTap,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
            ),
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark ? NsColorsDark.input : NsColorsLight.input,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: NsSpacing.md,
              vertical: NsSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.border : NsColorsLight.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.border : NsColorsLight.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.ring : NsColorsLight.ring,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.destructive : NsColorsLight.destructive,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.destructive : NsColorsLight.destructive,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: (isDark ? NsColorsDark.border : NsColorsLight.border).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
