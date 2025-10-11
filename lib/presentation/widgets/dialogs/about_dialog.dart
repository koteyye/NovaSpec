import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';

/// Диалог "О программе"
class NsAboutDialog extends StatelessWidget {
  const NsAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        child: Padding(
          padding: const EdgeInsets.all(NsSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: NsSpacing.lg),

              // App name
              Text(
                'NovaSpec',
                style: NsTextStyles.h1(context),
              ),
              const SizedBox(height: NsSpacing.sm),

              // Version
              Text(
                'Version 1.0.0',
                style: NsTextStyles.bodyMedium(context).copyWith(
                  color: isDark
                      ? NsColorsDark.mutedForeground
                      : NsColorsLight.mutedForeground,
                ),
              ),
              const SizedBox(height: NsSpacing.xl),

              // Description
              Text(
                'AI-powered collaborative technical specification editor for Windows and macOS',
                style: NsTextStyles.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NsSpacing.lg),

              // Features
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeature(context, 'AI Assistant', 'Integrated AI for specification writing'),
                      _buildFeature(context, 'Confluence Integration', 'Direct export to Confluence'),
                      _buildFeature(context, 'Template System', 'Customizable specification templates'),
                      _buildFeature(context, 'Background Music', 'Focus-enhancing ambient music'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: NsSpacing.lg),

              // Creator info
              Text(
                'Создано командой NovaSpec',
                style: NsTextStyles.bodySmall(context).copyWith(
                  color: isDark
                      ? NsColorsDark.mutedForeground
                      : NsColorsLight.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NsSpacing.md),

              // Close button
              NsButton(
                text: 'Закрыть',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: NsSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
          ),
          const SizedBox(width: NsSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NsTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: NsTextStyles.bodySmall(context).copyWith(
                    color: isDark
                        ? NsColorsDark.mutedForeground
                        : NsColorsLight.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
