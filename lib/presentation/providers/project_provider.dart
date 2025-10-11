import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:novaspec/domain/services/file_service.dart';
import 'dart:io';

/// Провайдер для работы с проектами
final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier();
});

/// Открытый файл (вкладка)
class OpenedFile {
  final String path;
  final String content;
  final bool hasUnsavedChanges;

  const OpenedFile({
    required this.path,
    required this.content,
    this.hasUnsavedChanges = false,
  });

  OpenedFile copyWith({
    String? path,
    String? content,
    bool? hasUnsavedChanges,
  }) {
    return OpenedFile(
      path: path ?? this.path,
      content: content ?? this.content,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  String get fileName {
    return path.split('/').last.split('\\').last;
  }
}

/// Состояние проекта
class ProjectState {
  final String? projectPath;
  final String? projectName;
  final List<OpenedFile> openedFiles;
  final int? activeTabIndex;
  final DateTime? lastSavedAt;

  const ProjectState({
    this.projectPath,
    this.projectName,
    this.openedFiles = const [],
    this.activeTabIndex,
    this.lastSavedAt,
  });

  /// Получить активный файл
  OpenedFile? get activeFile {
    if (activeTabIndex != null &&
        activeTabIndex! >= 0 &&
        activeTabIndex! < openedFiles.length) {
      return openedFiles[activeTabIndex!];
    }
    return null;
  }

  /// Проверить, есть ли несохраненные изменения в активном файле
  bool get hasUnsavedChanges {
    return activeFile?.hasUnsavedChanges ?? false;
  }

  /// Устаревшие поля для обратной совместимости
  @Deprecated('Use activeFile?.path instead')
  String? get currentFilePath => activeFile?.path;

  @Deprecated('Use activeFile?.content instead')
  String? get currentFileContent => activeFile?.content;

  ProjectState copyWith({
    String? projectPath,
    String? projectName,
    List<OpenedFile>? openedFiles,
    int? activeTabIndex,
    DateTime? lastSavedAt,
    bool clearActiveTab = false,
  }) {
    return ProjectState(
      projectPath: projectPath ?? this.projectPath,
      projectName: projectName ?? this.projectName,
      openedFiles: openedFiles ?? this.openedFiles,
      activeTabIndex: clearActiveTab ? null : (activeTabIndex ?? this.activeTabIndex),
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }
}

/// Notifier для управления проектом
class ProjectNotifier extends StateNotifier<ProjectState> {
  ProjectNotifier() : super(const ProjectState()) {
    _loadCurrentProject();
  }

  final _repository = ConfigRepository(HiveDataSource());
  final _fileService = FileService();

  /// Загрузка текущего проекта из Hive
  Future<void> _loadCurrentProject() async {
    final config = await _repository.getConfig();
    if (config?.currentProjectPath != null) {
      state = state.copyWith(
        projectPath: config!.currentProjectPath,
        projectName: config.currentProjectName,
      );
    }
  }

  /// Создать новый проект
  Future<bool> createNewProject() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final dir = Directory(selectedDirectory);
        final projectName = dir.uri.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
          orElse: () => 'New Project',
        );

        // Создаем структуру папок
        await Directory('$selectedDirectory/specs').create(recursive: true);
        await Directory('$selectedDirectory/.novaspec').create(recursive: true);

        // Сохраняем в Hive
        await _repository.updateCurrentProject(
          path: selectedDirectory,
          name: projectName,
        );

        state = state.copyWith(
          projectPath: selectedDirectory,
          projectName: projectName,
          openedFiles: [], // Очищаем вкладки
          clearActiveTab: true,
        );

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Открыть существующий проект
  Future<bool> openProject() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final dir = Directory(selectedDirectory);
        final projectName = dir.uri.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
          orElse: () => 'Project',
        );

        // Сохраняем в Hive
        await _repository.updateCurrentProject(
          path: selectedDirectory,
          name: projectName,
        );

        state = state.copyWith(
          projectPath: selectedDirectory,
          projectName: projectName,
          openedFiles: [], // Очищаем вкладки
          clearActiveTab: true,
        );

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Открыть файл в проекте (в новой вкладке или активировать существующую)
  Future<bool> openFile(String filePath) async {
    try {
      // Проверяем, не открыт ли уже этот файл
      final existingIndex = state.openedFiles.indexWhere((file) => file.path == filePath);

      if (existingIndex != -1) {
        // Файл уже открыт, просто активируем его
        state = state.copyWith(activeTabIndex: existingIndex);
        return true;
      }

      // Читаем содержимое файла
      final content = await _fileService.readFile(filePath);
      if (content != null) {
        // Добавляем новую вкладку
        final newFile = OpenedFile(path: filePath, content: content);
        final updatedFiles = [...state.openedFiles, newFile];

        state = state.copyWith(
          openedFiles: updatedFiles,
          activeTabIndex: updatedFiles.length - 1,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Переключиться на вкладку
  void switchTab(int index) {
    if (index >= 0 && index < state.openedFiles.length) {
      state = state.copyWith(activeTabIndex: index);
    }
  }

  /// Закрыть вкладку
  void closeTab(int index) {
    if (index < 0 || index >= state.openedFiles.length) {
      return;
    }

    final updatedFiles = List<OpenedFile>.from(state.openedFiles);
    updatedFiles.removeAt(index);

    int? newActiveIndex;
    if (updatedFiles.isEmpty) {
      newActiveIndex = null;
    } else if (state.activeTabIndex == index) {
      // Если закрываем активную вкладку
      if (index > 0) {
        // Активируем предыдущую
        newActiveIndex = index - 1;
      } else {
        // Или следующую, если это первая
        newActiveIndex = 0;
      }
    } else if (state.activeTabIndex != null && state.activeTabIndex! > index) {
      // Если закрываем вкладку до активной, сдвигаем индекс
      newActiveIndex = state.activeTabIndex! - 1;
    } else {
      // Иначе индекс не меняется
      newActiveIndex = state.activeTabIndex;
    }

    state = state.copyWith(
      openedFiles: updatedFiles,
      activeTabIndex: newActiveIndex,
      clearActiveTab: updatedFiles.isEmpty,
    );
  }

  /// Обновить содержимое активного файла (без сохранения)
  void updateContent(String content) {
    final activeIndex = state.activeTabIndex;
    if (activeIndex == null) return;

    final activeFile = state.activeFile;
    if (activeFile == null || activeFile.content == content) return;

    final updatedFiles = List<OpenedFile>.from(state.openedFiles);
    updatedFiles[activeIndex] = activeFile.copyWith(
      content: content,
      hasUnsavedChanges: true,
    );

    state = state.copyWith(openedFiles: updatedFiles);
  }

  /// Сохранить активный файл
  Future<bool> saveCurrentFile() async {
    final activeIndex = state.activeTabIndex;
    final activeFile = state.activeFile;

    if (activeIndex == null || activeFile == null) {
      return false;
    }

    try {
      final success = await _fileService.writeFile(
        activeFile.path,
        activeFile.content,
      );

      if (success) {
        final updatedFiles = List<OpenedFile>.from(state.openedFiles);
        updatedFiles[activeIndex] = activeFile.copyWith(hasUnsavedChanges: false);

        state = state.copyWith(
          openedFiles: updatedFiles,
          lastSavedAt: DateTime.now(), // Триггер для обновления
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Сохранить как новый файл
  Future<bool> saveAs() async {
    final activeFile = state.activeFile;
    if (activeFile == null || state.projectPath == null) {
      return false;
    }

    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить спецификацию',
        fileName: 'spec.md',
        initialDirectory: '${state.projectPath}/specs',
        allowedExtensions: ['md'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        final success = await _fileService.writeFile(
          outputFile,
          activeFile.content,
        );
        if (success) {
          // Обновляем путь файла в текущей вкладке
          final activeIndex = state.activeTabIndex!;
          final updatedFiles = List<OpenedFile>.from(state.openedFiles);
          updatedFiles[activeIndex] = OpenedFile(
            path: outputFile,
            content: activeFile.content,
            hasUnsavedChanges: false,
          );

          state = state.copyWith(
            openedFiles: updatedFiles,
            lastSavedAt: DateTime.now(),
          );
        }
        return success;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Создать новый файл спецификации
  Future<bool> createNewSpec(String template) async {
    if (state.projectPath == null) {
      return false;
    }

    // Создаем новую вкладку с временным именем
    final newFile = OpenedFile(
      path: 'Untitled',
      content: template,
      hasUnsavedChanges: true,
    );

    final updatedFiles = [...state.openedFiles, newFile];

    state = state.copyWith(
      openedFiles: updatedFiles,
      activeTabIndex: updatedFiles.length - 1,
    );

    return true;
  }
}
