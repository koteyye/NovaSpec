import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Компонент выпадающего списка NsSelect
class NsSelect extends StatelessWidget {
  final String label;
  final String value;
  final List<Map<String, String>> items;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const NsSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: NsTextStyles.bodySmall(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: NsSpacing.xs),
        ],

        // Dropdown
        Container(
          decoration: BoxDecoration(
            color: isDark ? NsColorsDark.input : NsColorsLight.input,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? NsColorsDark.border : NsColorsLight.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(
                horizontal: NsSpacing.md,
                vertical: NsSpacing.sm,
              ),
              style: NsTextStyles.bodyMedium(context),
              dropdownColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled
                    ? (isDark ? NsColorsDark.foreground : NsColorsLight.foreground)
                    : (isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value']!,
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: enabled ? (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              } : null,
            ),
          ),
        ),
      ],
    );
  }
}
