import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';

/// Статус-бар для отображения информации о процессах
class StatusBar extends StatelessWidget {
  final String? statusMessage;
  final bool isLoading;
  final double? progress;

  const StatusBar({
    super.key,
    this.statusMessage,
    this.isLoading = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.panel : NsColorsLight.panel,
        border: Border(
          top: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          // Статус сообщение
          if (statusMessage != null) ...[
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: NsSpacing.sm),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                left: isLoading ? NsSpacing.xs : NsSpacing.sm,
                right: NsSpacing.sm,
              ),
              child: Text(
                statusMessage!,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                ),
              ),
            ),
          ],

          // Прогресс бар (если есть)
          if (progress != null && progress! > 0 && progress! < 1) ...[
            const SizedBox(width: NsSpacing.sm),
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: isDark ? NsColorsDark.muted : NsColorsLight.muted,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? NsColorsDark.primary : NsColorsLight.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: NsSpacing.xs, right: NsSpacing.sm),
              child: Text(
                '${(progress! * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                ),
              ),
            ),
          ],

          const Spacer(),

          // Правая часть (можно добавить дополнительную информацию)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NsSpacing.sm),
            child: Text(
              'NovaSpec IDE Studio',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
