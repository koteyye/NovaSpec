import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/project.dart';
import '../../shared/models/project_file.dart';
import '../../shared/models/project_settings.dart';
import '../../core/models/project_error.dart';
import 'project_service_interface.dart';

class ProjectValidationException implements Exception {
  final String message;
  ProjectValidationException(this.message);
  
  @override
  String toString() => message;
}

class ProjectService implements ProjectServiceInterface {
  static const String _fileExtension = 'novaspec';
  static const String _recentProjectsKey = 'recent_projects';
  
  final StreamController<ProjectEvent> _projectEventController = 
      StreamController<ProjectEvent>.broadcast();

  /// Stream событий проекта
  @override
  Stream<ProjectEvent> get projectEvents => _projectEventController.stream;

  /// Проверить, является ли путь сетевым
  @override
  bool isNetworkPath(String path) {
    // Windows network paths: \\server\share or //server/share
    if (path.startsWith('\\\\') || path.startsWith('//')) {
      return true;
    }
    
    // Unix network paths: smb://, nfs://, etc.
    if (path.contains('://') && !path.startsWith('file://')) {
      return true;
    }
    
    // Mapped network drives (Windows)
    if (Platform.isWindows) {
      // Check if path starts with a drive letter that might be mapped
      final driveLetter = path.split(':').first;
      if (driveLetter.length == 1 && RegExp(r'^[A-Za-z]$').hasMatch(driveLetter)) {
        // This is a basic check - in real implementation you'd query Windows API
        // to determine if the drive is mapped network drive
        return false; // Assume local for now
      }
    }
    
    return false;
  }

  /// Валидировать путь проекта
  @override
  Future<void> validateProjectPath(String path) async {
    // Check for network paths
    if (isNetworkPath(path)) {
      throw ProjectValidationException('Network paths are not supported: $path');
    }
    
    // Check if path exists
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw ProjectValidationException('Path does not exist: $path');
    }
    
