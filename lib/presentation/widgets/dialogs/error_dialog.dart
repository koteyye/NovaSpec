import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';

/// Диалог для отображения ошибок
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;

  const ErrorDialog({
    super.key,
    this.title = 'Ошибка',
    required this.message,
    this.details,
  });

  /// Показать диалог ошибки
  static Future<void> show(
    BuildContext context, {
    String? title,
    required String message,
    String? details,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title ?? 'Ошибка',
        message: message,
        details: details,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(NsSpacing.lg),
              decoration: BoxDecoration(
                color: isDark
                    ? NsColorsDark.destructive.withValues(alpha: 0.1)
                    : NsColorsLight.destructive.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? NsColorsDark.border : NsColorsLight.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: isDark ? NsColorsDark.destructive : NsColorsLight.destructive,
                    size: 24,
                  ),
                  const SizedBox(width: NsSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: NsTextStyles.h3(context).copyWith(
                        color: isDark ? NsColorsDark.destructive : NsColorsLight.destructive,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(NsSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Message
                    Text(
                      message,
                      style: NsTextStyles.bodyMedium(context),
                    ),

                    // Details (если есть)
                    if (details != null && details!.isNotEmpty) ...[
                      const SizedBox(height: NsSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Детали:',
                            style: NsTextStyles.bodySmall(context).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            tooltip: 'Копировать детали',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: details!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Детали скопированы в буфер обмена'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: NsSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(NsSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark ? NsColorsDark.muted : NsColorsLight.muted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            details!,
                            style: NsTextStyles.code(context).copyWith(
                              fontSize: 11,
                              color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(NsSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? NsColorsDark.border : NsColorsLight.border,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NsButton(
                    text: 'OK',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
