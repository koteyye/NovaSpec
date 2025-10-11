import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';

/// Диалог подтверждения музикации
class MusicifyDialog extends StatelessWidget {
  final String fileName;
  final int estimatedCost;

  const MusicifyDialog({
    super.key,
    required this.fileName,
    this.estimatedCost = 17,
  });

  /// Показать диалог музикации
  static Future<bool?> show(
    BuildContext context, {
    required String fileName,
    int estimatedCost = 17,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => MusicifyDialog(
        fileName: fileName,
        estimatedCost: estimatedCost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(NsSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? NsColorsDark.border : NsColorsLight.border,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.music_note,
                    color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                    size: 24,
                  ),
                  const SizedBox(width: NsSpacing.md),
                  Expanded(
                    child: Text(
                      'Музикация документа',
                      style: NsTextStyles.h3(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(NsSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main message
                  Text(
                    'Вы уверены, что хотите создать музыкальное сопровождение для документа?',
                    style: NsTextStyles.bodyMedium(context),
                  ),
                  const SizedBox(height: NsSpacing.md),

                  // File name
                  Container(
                    padding: const EdgeInsets.all(NsSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? NsColorsDark.muted : NsColorsLight.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
                        ),
                        const SizedBox(width: NsSpacing.sm),
                        Expanded(
                          child: Text(
                            fileName,
                            style: NsTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: NsSpacing.lg),

                  // Warning
                  Container(
                    padding: const EdgeInsets.all(NsSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.orange.shade700,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: NsSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Важная информация',
                                style: NsTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: NsSpacing.xs),
                              Text(
                                'Генерация музыки займет несколько минут и будет стоить приблизительно $estimatedCost руб. с вашего баланса Gen-API (Suno).',
                                style: NsTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    text: 'Отмена',
                    onPressed: () => Navigator.of(context).pop(false),
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(width: NsSpacing.md),
                  NsButton(
                    text: 'Да, создать музыку',
                    onPressed: () => Navigator.of(context).pop(true),
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
