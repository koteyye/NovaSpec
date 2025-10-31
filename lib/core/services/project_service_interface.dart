import 'dart:async';
import '../../shared/models/project.dart';
import '../../shared/models/project_settings.dart';
import '../../core/models/project_error.dart';

/// Интерфейс для работы с проектами
abstract class ProjectServiceInterface {
  /// Создать новый проект
  Future<Project> createProject({
    required String name,
    required String directory,
    String description = '',
  });

  /// Открыть существующий проект
  Future<Project> openProject(String filePath);

  /// Открыть папку как проект
  Future<Project> openFolderAsProject();

  /// Сохранить проект
  Future<void> saveProject(Project project);

  /// Сохранить проект как
  Future<Project> saveProjectAs(Project project, String newPath);

  /// Удалить проект
  Future<void> deleteProject(Project project);

  /// Проверить доступность проекта
  Future<bool> isProjectAccessible(Project project);

  /// Получить список недавних проектов
  Future<List<Project>> getRecentProjects();

  /// Добавить проект в недавние
  Future<void> addToRecentProjects(Project project);

  /// Валидировать путь проекта
  Future<void> validateProjectPath(String path);

  /// Проверить, является ли путь сетевым
  bool isNetworkPath(String path);

  /// Определить тип проекта (файл или папка)
  Future<bool> isFolderProject(String path);

  /// Выбрать директорию
  Future<String?> pickDirectory();

  /// Выбрать файл проекта
  Future<String?> pickProjectFile();

  /// Получить настройки проекта
  Future<ProjectSettings> getProjectSettings(String projectId);

  /// Сохранить настройки проекта
  Future<void> saveProjectSettings(String projectId, ProjectSettings settings);

  /// Экспортировать проект
  Future<void> exportProject(Project project, String exportPath);

  /// Импортировать проект
  Future<Project> importProject(String importPath);

  /// Получить статистику проекта
  Future<Map<String, dynamic>> getProjectStats(Project project);

  /// Очистить кэш проекта
  Future<void> clearProjectCache(String projectId);

  /// Проверить целостность проекта
  Future<List<ProjectError>> validateProjectIntegrity(Project project);

  /// Восстановить проект
  Future<Project> recoverProject(String backupPath);

  /// Создать резервную копию
  Future<void> createBackup(Project project, String backupPath);

  /// Stream событий проекта
  Stream<ProjectEvent> get projectEvents;
}

/// События проекта
enum ProjectEvent {
  created,
  opened,
  saved,
  closed,
  deleted,
  modified,
  error,
}

/// Данные о событии проекта
class ProjectEventData {
  final ProjectEvent type;
  final String? projectId;
  final String? message;
  final DateTime timestamp;
  final dynamic data;

  const ProjectEventData({
    required this.type,
    this.projectId,
    this.message,
    required this.timestamp,
    this.data,
  });
}