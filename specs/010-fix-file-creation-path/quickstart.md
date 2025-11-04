# Quick Start Guide: Исправление пути создания файлов

**Feature**: Исправление пути создания файлов  
**Date**: 31.10.2025  
**Target Audience**: Flutter Developers  

## Overview

Этот гайд поможет быстро начать работу с исправлением проблемы создания файлов в неверной директории. Основная задача - обеспечить создание файлов в текущей активной директории проводника, а не в корне репозитория.

## Prerequisites

### Required Dependencies
Убедитесь что в `pubspec.yaml` есть все необходимые зависимости:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  get_it: ^7.6.4
  file_picker: ^6.1.1
  dio: ^5.3.2
  flutter_localizations:
    sdk: flutter
  flutter_svg: ^2.0.7
```

### Required Services
Убедитесь что все сервисы зарегистрированы в DI контейнере:

```dart
// lib/core/services/get_it.dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Existing services
  getIt.registerLazySingleton<ProjectService>(() => ProjectService());
  getIt.registerLazySingleton<WorkspaceFileService>(() => WorkspaceFileService());
  getIt.registerLazySingleton<FileExplorerProvider>(() => FileExplorerProvider());
  getIt.registerLazySingleton<ToastService>(() => ToastService());
}
```

## Implementation Steps

### Step 1: Update FileExplorerProvider

Добавьте методы для валидации директории:

```dart
// lib/features/workspace/providers/file_explorer_provider.dart

class FileExplorerProvider extends ChangeNotifier {
  String _currentDirectory = '';
  String get currentDirectory => _currentDirectory;
  
  void setCurrentDirectory(String path) {
    _currentDirectory = path;
    notifyListeners();
  }
  
  // Новый метод для валидации директории
  Future<DirectoryValidationResult> validateDirectory(String path) async {
    try {
      final directory = Directory(path);
      
      // Проверяем существование
      if (!await directory.exists()) {
        return DirectoryValidationResult.notFound(path);
      }
      
      // Проверяем права на запись
      try {
        final testFile = File('$path/.write_test_${DateTime.now().millisecondsSinceEpoch}');
        await testFile.writeAsString('test');
        await testFile.delete();
      } catch (e) {
        return DirectoryValidationResult.permissionDenied(path);
      }
      
      // Проверяем длину пути
      if (path.length > 260) {
        return DirectoryValidationResult.pathTooLong(path);
      }
      
      return DirectoryValidationResult.success();
    } catch (e) {
      return DirectoryValidationResult.error(
        DirectoryValidationStatus.unknownError,
        e.toString(),
      );
    }
  }
  
  Future<bool> isDirectoryAccessible(String path) async {
    final result = await validateDirectory(path);
    return result.isAccessible && result.hasWritePermission;
  }
}
```

### Step 2: Update WorkspaceFileService

Добавьте новый метод для создания файлов с контекстом:

```dart
// lib/shared/services/workspace_file_service.dart

class WorkspaceFileService {
  String _currentDirectory = '';
  
  // Новый метод для создания файла с контекстом
  Future<FileCreationResult> createFileWithContext(
    FileCreationContext context
  ) async {
    try {
      // Валидация контекста
      if (!context.isValid) {
        return FileCreationResult.error(
          FileCreationErrorType.invalidFileName,
          context.validationError ?? 'Invalid file name',
        );
      }
      
      // Проверяем существование файла
      if (await File(context.fullPath).exists()) {
        return FileCreationResult.error(
          FileCreationErrorType.fileAlreadyExists,
          'File already exists: ${context.fileName}',
        );
      }
      
      // Создаем файл
      final file = File(context.fullPath);
      await file.writeAsString('');
      
      return FileCreationResult.success(context.fullPath);
    } catch (e) {
      // Определяем тип ошибки
      FileCreationErrorType errorType;
      String message = e.toString();
      
      if (e is FileSystemException) {
        if (e.message.contains('Permission denied')) {
          errorType = FileCreationErrorType.permissionDenied;
        } else if (e.message.contains('No space left')) {
          errorType = FileCreationErrorType.diskFull;
        } else if (e.message.contains('No such file or directory')) {
          errorType = FileCreationErrorType.directoryNotFound;
        } else {
          errorType = FileCreationErrorType.unknownError;
        }
      } else {
        errorType = FileCreationErrorType.unknownError;
      }
      
      return FileCreationResult.error(errorType, message);
    }
  }
  
  // Существующий метод для обратной совместимости
  Future<void> createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
```

### Step 3: Update CreateFileDialog

Измените логику создания файла:

```dart
// lib/features/workspace/widgets/create_file_dialog.dart

class _CreateFileDialogState extends State<CreateFileDialog> {
  final _fileNameController = TextEditingController();
  bool _isCreating = false;
  
