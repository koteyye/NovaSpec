import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';

import '../../features/project/providers/project_provider.dart';
import '../../core/services/project_service.dart';
import '../../core/services/toast_service.dart';
import '../../features/onboarding/screens/onboarding_dialog.dart';
import '../../features/topbar/widgets/top_bar.dart';
import '../../features/topbar/widgets/status_bar.dart';
import '../../features/settings/widgets/settings_dialog.dart';
import '../../features/workspace/screens/workspace_screen.dart';
import '../../shared/widgets/modern_button.dart';
import '../../shared/services/di_container.dart';
import '../../features/musication/services/tray_manager_service.dart';
import 'dart:io';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showOnboarding = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMainScreen();
  }

  Future<void> _initializeMainScreen() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );

    // Инициализация TrayManager с локализованными текстами
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          final trayService = getIt<TrayManagerService>();
          trayService.initialize(
            showLabel: l10n.musication_tray_show,
            exitLabel: l10n.musication_tray_exit,
          );
        }
      });
    }

    // Check if this is first run or no last project
    final isFirstRun = appProvider.lastOpenedProject == null;

    if (isFirstRun) {
      setState(() {
        _showOnboarding = true;
      });
    } else {
      // Try to load last project after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _loadLastProject(projectProvider);
      });
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadLastProject(ProjectProvider projectProvider) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final lastProjectPath = appProvider.lastOpenedProject;

    if (lastProjectPath != null) {
      try {
        await projectProvider.openProject(lastProjectPath);
      } catch (e) {
        // If loading fails, show onboarding
        setState(() {
          _showOnboarding = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Загрузка NovaSpec...'),
            ],
          ),
        ),
      );
    }

    return Consumer2<ProjectProvider, SettingsProvider>(
      builder: (context, projectProvider, settingsProvider, child) {
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.comma, control: true):
                _handleOpenSettingsModal,
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                _handleNewProject,
            const SingleActivator(LogicalKeyboardKey.keyO, control: true):
                _handleOpenProject,
            const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
                _handleSaveProject(),
            const SingleActivator(
              LogicalKeyboardKey.keyS,
              control: true,
              shift: true,
            ): _handleSaveProjectAs,
            const SingleActivator(LogicalKeyboardKey.keyQ, control: true): () =>
                _handleExit(),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              // Top bar for Windows/Linux
              appBar: _buildAppBar(context, projectProvider, settingsProvider),

              // Body
              body: Column(
                children: [
                  // Main content area
                  Expanded(child: _buildMainContent(context, projectProvider)),

                  // Status bar
                  StatusBar(
                    projectProvider: projectProvider,
                    showProgress: projectProvider.isLoading,
                    progressMessage: projectProvider.isLoading
                        ? 'Загрузка...'
                        : null,
                  ),
                ],
              ),

              // Floating action button for debug
              floatingActionButton: kDebugMode
                  ? _buildDebugButton(projectProvider)
                  : null,
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ProjectProvider projectProvider,
    SettingsProvider settingsProvider,
  ) {
    // For macOS, we might want to use system menu bar
    // For now, we'll use custom top bar for all platforms

    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: TopBar(
        projectProvider: projectProvider,
        settingsProvider: settingsProvider,
        onNewProject: _handleNewProject,
        onOpenProject: _handleOpenProject,
        onSaveProject: _handleSaveProject,
        onSaveProjectAs: _handleSaveProjectAs,
        onExit: _handleExit,
        onOpenTemplates: _handleOpenTemplates,
        onOpenAbout: _handleOpenAbout,
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    ProjectProvider projectProvider,
  ) {
    if (_showOnboarding) {
      // Show onboarding using proper modal dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOnboardingDialog();
      });
      // Использовать фон из темы вместо пустого контейнера
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!projectProvider.hasActiveProject) {
      return _buildEmptyState(context);
    }

    return _buildWorkspace(context, projectProvider);
  }

  void _showOnboardingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => OnboardingDialog(
        onCreateProject: _handleCreateProject,
        onOpenProject: _handleOpenProject,
        onCancel: _handleCancelOnboarding,
      ),
    ).then((_) {
      // Dialog closed, update state
      if (mounted) {
        setState(() {
          _showOnboarding = false;
        });
      }
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noOpenProject,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.workspaceComingSoon,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ModernButton(
                  text: 'Новый проект',
                  onPressed: _handleNewProject,
                  type: ButtonType.primary,
                  icon: Icons.add_circle_outline,
                ),
                const SizedBox(width: 16),
                ModernButton(
                  text: 'Открыть проект',
                  onPressed: _handleOpenProject,
                  type: ButtonType.secondary,
                  icon: Icons.folder_open_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspace(
    BuildContext context,
    ProjectProvider projectProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project header
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectProvider.projectDisplayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Workspace content - ИНТЕГРИРУЕМ WorkspaceScreen ЗДЕСЬ
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const WorkspaceScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton(ProjectProvider projectProvider) {
    return FloatingActionButton(
      mini: true,
      onPressed: () => _showDebugMenu(projectProvider),
      backgroundColor: Colors.orange,
      child: const Icon(Icons.bug_report, color: Colors.white),
    );
  }

  void _showDebugMenu(ProjectProvider projectProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernButton(
              text: 'Показать онбординг',
              onPressed: () {
                Navigator.of(context).pop();
                _showOnboardingDialog();
              },
              type: ButtonType.primary,
            ),
            const SizedBox(height: 8),
            ModernButton(
              text: 'Создать пустой проект',
              onPressed: () {
                Navigator.of(context).pop();
                projectProvider.createEmptyProject();
              },
              type: ButtonType.secondary,
            ),
            const SizedBox(height: 8),
            ModernButton(
              text: 'Закрыть проект',
              onPressed: () {
                Navigator.of(context).pop();
                projectProvider.closeProject();
              },
              type: ButtonType.secondary,
            ),
            const SizedBox(height: 16),
            // Mock gen-api.ru settings
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: settingsProvider.mockGenApiEnabled,
                          onChanged: (value) {
                            debugPrint('🔧 Debug Menu: Setting mockGenApiEnabled to $value');
                            settingsProvider.setMockGenApiEnabled(value ?? false);
                            debugPrint('🔧 Debug Menu: mockGenApiEnabled is now ${settingsProvider.mockGenApiEnabled}');
                          },
                        ),
                        const Text('Мок gen-api.ru'),
                      ],
                    ),
                    if (settingsProvider.mockGenApiEnabled) ...[
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'URL мока',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        controller: TextEditingController(
                          text: settingsProvider.mockGenApiUrl,
                        ),
                        onChanged: (value) {
                          debugPrint('🔧 Debug Menu: Setting mockGenApiUrl to $value');
                          settingsProvider.setMockGenApiUrl(value);
                          debugPrint('🔧 Debug Menu: mockGenApiUrl is now ${settingsProvider.mockGenApiUrl}');
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _handleOpenSettingsModal() {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(settingsProvider: settingsProvider),
    );
  }

  void _handleOpenAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О NovaSpec'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NovaSpec - Flutter/Dart версия приложения для создания технических заданий с ИИ-ассистентом.',
            ),
            SizedBox(height: 16),
            Text('Версия: 1.0.0'),
            Text('Технологии: Flutter 3.x, Dart 3.x'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _handleOpenTemplates() {
    show(description: 'Templates will be available soon');
  }

  void _handleCreateProject() {
    // Close onboarding dialog if it's open and reset state
    if (_showOnboarding) {
      Navigator.of(context).pop();
      setState(() {
        _showOnboarding = false;
      });
    }
    _showCreateProjectDialog();
  }

  void _handleOpenProject() async {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    
    // Close onboarding dialog if it's open and reset state
    if (_showOnboarding) {
      Navigator.of(context).pop();
      setState(() {
        _showOnboarding = false;
      });
    }

    try {
      // Use project provider to open project
      await projectProvider.openProject(null);

      // Show success message
      if (mounted && projectProvider.currentProject != null) {
        success(
          description:
              'Проект "${projectProvider.currentProject!.name}" успешно открыт',
        );
      }
    } catch (e) {
      // Show error using the current context
      if (mounted) {
        error(description: 'Ошибка при открытии проекта: $e');
      }
    }
  }

  void _handleCancelOnboarding() {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    Navigator.of(context).pop(); // Close onboarding dialog first
    
    setState(() {
      _showOnboarding = false;
    });

    projectProvider.createEmptyProject();
  }

  void _handleNewProject() {
    _showCreateProjectDialog();
  }

  void _handleSaveProject() async {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    await projectProvider.saveProject();
  }

  void _handleSaveProjectAs() async {
    _showSaveProjectAsDialog();
  }

  void _handleExit() {
    // Handle application exit
    Navigator.of(context).pop();
  }

  void _showCreateProjectDialog() {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) =>
          _CreateProjectDialog(projectProvider: projectProvider),
    );
  }

  void _showSaveProjectAsDialog() {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (context) =>
          _SaveProjectAsDialog(projectProvider: projectProvider),
    );
  }
}

