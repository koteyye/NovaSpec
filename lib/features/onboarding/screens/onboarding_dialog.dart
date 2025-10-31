import 'package:flutter/material.dart';
import '../../../shared/widgets/modern_button.dart';

class OnboardingDialog extends StatefulWidget {
  final VoidCallback onCreateProject;
  final VoidCallback onOpenProject;
  final VoidCallback onCancel;

  const OnboardingDialog({
    super.key,
    required this.onCreateProject,
    required this.onOpenProject,
    required this.onCancel,
  });

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Добро пожаловать в NovaSpec',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Выберите действие для начала работы',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Создать новый проект',
                onPressed: widget.onCreateProject,
                type: ButtonType.primary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Открыть существующий проект',
                onPressed: widget.onOpenProject,
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ModernButton(
                text: 'Отмена',
                onPressed: widget.onCancel,
                type: ButtonType.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Convenience method to show the onboarding dialog
Future<void> showOnboardingDialog({
  required BuildContext context,
  required VoidCallback onCreateProject,
  required VoidCallback onOpenProject,
  required VoidCallback onCancel,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => OnboardingDialog(
      onCreateProject: onCreateProject,
      onOpenProject: onOpenProject,
      onCancel: onCancel,
    ),
  );
}
