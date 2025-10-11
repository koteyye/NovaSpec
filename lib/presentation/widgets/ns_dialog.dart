import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Модальное диалоговое окно NovaSpec
class NsDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? content;
  final List<Widget>? actions;
  final bool dismissible;
  final double? maxWidth;

  const NsDialog({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions,
    this.dismissible = true,
    this.maxWidth,
  });

  /// Показать диалог
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? description,
    Widget? content,
    List<Widget>? actions,
    bool dismissible = true,
    double? maxWidth,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => NsDialog(
        title: title,
        description: description,
        content: content,
        actions: actions,
        dismissible: dismissible,
        maxWidth: maxWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 500,
        ),
        decoration: BoxDecoration(
          color: isDark ? NsColorsDark.card : NsColorsLight.card,
          borderRadius: NsRadius.dialog,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            if (title != null || description != null)
              Padding(
                padding: const EdgeInsets.all(NsSpacing.dialogPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: NsTextStyles.h3(context),
                      ),
                    if (description != null) ...[
                      const SizedBox(height: NsSpacing.sm),
                      Text(
                        description!,
                        style: NsTextStyles.bodyMedium(context).copyWith(
                          color: isDark
                              ? NsColorsDark.mutedForeground
                              : NsColorsLight.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Content
            if (content != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: NsSpacing.dialogPadding,
                    vertical: title != null || description != null ? 0 : NsSpacing.dialogPadding,
                  ),
                  child: content!,
                ),
              ),

            // Actions
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(NsSpacing.dialogPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      actions![i],
                      if (i < actions!.length - 1) const SizedBox(width: NsSpacing.sm),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
