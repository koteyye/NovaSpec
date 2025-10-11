import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';
import 'package:novaspec/presentation/widgets/inputs/ns_text_field.dart';
import 'package:novaspec/presentation/widgets/cards/ns_card.dart';
import 'dart:io';

/// Диалог онбординга с 3 этапами
class OnboardingDialog extends ConsumerStatefulWidget {
  const OnboardingDialog({super.key});

  @override
  ConsumerState<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends ConsumerState<OnboardingDialog> {
  int _currentStep = 0;
  String? _selectedProjectPath;
  String? _selectedProjectName;

  // AI Provider fields
  final _aiProviderController = TextEditingController(text: 'anthropic');
  final _aiBaseUrlController = TextEditingController();
  final _aiTokenController = TextEditingController();
  final _aiModelController = TextEditingController(text: 'claude-3-5-sonnet-20241022');

  @override
  void dispose() {
    _aiProviderController.dispose();
    _aiBaseUrlController.dispose();
    _aiTokenController.dispose();
    _aiModelController.dispose();
    super.dispose();
  }

  Future<void> _pickExistingProject() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      setState(() {
        _selectedProjectPath = selectedDirectory;
        _selectedProjectName = dir.uri.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
          orElse: () => 'Project',
        );
      });

      // Сразу переходим к следующему шагу
      setState(() {
        _currentStep = 2;
      });
    }
  }

  Future<void> _createNewProject() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      setState(() {
        _selectedProjectPath = selectedDirectory;
        _selectedProjectName = dir.uri.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
          orElse: () => 'New Project',
        );
      });

      // Создаем структуру папок для нового проекта
      try {
        await Directory('$selectedDirectory/specs').create(recursive: true);
        await Directory('$selectedDirectory/.novaspec').create(recursive: true);

        // Переходим к следующему шагу
        setState(() {
          _currentStep = 2;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating project: $e')),
          );
        }
      }
    }
  }

  Future<void> _completeOnboarding() async {
    if (_selectedProjectPath == null || _selectedProjectName == null) {
      return;
    }

    final repository = ConfigRepository(HiveDataSource());

    try {
      // Сохраняем проект
      await repository.updateCurrentProject(
        path: _selectedProjectPath!,
        name: _selectedProjectName!,
      );

      // Сохраняем AI провайдер
      await repository.updateAIProvider(
        provider: _aiProviderController.text,
        baseUrl: _aiBaseUrlController.text.isEmpty ? null : _aiBaseUrlController.text,
        token: _aiTokenController.text.isEmpty ? null : _aiTokenController.text,
        model: _aiModelController.text,
      );

      if (mounted) {
        // Закрываем диалог и переходим на главный экран
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving configuration: $e')),
        );
      }
    }
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentStep;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? NsColorsDark.primary : NsColorsLight.primary)
                : (isDark ? NsColorsDark.border : NsColorsLight.border),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome to NovaSpec',
          style: NsTextStyles.h1(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NsSpacing.md),
        Text(
          'Choose how to get started',
          style: NsTextStyles.bodyLarge(context).copyWith(
            color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NsSpacing.xl),
        NsCard(
          onTap: _pickExistingProject,
          child: Padding(
            padding: const EdgeInsets.all(NsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open Existing Project', style: NsTextStyles.h3(context)),
                const SizedBox(height: NsSpacing.sm),
                Text(
                  'Select a folder with your existing specifications',
                  style: NsTextStyles.bodyMedium(context).copyWith(
                    color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NsSpacing.md),
        NsCard(
          onTap: _createNewProject,
          child: Padding(
            padding: const EdgeInsets.all(NsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create New Project', style: NsTextStyles.h3(context)),
                const SizedBox(height: NsSpacing.sm),
                Text(
                  'Start a new project from scratch',
                  style: NsTextStyles.bodyMedium(context).copyWith(
                    color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Project Selected',
          style: NsTextStyles.h1(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NsSpacing.xl),
        NsCard(
          child: Padding(
            padding: const EdgeInsets.all(NsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project Name', style: NsTextStyles.bodySmall(context).copyWith(
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                )),
                const SizedBox(height: NsSpacing.xs),
                Text(_selectedProjectName ?? '', style: NsTextStyles.h3(context)),
                const SizedBox(height: NsSpacing.md),
                Text('Project Path', style: NsTextStyles.bodySmall(context).copyWith(
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                )),
                const SizedBox(height: NsSpacing.xs),
                Text(
                  _selectedProjectPath ?? '',
                  style: NsTextStyles.bodyMedium(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: NsSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NsButton(
              text: 'Back',
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                  _selectedProjectPath = null;
                  _selectedProjectName = null;
                });
              },
              variant: ButtonVariant.secondary,
            ),
            NsButton(
              text: 'Continue',
              onPressed: () {
                setState(() {
                  _currentStep = 2;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'AI Configuration',
          style: NsTextStyles.h1(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NsSpacing.md),
        Text(
          'Configure your AI provider settings',
          style: NsTextStyles.bodyMedium(context).copyWith(
            color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: NsSpacing.xl),
        NsTextField(
          controller: _aiProviderController,
          label: 'Provider',
          hint: 'anthropic, openai, etc.',
        ),
        const SizedBox(height: NsSpacing.md),
        NsTextField(
          controller: _aiBaseUrlController,
          label: 'Base URL (optional)',
          hint: 'https://api.anthropic.com',
        ),
        const SizedBox(height: NsSpacing.md),
        NsTextField(
          controller: _aiTokenController,
          label: 'API Token',
          hint: 'Enter your API token',
          obscureText: true,
        ),
        const SizedBox(height: NsSpacing.md),
        NsTextField(
          controller: _aiModelController,
          label: 'Model',
          hint: 'claude-3-5-sonnet-20241022',
        ),
        const SizedBox(height: NsSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NsButton(
              text: 'Back',
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              variant: ButtonVariant.secondary,
            ),
            NsButton(
              text: 'Complete',
              onPressed: _completeOnboarding,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(NsSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepIndicator(),
              const SizedBox(height: NsSpacing.xl),
              Flexible(
                child: SingleChildScrollView(
                  child: _currentStep == 0
                      ? _buildStep1()
                      : _currentStep == 1
                          ? _buildStep2()
                          : _buildStep3(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