    // Check if path is accessible
    try {
      // Try to list directory contents
      await dir.list().first;
    } catch (e) {
      if (e is FileSystemException) {
        if (e.osError?.errorCode == 5) { // Access denied
          throw ProjectValidationException('Access denied to path: $path');
        }
      }
      throw ProjectValidationException('Error accessing path: $path - $e');
    }
  }

  /// Определить тип проекта (файл или папка)
  @override
  Future<bool> isFolderProject(String projectPath) async {
    final dir = Directory(projectPath);
    if (!await dir.exists()) {
      return false;
    }
    
    // Check if there's a .novaspec file in the directory
    final specFile = File(path.join(projectPath, '.novaspec'));
    if (await specFile.exists()) {
      return true;
    }
    
    // Check if there are project files in the directory
    try {
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.$_fileExtension')) {
          return false; // File project
        }
      }
    } catch (e) {
      // If we can't list directory, assume it's not accessible
      return false;
    }
    
    // If no .novaspec file and no .novaspec files, assume folder project
    return true;
  }

  // Create a new project
  @override
  Future<Project> createProject({
    required String name,
    required String directory,
    String description = '',
  }) async {
    // Validate project name
    if (name.trim().isEmpty) {
      throw ProjectValidationException('Project name cannot be empty');
    }

    // Validate directory
    if (isNetworkPath(directory)) {
      throw ProjectValidationException('Network paths are not supported for projects');
    }
    
    final dir = Directory(directory);
    if (!await dir.exists()) {
      throw ProjectValidationException('Directory does not exist');
    }

    // Check if directory is writable
    try {
      final testFile = File(path.join(directory, '.novaspec_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      throw ProjectValidationException('No write permissions for directory');
    }

    // Check if project already exists
    final projectPath = path.join(directory, '${name.toLowerCase().replaceAll(' ', '_')}.$_fileExtension');
    final projectFile = File(projectPath);
    if (await projectFile.exists()) {
      throw ProjectValidationException('Project with this name already exists in directory');
    }

    // Create project
    final project = Project.createNew(
      name: name.trim(),
      directory: directory,
    );

    // Save project file
    await _saveProjectFile(project);

    return project;
  }

  // Open existing project
  @override
  Future<Project> openProject(String filePath) async {
    // If filePath is null or empty, open folder picker (like VSCode)
    if (filePath.trim().isEmpty) {
      return await openFolderAsProject();
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw ProjectValidationException('Project file does not exist');
    }

    try {
      final content = await file.readAsString();
      final data = _parseProjectContent(content);
      
      final fileName = path.basenameWithoutExtension(filePath);
      final directory = path.dirname(filePath);

      return Project.fromFile(
        name: fileName,
        filePath: filePath,
        directory: directory,
        data: data,
      );
    } catch (e) {
      throw ProjectValidationException('Error reading project file: $e');
    }
  }

  // Open any folder as a project (like VSCode)
  @override
  Future<Project> openFolderAsProject() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Выберите папку для открытия как проект',
    );

    if (selectedDirectory == null || selectedDirectory.trim().isEmpty) {
      throw ProjectValidationException('No folder selected');
    }

    // Check for network paths
    if (isNetworkPath(selectedDirectory)) {
      throw ProjectValidationException('Network paths are not supported for folder projects');
    }

    final directory = Directory(selectedDirectory);
    if (!await directory.exists()) {
      throw ProjectValidationException('Selected folder does not exist');
    }

    final folderName = path.basename(selectedDirectory);
    
    // Create a project from folder
    return Project.fromFile(
      name: folderName,
      filePath: '$selectedDirectory/.novaspec', // Virtual project file path
      directory: selectedDirectory,
      data: {
        'version': '1.0.0',
        'created': DateTime.now().toIso8601String(),
        'modified': DateTime.now().toIso8601String(),
        'settings': {
          'theme': 'light',
          'language': 'ru',
          'is_folder_project': true,
        },
        'content': {
          'sections': [],
          'specifications': [],
        },
      },
    );
  }

  // Save project
  @override
  Future<void> saveProject(Project project) async {
    if (project.filePath.isEmpty) {
      throw ProjectValidationException('Project has no save path');
    }

    await _saveProjectFile(project);
  }

  // Save project as
  @override
  Future<Project> saveProjectAs(Project project, String newFilePath) async {
    if (newFilePath.trim().isEmpty) {
      throw ProjectValidationException('New path cannot be empty');
    }

    final directory = path.dirname(newFilePath);
    
    // Check if directory exists and is writable
    final dir = Directory(directory);
    if (!await dir.exists()) {
      throw ProjectValidationException('Save directory does not exist');
    }

    try {
      final testFile = File(path.join(directory, '.novaspec_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      throw ProjectValidationException('No write permissions for save directory');
    }

    // Create new project with updated path
    final fileName = path.basenameWithoutExtension(newFilePath);
    final updatedProject = project.copyWith(
      name: fileName,
      filePath: newFilePath,
      directory: directory,
    );

    await _saveProjectFile(updatedProject);
    return updatedProject;
  }

  // Pick directory for project
  @override
  Future<String?> pickDirectory() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Выберите директорию для проекта',
      );
      return result;
    } catch (e) {
      throw ProjectValidationException('Error selecting directory: $e');
    }
  }

  // Pick project file or directory
  @override
  Future<String?> pickProjectFile() async {
    try {
      // First try to pick directory for more flexible project opening
      final directory = await pickDirectory();
      if (directory != null) {
        // Look for .novaspec files in the directory
        final dir = Directory(directory);
        final files = await dir.list().where((entity) => 
          entity is File && 
          entity.path.endsWith('.$_fileExtension')
        ).cast<File>().toList();
        
        if (files.isNotEmpty) {
          // Return the first .novaspec file found
          return files.first.path;
        } else {
          // Create a new project file in the directory
          final projectName = path.basename(directory);
          final projectFilePath = path.join(directory, '$projectName.$_fileExtension');
          final projectFile = File(projectFilePath);
          
          // Create empty project file
          if (!await projectFile.exists()) {
            await projectFile.writeAsString('{"name": "$projectName", "files": [], "settings": {}}');
          }
          
          return projectFilePath;
        }
      }
      
      // Fallback to file picker if directory selection fails
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [_fileExtension],
        dialogTitle: 'Выберите файл проекта',
      );
      
      return result?.files.single.path;
    } catch (e) {
      throw ProjectValidationException('Error selecting project file: $e');
    }
  }

  // Check if project is accessible
  @override
  Future<bool> isProjectAccessible(Project project) async {
    try {
      if (project.isFolderProject) {
        // For folder projects, check directory accessibility and write permissions
        final directory = Directory(project.directory);
        if (!await directory.exists()) return false;
        
        // Check write permissions by trying to create a test file
        try {
          final testFile = File(path.join(project.directory, '.novaspec_access_test'));
          await testFile.writeAsString('test');
          await testFile.delete();
          return true;
        } catch (e) {
          // Permission denied or other access error
          return false;
        }
      } else {
        // For file projects, check file accessibility
        if (project.filePath.isEmpty) return false;
        final file = File(project.filePath);
        if (!await file.exists()) return false;
        
        // Check if we can read the file
        try {
          await file.readAsString();
          return true;
        } catch (e) {
          // Permission denied or other access error
          return false;
        }
      }
    } catch (e) {
      return false;
    }
  }

  // Delete project
  @override
  Future<void> deleteProject(Project project) async {
    try {
      if (project.filePath.isNotEmpty) {
        final file = File(project.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw ProjectValidationException('Error deleting project: $e');
    }
  }

  // Get project files
  Future<List<ProjectFile>> getProjectFiles(Project project) async {
    try {
      final directory = Directory(project.directory);
      if (!await directory.exists()) {
        return [];
      }

      final files = <ProjectFile>[];
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: project.directory);
          final stat = await entity.stat();
          
          files.add(ProjectFile(
            name: path.basename(entity.path),
            path: relativePath,
            size: stat.size,
            modifiedAt: stat.modified,
            type: _getFileType(entity.path),
          ));
        }
      }

      return files..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw ProjectValidationException('Error getting file list: $e');
    }
  }

  // Validate project structure
  Future<bool> validateProjectStructure(Project project) async {
    try {
      // Check if project file exists and is readable
      if (project.filePath.isNotEmpty) {
        final file = File(project.filePath);
        if (!await file.exists()) return false;
        
        final content = await file.readAsString();
        _parseProjectContent(content);
      }

      // Check if directory exists
      final directory = Directory(project.directory);
      if (!await directory.exists()) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Реализация недостающих методов интерфейса

  /// Получить список недавних проектов
  @override
  Future<List<Project>> getRecentProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentProjectsJson = prefs.getStringList(_recentProjectsKey) ?? [];
      
      final projects = <Project>[];
      for (final projectJson in recentProjectsJson) {
        try {
          final data = jsonDecode(projectJson);
          final project = Project.fromMap(data);
          if (await isProjectAccessible(project)) {
            projects.add(project);
          }
        } catch (e) {
          // Пропускаем некорректные записи
          continue;
        }
      }
      
      return projects;
    } catch (e) {
      return [];
    }
  }

  /// Добавить проект в недавние
  @override
  Future<void> addToRecentProjects(Project project) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentProjectsJson = prefs.getStringList(_recentProjectsKey) ?? [];
      
      // Удаляем дубликаты
      recentProjectsJson.removeWhere((json) {
        try {
          final data = jsonDecode(json);
          return data['filePath'] == project.filePath;
        } catch (e) {
          return false;
        }
      });
      
      // Добавляем в начало
      recentProjectsJson.insert(0, jsonEncode(project.toMap()));
      
      // Ограничиваем количество
      if (recentProjectsJson.length > 10) {
        recentProjectsJson.removeRange(10, recentProjectsJson.length);
      }
      
      await prefs.setStringList(_recentProjectsKey, recentProjectsJson);
      _projectEventController.add(ProjectEvent.opened);
    } catch (e) {
      // Игнорируем ошибки при сохранении недавних проектов
    }
  }

  /// Получить настройки проекта
  @override
  Future<ProjectSettings> getProjectSettings(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('project_settings_$projectId');
      
      if (settingsJson != null) {
        final data = jsonDecode(settingsJson);
        return ProjectSettings.fromMap(data);
      }
      
      return ProjectSettings.defaultSettings();
    } catch (e) {
      return ProjectSettings.defaultSettings();
    }
  }

  /// Сохранить настройки проекта
  @override
  Future<void> saveProjectSettings(String projectId, ProjectSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('project_settings_$projectId', jsonEncode(settings.toMap()));
    } catch (e) {
      // Игнорируем ошибки при сохранении настроек
    }
  }

  /// Экспортировать проект
  @override
  Future<void> exportProject(Project project, String exportPath) async {
    try {
      final exportFile = File(exportPath);
      final content = _serializeProject(project);
      await exportFile.writeAsString(content);
      _projectEventController.add(ProjectEvent.saved);
    } catch (e) {
      throw ProjectValidationException('Error exporting project: $e');
    }
  }

  /// Импортировать проект
  @override
  Future<Project> importProject(String importPath) async {
    try {
      final file = File(importPath);
      if (!await file.exists()) {
        throw ProjectValidationException('Import file does not exist');
      }
      
      final content = await file.readAsString();
      final data = _parseProjectContent(content);
      
      final fileName = path.basenameWithoutExtension(importPath);
      final directory = path.dirname(importPath);
      
      final project = Project.fromFile(
        name: fileName,
        filePath: importPath,
        directory: directory,
        data: data,
      );
      
      _projectEventController.add(ProjectEvent.created);
      return project;
    } catch (e) {
      throw ProjectValidationException('Error importing project: $e');
    }
  }

  /// Получить статистику проекта
  @override
  Future<Map<String, dynamic>> getProjectStats(Project project) async {
    try {
      final files = await getProjectFiles(project);
      final totalSize = files.fold<int>(0, (sum, file) => sum + file.size);
      
      return {
        'totalFiles': files.length,
        'totalSize': totalSize,
        'lastModified': project.modifiedAt.toIso8601String(),
        'createdAt': project.createdAt.toIso8601String(),
        'isAccessible': await isProjectAccessible(project),
        'projectType': project.isFolderProject ? 'folder' : 'file',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'totalFiles': 0,
        'totalSize': 0,
      };
    }
  }

  /// Очистить кэш проекта
  @override
  Future<void> clearProjectCache(String projectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('project_cache_$projectId');
      await prefs.remove('project_settings_$projectId');
    } catch (e) {
      // Игнорируем ошибки при очистке кэша
    }
  }

  /// Проверить целостность проекта
  @override
  Future<List<ProjectError>> validateProjectIntegrity(Project project) async {
    final errors = <ProjectError>[];
    
    try {
      // Проверяем доступность файла проекта
      if (!project.isFolderProject && project.filePath.isNotEmpty) {
        final file = File(project.filePath);
        if (!await file.exists()) {
          errors.add(ProjectError.fileSystem(
            projectId: project.id,
            message: 'Project file not found: ${project.filePath}',
            details: 'File project requires existing project file',
          ));
        }
      }
      
      // Проверяем доступность директории
      final directory = Directory(project.directory);
      if (!await directory.exists()) {
        errors.add(ProjectError.fileSystem(
          projectId: project.id,
          message: 'Project directory not found: ${project.directory}',
          details: 'Project directory must exist for project to be accessible',
        ));
      }
      
      // Проверяем права на запись
      try {
        final testFile = File(path.join(project.directory, '.novaspec_integrity_test'));
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        errors.add(ProjectError.permission(
          projectId: project.id,
          message: 'No write permissions for project directory: ${project.directory}',
          details: e.toString(),
        ));
      }
      
      // Проверяем структуру файла проекта
      if (!project.isFolderProject && project.filePath.isNotEmpty) {
        try {
          final file = File(project.filePath);
          final content = await file.readAsString();
          _parseProjectContent(content);
        } catch (e) {
          errors.add(ProjectError.fileSystem(
            projectId: project.id,
            message: 'Project file corrupted: ${e.toString()}',
            details: 'File parsing failed',
            stackTrace: e.toString(),
          ));
        }
      }
      
    } catch (e) {
      errors.add(ProjectError.unknown(
        projectId: project.id,
        message: 'Integrity check failed: ${e.toString()}',
        details: e.toString(),
        stackTrace: e.toString(),
      ));
    }
    
    return errors;
  }

  /// Восстановить проект
  @override
  Future<Project> recoverProject(String backupPath) async {
    try {
      return await importProject(backupPath);
    } catch (e) {
      throw ProjectValidationException('Error recovering project: $e');
    }
  }

  /// Создать резервную копию
  @override
  Future<void> createBackup(Project project, String backupPath) async {
    try {
      await exportProject(project, backupPath);
    } catch (e) {
      throw ProjectValidationException('Error creating backup: $e');
    }
  }

  /// Освободить ресурсы
  void dispose() {
    _projectEventController.close();
  }

  // Private helper methods

  Future<void> _saveProjectFile(Project project) async {
    try {
      final file = File(project.filePath);
      final content = _serializeProject(project);
      await file.writeAsString(content);
    } catch (e) {
      throw ProjectValidationException('Error saving project: $e');
    }
  }

  Map<String, dynamic> _parseProjectContent(String content) {
    try {
      if (content.trim().isEmpty) {
        // Return default structure for empty content
        return {
          'version': '1.0.0',
          'created': DateTime.now().toIso8601String(),
          'modified': DateTime.now().toIso8601String(),
          'settings': {},
          'content': {
            'specifications': [],
          },
        };
      }
      
      final dynamic parsed = jsonDecode(content);
      
      // Ensure we return Map<String, dynamic>
      if (parsed is Map) {
        return Map<String, dynamic>.from(parsed);
      } else {
        throw ProjectValidationException('Invalid project file format');
      }
    } catch (e) {
      throw ProjectValidationException('Error parsing project content: $e');
    }
  }

  String _serializeProject(Project project) {
    // Simple JSON-like serialization for now
    // In real implementation, you'd use dart:convert
    return '''
{
  "version": "1.0.0",
  "created": "${project.createdAt.toIso8601String()}",
  "modified": "${project.modifiedAt.toIso8601String()}",
  "settings": {},
  "content": {
    "specifications": []
  }
}
''';
  }

  ProjectFileType _getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.dart':
        return ProjectFileType.dart;
      case '.json':
        return ProjectFileType.json;
      case '.md':
        return ProjectFileType.markdown;
      case '.txt':
        return ProjectFileType.text;
      case '.yaml':
      case '.yml':
        return ProjectFileType.yaml;
      default:
        return ProjectFileType.other;
    }
  }
}