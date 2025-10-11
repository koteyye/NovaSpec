import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';

/// Переключатель (toggle) NovaSpec
class NsSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const NsSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<NsSwitch> createState() => _NsSwitchState();
}

class _NsSwitchState extends State<NsSwitch> {
  bool _isHovered = false;

  void _handleTap() {
    if (widget.enabled && widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  Color _getTrackColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!widget.enabled) {
      return (widget.value
              ? (isDark ? NsColorsDark.primary : NsColorsLight.primary)
              : (isDark ? NsColorsDark.input : NsColorsLight.input))
          .withValues(alpha: 0.5);
    }

    if (widget.value) {
      return isDark ? NsColorsDark.primary : NsColorsLight.primary;
    }

    return isDark ? NsColorsDark.input : NsColorsLight.input;
  }

  Color _getThumbColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.value) {
      return isDark ? NsColorsDark.primaryForeground : NsColorsLight.primaryForeground;
    }

    return isDark ? NsColorsDark.foreground : NsColorsLight.foreground;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            color: _getTrackColor(context),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                left: widget.value ? 22 : 2,
                top: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getThumbColor(context),
                    shape: BoxShape.circle,
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
