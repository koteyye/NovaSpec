import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../shared/widgets/modern_button.dart';

enum OnboardingStep {
  project,
  newProjectSetup,
  settings,
}

class OnboardingDialogRefactored extends StatefulWidget {
  final VoidCallback onCreateProject;
  final VoidCallback onOpenProject;
  final VoidCallback onCancel;

  const OnboardingDialogRefactored({
    super.key,
    required this.onCreateProject,
    required this.onOpenProject,
    required this.onCancel,
  });

  @override
  State<OnboardingDialogRefactored> createState() => _OnboardingDialogRefactoredState();
}

class _OnboardingDialogRefactoredState extends State<OnboardingDialogRefactored> {
  OnboardingStep _currentStep = OnboardingStep.project;
  String _projectName = '';
  String _projectPath = '';
  
  @override
  void initState() {
    super.initState();
    _currentStep = OnboardingStep.project;
    _projectName = '';
    _projectPath = '';
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: _buildContent(context),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    String title;
    String description;

    switch (_currentStep) {
      case OnboardingStep.project:
        title = 'Добро пожаловать в NovaSpec';
        description = 'Создайте новый проект или откройте существующий, чтобы начать работу';
        break;
      case OnboardingStep.newProjectSetup:
        title = 'Создание нового проекта';
        description = 'Укажите имя проекта и выберите папку для сохранения';
        break;
      case OnboardingStep.settings:
        title = 'Настройка ИИ и интеграций';
        description = 'Настройте AI-провайдера и интеграции для полноценной работы с приложением';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_currentStep) {
      case OnboardingStep.project:
        return _buildProjectStep(context);
      case OnboardingStep.newProjectSetup:
        return _buildNewProjectSetupStep(context);
      case OnboardingStep.settings:
        return _buildSettingsStep(context);
    }
  }

  Widget _buildProjectStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ModernButton(
            text: 'Создать новый проект',
            onPressed: _handleCreateNew,
            type: ButtonType.secondary,
            fullWidth: true,
            height: 96,
            icon: Icons.description,

          ),
          const SizedBox(height: 16),
          ModernButton(
            text: 'Открыть существующий проект',
            onPressed: _handleOpenExisting,
            type: ButtonType.secondary,
            fullWidth: true,
            height: 96,
            icon: Icons.folder_open,

          ),
        ],
      ),
    );
  }

  Widget _buildNewProjectSetupStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Имя проекта',
              hintText: 'Мой проект',
              border: OutlineInputBorder(),
            ),
            initialValue: _projectName,
            onChanged: (value) => _projectName = value,
          ),
          const SizedBox(height: 16),
          const Text(
            'Путь к папке',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Выберите папку...',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(text: _projectPath),
                ),
              ),
              const SizedBox(width: 8),
              ModernButton(
                text: 'Обзор',
                onPressed: _handleBrowseFolder,
                type: ButtonType.secondary,
                icon: Icons.folder,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Вы можете настроить параметры прямо сейчас или сделать это позже в настройках приложения.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    switch (_currentStep) {
      case OnboardingStep.project:
        return const SizedBox.shrink();
      case OnboardingStep.newProjectSetup:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              ModernButton(
                text: 'Назад',
                onPressed: () => setState(() => _currentStep = OnboardingStep.project),
                type: ButtonType.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernButton(
                  text: 'Продолжить',
                  onPressed: _projectName.isNotEmpty && _projectPath.isNotEmpty
                      ? _handleContinueToSettings
                      : null,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        );
      case OnboardingStep.settings:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              ModernButton(
                text: 'Пропустить',
                onPressed: _handleSkip,
                type: ButtonType.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModernButton(
                  text: 'Настроить',
                  onPressed: _handleConfigure,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        );
    }
  }

  void _handleCreateNew() {
    Navigator.of(context).pop();
    widget.onCreateProject();
  }

  void _handleOpenExisting() {
    Navigator.of(context).pop();
    widget.onOpenProject();
  }

  void _handleBrowseFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() => _projectPath = selectedDirectory);
    }
  }

  void _handleContinueToSettings() {
    setState(() => _currentStep = OnboardingStep.settings);
  }

  void _handleSkip() {
    Navigator.of(context).pop();
    widget.onCancel();
  }

  void _handleConfigure() {
    Navigator.of(context).pop();
    widget.onCancel();
  }

  
}