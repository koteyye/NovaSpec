import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/widgets/modern_button.dart';
import 'settings_dialog_content.dart';

class SettingsDialog extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const SettingsDialog({super.key, required this.settingsProvider});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  void initState() {
    super.initState();

    // Initialize settings provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.settingsProvider.initialize().catchError((e) {
        // Handle error silently or log through proper logging service
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Параметры',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListenableBuilder(
                listenable: widget.settingsProvider,
                builder: (context, child) {
                  if (widget.settingsProvider.hasError) {
                    return _buildErrorView(widget.settingsProvider);
                  }

                  if (widget.settingsProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Проверяем создание SettingsDialogContent
                  try {
                    return SettingsDialogContent(settingsProvider: widget.settingsProvider);
                  } catch (e) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text('Ошибка в SettingsDialogContent: $e'),
                      ),
                    );
                  }
                },
              ),
            ),

            // Footer with buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: ListenableBuilder(
                listenable: widget.settingsProvider,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ModernButton(
                        text: 'Проверить',
                        onPressed: widget.settingsProvider.isLoading ? null : () => _validateSettings(context),
                        type: ButtonType.secondary,
                        isLoading: widget.settingsProvider.isLoading,
                      ),
                      const SizedBox(width: 8),
                      ModernButton(
                        text: 'Сохранить',
                        onPressed: widget.settingsProvider.isLoading ? null : () => _saveSettings(context),
                        type: ButtonType.primary,
                        isLoading: widget.settingsProvider.isLoading,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(SettingsProvider settings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки настроек',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              settings.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ModernButton(
              text: 'Повторить',
              onPressed: () {
                settings.clearError();
                settings.initialize();
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _validateSettings(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.validateCurrentProvider();

    if (settings.errorMessage == null) {
      success(description: 'Проверка завершена успешно');
    } else {
      error(description: 'Ошибка проверки: ${settings.errorMessage}');
    }
  }

  void _saveSettings(BuildContext context) async {
    final navigator = Navigator.of(context);

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.saveSettings();

    if (settings.errorMessage == null) {
      success(description: 'Настройки успешно сохранены');
    } else {
      error(description: 'Ошибка сохранения: ${settings.errorMessage}');
    }

    if (mounted) {
      navigator.pop();
    }
  }
}
