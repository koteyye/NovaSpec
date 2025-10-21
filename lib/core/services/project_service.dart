import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../shared/models/project.dart';
import '../../shared/models/project_file.dart';

class ProjectValidationException implements Exception {
  final String message;
  ProjectValidationException(this.message);
  
  @override
  String toString() => message;
}

class ProjectService {
  static const String _fileExtension = 'novaspec';

  // Create a new project
  Future<Project> createProject({
    required String name,
    required String directory,
    String description = '',
  }) async {
    // Validate project name
    if (name.trim().isEmpty) {
      throw ProjectValidationException('Название проекта не может быть пустым');
    }

    // Validate directory
    final dir = Directory(directory);
    if (!await dir.exists()) {
      throw ProjectValidationException('Указанная директория не существует');
    }

    // Check if directory is writable
    try {
      final testFile = File(path.join(directory, '.novaspec_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      throw ProjectValidationException('Нет прав на запись в указанную директорию');
    }

    // Check available disk space (basic check)
    try {
      // For now, skip disk space check as Directory.length is not available
      // In real implementation, you'd use platform-specific APIs
    } catch (e) {
      // Skip disk space check for now
    }

    // Check if project already exists
    final projectPath = path.join(directory, '${name.toLowerCase().replaceAll(' ', '_')}.$_fileExtension');
    final projectFile = File(projectPath);
    if (await projectFile.exists()) {
      throw ProjectValidationException('Проект с таким названием уже существует в этой директории');
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
  Future<Project> openProject(String filePath) async {
    // If filePath is null or empty, open folder picker (like VSCode)
    if (filePath.trim().isEmpty) {
      return await openFolderAsProject();
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw ProjectValidationException('Файл проекта не существует');
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
      throw ProjectValidationException('Ошибка при чтении файла проекта: $e');
    }
  }

  // Open any folder as a project (like VSCode)
  Future<Project> openFolderAsProject() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Выберите папку для открытия как проект',
    );

    if (selectedDirectory == null || selectedDirectory.trim().isEmpty) {
      throw ProjectValidationException('Папка не выбрана');
    }

    final directory = Directory(selectedDirectory);
    if (!await directory.exists()) {
      throw ProjectValidationException('Выбранная папка не существует');
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
  Future<void> saveProject(Project project) async {
    if (project.filePath.isEmpty) {
      throw ProjectValidationException('Проект не имеет пути для сохранения');
    }

    await _saveProjectFile(project);
  }

  // Save project as
  Future<Project> saveProjectAs(Project project, String newFilePath) async {
    if (newFilePath.trim().isEmpty) {
      throw ProjectValidationException('Новый путь не может быть пустым');
    }

    final directory = path.dirname(newFilePath);
    
    // Check if directory exists and is writable
    final dir = Directory(directory);
    if (!await dir.exists()) {
      throw ProjectValidationException('Директория для сохранения не существует');
    }

    try {
      final testFile = File(path.join(directory, '.novaspec_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      throw ProjectValidationException('Нет прав на запись в указанную директорию');
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
  Future<String?> pickDirectory() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Выберите директорию для проекта',
      );
      return result;
    } catch (e) {
      throw ProjectValidationException('Ошибка при выборе директории: $e');
    }
  }

  // Pick project file or directory
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
      throw ProjectValidationException('Ошибка при выборе файла проекта: $e');
    }
  }

  // Check if project is accessible
  Future<bool> isProjectAccessible(Project project) async {
    try {
      if (project.filePath.isEmpty) return false;
      
      final file = File(project.filePath);
      return await file.exists();
    } catch (e) {
      return false;
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
      throw ProjectValidationException('Ошибка при получении списка файлов: $e');
    }
  }

  // Delete project
  Future<void> deleteProject(Project project) async {
    try {
      if (project.filePath.isNotEmpty) {
        final file = File(project.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      throw ProjectValidationException('Ошибка при удалении проекта: $e');
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

  // Private helper methods

  Future<void> _saveProjectFile(Project project) async {
    try {
      final file = File(project.filePath);
      final content = _serializeProject(project);
      await file.writeAsString(content);
    } catch (e) {
      throw ProjectValidationException('Ошибка при сохранении проекта: $e');
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
        throw ProjectValidationException('Неверный формат файла проекта');
      }
    } catch (e) {
      throw ProjectValidationException('Ошибка парсинга содержимого проекта: $e');
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