class _CreateProjectDialog extends StatefulWidget {
  final ProjectProvider projectProvider;

  const _CreateProjectDialog({required this.projectProvider});

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _nameController = TextEditingController();
  final _directoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _directoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать новый проект'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя проекта',
                hintText: 'Введите имя проекта',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _directoryController,
              decoration: const InputDecoration(
                labelText: 'Директория',
                hintText: 'Выберите директорию для проекта',
                suffixIcon: Icon(Icons.folder_open),
              ),
              readOnly: true,
              onTap: _selectDirectory,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ModernButton(
          text: 'Создать',
          onPressed: _isLoading ? null : _createProject,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _selectDirectory() async {
    final projectService = ProjectService();
    final directory = await projectService.pickDirectory();

    if (directory != null) {
      setState(() {
        _directoryController.text = directory;
      });
    }
  }

  Future<void> _createProject() async {
    if (_nameController.text.trim().isEmpty) {
      error(description: 'Введите имя проекта');
      return;
    }

    if (_directoryController.text.trim().isEmpty) {
      error(description: 'Выберите директорию');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.projectProvider.createProject(
        name: _nameController.text.trim(),
        directory: _directoryController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        success(description: 'Проект "${_nameController.text}" создан');
      }
    } catch (e) {
      if (mounted) {
        error(description: 'Ошибка создания проекта: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _SaveProjectAsDialog extends StatefulWidget {
  final ProjectProvider projectProvider;

  const _SaveProjectAsDialog({required this.projectProvider});

  @override
  State<_SaveProjectAsDialog> createState() => _SaveProjectAsDialogState();
}

class _SaveProjectAsDialogState extends State<_SaveProjectAsDialog> {
  final _nameController = TextEditingController();
  final _directoryController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _directoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Сохранить проект как'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя проекта',
                hintText: 'Введите новое имя проекта',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _directoryController,
              decoration: const InputDecoration(
                labelText: 'Директория',
                hintText: 'Выберите директорию для проекта',
                suffixIcon: Icon(Icons.folder_open),
              ),
              readOnly: true,
              onTap: _selectDirectory,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ModernButton(
          text: 'Сохранить',
          onPressed: _isLoading ? null : _saveProjectAs,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _selectDirectory() async {
    final projectService = ProjectService();
    final directory = await projectService.pickDirectory();

    if (directory != null) {
      setState(() {
        _directoryController.text = directory;
      });
    }
  }

  Future<void> _saveProjectAs() async {
    if (_nameController.text.trim().isEmpty) {
      error(description: 'Введите имя проекта');
      return;
    }

    if (_directoryController.text.trim().isEmpty) {
      error(description: 'Выберите директорию');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.projectProvider.saveProjectAs();

      if (mounted) {
        Navigator.of(context).pop();
        success(description: 'Проект сохранен как "${_nameController.text}"');
      }
    } catch (e) {
      if (mounted) {
        error(description: 'Ошибка сохранения проекта: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