  Future<void> _createFile() async {
    if (_fileNameController.text.trim().isEmpty) return;
    
    setState(() => _isCreating = true);
    
    try {
      final fileExplorerProvider = getIt<FileExplorerProvider>();
      final workspaceService = getIt<WorkspaceFileService>();
      final projectProvider = getIt<ProjectProvider>();
      
      // Получаем текущую директорию
      final currentDir = fileExplorerProvider.currentDirectory;
      final projectRoot = projectProvider.currentProject?.directory ?? '';
      
      // Если текущая директория не установлена, используем корень проекта
      final targetDirectory = currentDir.isNotEmpty ? currentDir : projectRoot;
      
      // Создаем контекст
      final context = FileCreationContext.create(
        fileName: _fileNameController.text.trim(),
        currentDirectory: targetDirectory,
        projectRoot: projectRoot,
      );
      
      // Валидируем директорию
      final validation = await fileExplorerProvider.validateDirectory(targetDirectory);
      if (!validation.isAccessible || !validation.hasWritePermission) {
        ToastService.error(
          AppLocalizations.of(context)!.fileCreationErrorPermissionDenied(targetDirectory)
        );
        return;
      }
      
      // Создаем файл
      final result = await workspaceService.createFileWithContext(context);
      
      if (result.success) {
        ToastService.success(
          AppLocalizations.of(context)!.fileCreated(result.filePath!)
        );
        
        // Обновляем проводник
        fileExplorerProvider.refresh();
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        String errorMessage;
        switch (result.errorType) {
          case FileCreationErrorType.fileAlreadyExists:
            errorMessage = AppLocalizations.of(context)!.fileAlreadyExists(context.fileName);
            break;
          case FileCreationErrorType.invalidFileName:
            errorMessage = AppLocalizations.of(context)!.invalidFileName(context.fileName);
            break;
          case FileCreationErrorType.permissionDenied:
            errorMessage = AppLocalizations.of(context)!.permissionDenied(targetDirectory);
            break;
          case FileCreationErrorType.directoryNotFound:
            errorMessage = AppLocalizations.of(context)!.directoryNotFound(targetDirectory);
            break;
          case FileCreationErrorType.diskFull:
            errorMessage = AppLocalizations.of(context)!.diskFull;
            break;
          default:
            errorMessage = result.errorMessage ?? AppLocalizations.of(context)!.unknownError;
        }
        
        ToastService.error(errorMessage);
      }
    } catch (e) {
      ToastService.error(
        AppLocalizations.of(context)!.fileCreationError(e.toString())
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: AppLocalizations.of(context)!.createFile,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _fileNameController,
            labelText: AppLocalizations.of(context)!.fileName,
            hintText: AppLocalizations.of(context)!.enterFileName,
          ),
        ],
      ),
      actions: [
        ModernButton(
          text: AppLocalizations.of(context)!.cancel,
          type: ButtonType.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        ModernButton(
          text: _isCreating 
            ? AppLocalizations.of(context)!.creating 
            : AppLocalizations.of(context)!.create,
          type: ButtonType.primary,
          onPressed: _isCreating ? null : _createFile,
          isLoading: _isCreating,
        ),
      ],
    );
  }
}
```

### Step 4: Add Localization

Добавьте необходимые строки в файлы локализации:

```dart
// lib/l10n/app_localizations.arb
{
  "fileCreated": "Файл {fileName} создан успешно",
  "fileCreationError": "Ошибка создания файла: {error}",
  "fileCreationErrorPermissionDenied": "Нет прав на запись в директорию: {directory}",
  "fileAlreadyExists": "Файл {fileName} уже существует",
  "invalidFileName": "Недопустимое имя файла: {fileName}",
  "permissionDenied": "Нет прав на запись в директорию: {directory}",
  "directoryNotFound": "Директория не найдена: {directory}",
  "diskFull": "Недостаточно места на диске",
  "unknownError": "Неизвестная ошибка",
  "creating": "Создание...",
  "fileName": "Имя файла",
  "enterFileName": "Введите имя файла",
  "createFile": "Создать файл",
  "create": "Создать",
  "cancel": "Отмена"
}
```

## Testing

### Manual Testing Checklist

1. **Basic File Creation**
   - [ ] Открыть проект
   - [ ] Перейти в подпапку
   - [ ] Создать файл через диалог
   - [ ] Проверить что файл создан в правильной папке

2. **Root Directory Creation**
   - [ ] Открыть проект
   - [ ] Не переходить в подпапки
   - [ ] Создать файл
   - [ ] Проверить что файл создан в корне проекта

3. **Error Handling**
   - [ ] Попытаться создать файл в недоступной директории
   - [ ] Проверить сообщение об ошибке
   - [ ] Попытаться создать файл с недопустимым именем
   - [ ] Проверить валидацию имени файла

4. **Deep Directory Structure**
   - [ ] Перейти в папку глубиной 5+ уровней
   - [ ] Создать файл
   - [ ] Проверить что файл создан в правильной папке

### Performance Testing

1. **File Creation Speed**
   - Замерьте время от нажатия "Создать" до появления файла
   - Должно быть не более 2 секунд

2. **UI Responsiveness**
   - UI не должен блокироваться во время создания файла
   - Кнопка "Создать" должна показывать состояние загрузки

## Troubleshooting

### Common Issues

**Problem**: Файл создается в корне репозитория  
**Solution**: Убедитесь что `FileExplorerProvider.currentDirectory` установлен правильно

**Problem**: Ошибка "Permission denied"  
**Solution**: Проверьте права на запись в директорию

**Problem**: UI зависает при создании файла  
**Solution**: Убедитесь что все файловые операции асинхронные

### Debug Tips

1. Включите логирование для отслеживания операций
2. Проверьте значения `currentDirectory` в FileExplorerProvider
3. Используйте `print()` для отладки пути создания файла

## Next Steps

После реализации базовой функциональности:

1. Добавьте кэширование результатов валидации директории
2. Реализуйте batch создание файлов
3. Добавьте поддержку шаблонов файлов
4. Улучшите обработку ошибок с предложением альтернатив

## Support

Если возникли проблемы:
1. Проверьте логи приложения
2. Убедитесь что все зависимости установлены
3. Проверьте что DI контейнер настроен правильно
4. Сравните с TypeScript референсом для визуального соответствия