import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/project_service.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/models/project.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService;
  Timer? _fileMonitorTimer;
  
  Project? _currentProject;
  bool _isLoading = false;
  String? _errorMessage;
  List<Project> _recentProjects = [];
  bool _hasUnsavedChanges = false;
  
  // Global key for showing snack bars
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ProjectProvider(this._projectService) {
    _startFileMonitoring();
  }

  // Getters
  Project? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Project> get recentProjects => List.unmodifiable(_recentProjects);
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get hasActiveProject => _currentProject != null && !_currentProject!.isEmpty;
  String get projectDisplayName => _currentProject?.name ?? 'Без названия';
  String get projectStatus {
    if (_currentProject == null || _currentProject!.isEmpty) {
      return 'Нет проекта';
    } else if (_hasUnsavedChanges) {
      return 'Есть изменения';
    } else {
      return 'Сохранено';
    }
  }

  // Create new project
  Future<void> createProject(String name, String directory) async {
    _setLoading(true);
    _clearError();

    try {
      final project = await _projectService.createProject(name: name, directory: directory);
      await _setCurrentProject(project);
      
      // Add to recent projects
      _addToRecentProjects(project);
      
      _showSuccessMessage('Проект "${project.name}" успешно создан');
    } catch (e) {
      _setError(e.toString());
      _showErrorMessage('Не удалось создать проект: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Open existing project
  Future<void> openProject(String? filePath) async {
    if (filePath == null) {
      // Show file picker
      filePath = await _projectService.pickProjectFile();
      if (filePath == null) return;
    }

    _setLoading(true);
    _clearError();

    try {
      final project = await _projectService.openProject(filePath);
      await _setCurrentProject(project);
      
      // Add to recent projects
      _addToRecentProjects(project);
      
      // Success message will be shown by the caller
      debugPrint('Проект "${project.name}" успешно открыт');
    } catch (e) {
      _setError(e.toString());
      // Don't show SnackBar here as it might be called from dialog context
      // Let the caller handle the UI error display
      debugPrint('Error opening project: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Save current project
  Future<void> saveProject() async {
    if (_currentProject == null || _currentProject!.isEmpty) {
      _showErrorMessage('Нет проекта для сохранения');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _projectService.saveProject(_currentProject!);
      _currentProject = _currentProject!.markAsSaved();
      _hasUnsavedChanges = false;
      notifyListeners();
      
      _showSuccessMessage('Проект успешно сохранен');
    } catch (e) {
      _setError(e.toString());
      _showErrorMessage('Не удалось сохранить проект: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Save project as new file
  Future<void> saveProjectAs() async {
    if (_currentProject == null) {
      _showErrorMessage('Нет проекта для сохранения');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Pick new file path
      final newFilePath = await _projectService.pickProjectFile();
      if (newFilePath == null) return;

      final newProject = await _projectService.saveProjectAs(_currentProject!, newFilePath);
      
      await _setCurrentProject(newProject);
      _addToRecentProjects(newProject);
      
      _showSuccessMessage('Проект успешно сохранен как "${newProject.name}"');
    } catch (e) {
      _setError(e.toString());
      _showErrorMessage('Не удалось сохранить проект как: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Close current project
  Future<void> closeProject() async {
    if (_currentProject == null) return;

    // Check if there are unsaved changes
    if (_hasUnsavedChanges) {
      // In a real implementation, you'd show a confirmation dialog
      // For now, just close without saving
    }

    _currentProject = null;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  // Create empty project (when onboarding is cancelled)
  void createEmptyProject() {
    _currentProject = Project.empty();
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  // Mark project as modified
  void markAsModified() {
    if (_currentProject != null && !_currentProject!.isEmpty) {
      _hasUnsavedChanges = true;
      _currentProject = _currentProject!.markAsModified();
      notifyListeners();
    }
  }

  // Update project content
  void updateProjectContent(Map<String, dynamic> content) {
    if (_currentProject != null && !_currentProject!.isEmpty) {
      _currentProject = _currentProject!.copyWith(
        content: content,
        modifiedAt: DateTime.now(),
      );
      markAsModified();
    }
  }

  // Update project settings
  void updateProjectSettings(Map<String, dynamic> settings) {
    if (_currentProject != null && !_currentProject!.isEmpty) {
      _currentProject = _currentProject!.copyWith(
        settings: settings,
        modifiedAt: DateTime.now(),
      );
      markAsModified();
    }
  }

  // Load recent projects
  Future<void> loadRecentProjects() async {
    try {
      // In a real implementation, you'd load this from app settings
      // For now, return empty list
      _recentProjects = [];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Check project accessibility
  Future<void> checkProjectAccessibility() async {
    if (_currentProject == null || _currentProject!.isEmpty) return;

    try {
      final isAccessible = await _projectService.isProjectAccessible(_currentProject!);

      if (!isAccessible && _currentProject!.status != ProjectStatus.inaccessible) {
        _currentProject = _currentProject!.copyWith(
          status: ProjectStatus.inaccessible,
        );
        notifyListeners();
        
        _showErrorMessage('Файл проекта стал недоступен');
      } else if (isAccessible && _currentProject!.status == ProjectStatus.inaccessible) {
        _currentProject = _currentProject!.copyWith(
          status: _hasUnsavedChanges ? ProjectStatus.modified : ProjectStatus.saved,
        );
        notifyListeners();
        
        _showSuccessMessage('Файл проекта снова доступен');
      }
    } catch (e) {
      // Ignore monitoring errors to avoid spamming user
    }
  }

  // Private methods
  Future<void> _setCurrentProject(Project project) async {
    _currentProject = project;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  void _addToRecentProjects(Project project) {
    _recentProjects.removeWhere((p) => p.filePath == project.filePath);
    _recentProjects.insert(0, project);
    
    // Keep only last 10 projects
    if (_recentProjects.length > 10) {
      _recentProjects = _recentProjects.take(10).toList();
    }
    
    notifyListeners();
  }

  void _startFileMonitoring() {
    // Check file accessibility every 30 seconds
    _fileMonitorTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkProjectAccessibility();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _showSuccessMessage(String message) {
    debugPrint('Success: $message');
    _showSnackBar(message, Colors.green);
  }

  void _showErrorMessage(String message) {
    debugPrint('Error: $message');
    _showSnackBar(message, Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    // Use ToastService instead of ScaffoldMessenger
    if (color == Colors.green || color == Colors.lightGreen) {
      success(description: message);
    } else if (color == Colors.red || color == Colors.redAccent) {
      error(description: message);
    } else if (color == Colors.orange || color == Colors.amber) {
      warning(description: message);
    } else {
      show(description: message);
    }
  }

  @override
  void dispose() {
    _fileMonitorTimer?.cancel();
    super.dispose();
  }
}