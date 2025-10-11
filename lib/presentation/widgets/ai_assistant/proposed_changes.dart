import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';

/// Тип изменения в файле
enum ChangeType {
  deletion, // Удаление (красный)
  modification, // Изменение (желтый)
  addition, // Добавление (зеленый)
}

/// Модель изменения в файле
class FileChange {
  final String filePath;
  final List<DiffLine> diffLines;

  const FileChange({
    required this.filePath,
    required this.diffLines,
  });
}

/// Строка diff
class DiffLine {
  final ChangeType type;
  final String content;
  final int? lineNumber;

  const DiffLine({
    required this.type,
    required this.content,
    this.lineNumber,
  });
}

/// Виджет для отображения предложенных AI изменений
class ProposedChanges extends StatelessWidget {
  final FileChange change;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const ProposedChanges({
    super.key,
    required this.change,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: NsSpacing.md,
        vertical: NsSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.muted : NsColorsLight.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? NsColorsDark.border : NsColorsLight.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(NsSpacing.md),
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
                  Icons.edit_note_outlined,
                  size: 20,
                  color: isDark
                      ? NsColorsDark.primary
                      : NsColorsLight.primary,
                ),
                const SizedBox(width: NsSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Предложенные изменения',
                        style: NsTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: NsSpacing.xs),
                      Text(
                        change.filePath,
                        style: NsTextStyles.bodySmall(context).copyWith(
                          color: isDark
                              ? NsColorsDark.mutedForeground
                              : NsColorsLight.mutedForeground,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Diff content
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(NsSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: change.diffLines.map((line) {
                  return _buildDiffLine(context, isDark, line);
                }).toList(),
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(NsSpacing.md),
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
                  text: 'Отклонить',
                  onPressed: onReject,
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.small,
                ),
                const SizedBox(width: NsSpacing.sm),
                NsButton(
                  text: 'Принять',
                  onPressed: onAccept,
                  size: ButtonSize.small,
                  icon: Icon(Icons.check, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffLine(BuildContext context, bool isDark, DiffLine line) {
    Color? backgroundColor;
    Color? borderColor;
    String prefix;

    switch (line.type) {
      case ChangeType.deletion:
        backgroundColor = (isDark
                ? NsColorsDark.destructive
                : NsColorsLight.destructive)
            .withValues(alpha: 0.1);
        borderColor = isDark
            ? NsColorsDark.destructive
            : NsColorsLight.destructive;
        prefix = '-';
        break;
      case ChangeType.modification:
        backgroundColor = const Color(0xFFFFA500).withValues(alpha: 0.1); // Orange
        borderColor = const Color(0xFFFFA500);
        prefix = '~';
        break;
      case ChangeType.addition:
        backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1); // Green
        borderColor = const Color(0xFF10B981);
        prefix = '+';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: NsSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line number
          if (line.lineNumber != null) ...[
            SizedBox(
              width: 40,
              child: Text(
                line.lineNumber.toString(),
                style: NsTextStyles.bodySmall(context).copyWith(
                  fontFamily: 'monospace',
                  color: isDark
                      ? NsColorsDark.mutedForeground
                      : NsColorsLight.mutedForeground,
                ),
              ),
            ),
          ],

          // Prefix
          Text(
            '$prefix ',
            style: NsTextStyles.bodySmall(context).copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: borderColor,
            ),
          ),

          // Content
          Expanded(
            child: Text(
              line.content,
              style: NsTextStyles.bodySmall(context).copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
