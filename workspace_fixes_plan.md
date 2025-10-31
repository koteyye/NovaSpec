# План исправления проблем NovaSpec2

## Анализ проблем

После анализа кода были выявлены следующие ключевые проблемы:

### Проблема #1: Ошибка "файл проекта стал недоступен"
**Корень проблемы:** В `ProjectProvider` есть таймер `_fileMonitorTimer` который каждые 30 секунд проверяет доступность файла проекта через `checkProjectAccessibility()`. Для папок-проектов используется виртуальный путь `.novaspec`, который не существует физически.

**Файлы:** `lib/features/project/providers/project_provider.dart:268-270`

### Проблема #2: Файл создается в репозитории, а не в проекте  
**Корень проблемы:** В `CreateFileDialog` при формировании пути используется `widget.initialPath`, но не проверяется текущий открытый проект. `WorkspaceFileService` работает с `_currentDirectory` который может быть не установлен.

**Файлы:** `lib/features/workspace/widgets/create_file_dialog.dart:466-469`

### Проблема #3: Используется стандартный SnackBar вместо ModernToast
**Корень проблемы:** В `CreateFileDialog` и `ProjectProvider` используются `ScaffoldMessenger.of(context).showSnackBar()` вместо `ToastService`.

**Файлы:** 
- `lib/features/workspace/widgets/create_file_dialog.dart:488-494`
- `lib/features/project/providers/project_provider.dart:298-309`

### Проблема #4: Monaco Editor не показывается
**Корень проблемы:** Вместо Monaco Editor используется простой `CodeEditor` с `TextField`. Нет интеграции с `webview_flutter` для Monaco Editor.

**Файлы:** `lib/features/workspace/widgets/code_editor.dart`

### Проблема #5: Создание файла через диалоговое окно
**Корень проблемы:** Текущая реализация использует модальный диалог вместо inline редактирования как в VSCode. Нет inline создания файла с редактируемым именем.

**Файлы:** `lib/features/workspace/widgets/create_file_dialog.dart`

---

## План решения по фазам

### Фаза 1: Критические исправления (Приоритет: Высокий)

#### Задача 1.1: Исправить проверку доступности проекта
- **Действия:**
  1. Модифицировать `ProjectService.isProjectAccessible()` для корректной работы с папками-проектами
  2. Обновить `ProjectProvider.checkProjectAccessibility()` чтобы не показывать ошибку для папок-проектов
  3. Добавить проверку `is_folder_project` в статус проекта

#### Задача 1.2: Исправить путь создания файлов
- **Действия:**
  1. Обновить `CreateFileDialog` для использования текущей директории из `FileExplorerProvider`
  2. Убедиться что `WorkspaceFileService.setCurrentProject()` вызывается корректно
  3. Добавить валидацию пути создания файла

#### Задача 1.3: Заменить SnackBar на ModernToast
- **Действия:**
  1. Заменить все `ScaffoldMessenger.showSnackBar()` на `ToastService` вызовы
  2. Обновить импорты в `CreateFileDialog` и `ProjectProvider`
  3. Использовать глобальные функции `success()`, `error()` из `ToastService`

### Фаза 2: Улучшение редактора (Приоритет: Высокий)

#### Задача 2.1: Интеграция Monaco Editor
- **Действия:**
  1. Создать новый компонент `MonacoEditor` на основе `webview_flutter`
  2. Добавить поддержку языков: Dart, JavaScript, TypeScript, Python, JSON, Markdown
  3. Интегрировать Monaco Editor в `CodeEditor` компонент
  4. Добавить переключение между простым редактором и Monaco

#### Задача 2.2: Определение типов файлов для Monaco
- **Действия:**
  1. Обновить `WorkspaceFileService.getFileType()` для точного определения
  2. Создать маппинг типов файлов в языки Monaco
  3. Добавить поддержку синтаксиса и тем

### Фаза 3: Улучшение UX создания файлов (Приоритет: Средний)

#### Задача 3.1: Inline создание файлов
- **Действия:**
  1. Создать компонент `InlineFileCreator` для редактирования имени файла
  2. Интегрировать в `FileExplorerTree` для создания файлов как в VSCode
  3. Добавить автоопределение типа файла по расширению в имени
  4. Удалить диалоговое окно создания файлов

#### Задача 3.2: Улучшение проводника файлов
- **Действия:**
  1. Добавить контекстное меню для создания файлов
  2. Реализовать горячие клавиши (Ctrl+N для нового файла)
  3. Добавить шаблоны файлов при создании

### Фаза 4: Тестирование и оптимизация (Приоритет: Средний)

#### Задача 4.1: Комплексное тестирование
- **Действия:**
  1. Протестировать создание файлов в разных типах проектов
  2. Проверить работу Monaco Editor с различными файлами
  3. Убедиться что ModernToast работает корректно

#### Задача 4.2: Оптимизация производительности
- **Действия:**
  1. Оптимизировать загрузку Monaco Editor
  2. Добавить кэширование файлов
  3. Улучшить отзывчивость UI

---

## Детальное описание исправлений

### Исправление проблемы #1:

```dart
// В ProjectService.isProjectAccessible()
Future<bool> isProjectAccessible(Project project) async {
  try {
    if (project.filePath.isEmpty) return false;
    
    // Для папок-проектов проверяем существование директории
    if (project.settings['is_folder_project'] == true) {
      final directory = Directory(project.directory);
      return await directory.exists();
    }
    
    final file = File(project.filePath);
    return await file.exists();
  } catch (e) {
    return false;
  }
}
```

### Исправление проблемы #2:

```dart
// В CreateFileDialog._createFile()
final workspaceProvider = getIt<WorkspaceProvider>();
final fileExplorerProvider = getIt<FileExplorerProvider>();

// Используем текущую директорию из проводника
final currentDir = fileExplorerProvider.currentDirectory;
final fullPath = currentDir.isNotEmpty 
    ? '${fileExplorerProvider.currentDirectory}/$fileName'
    : fileName;
```

### Исправление проблемы #3:

```dart
// Заменить SnackBar на:
success(description: AppLocalizations.of(context)!.fileCreated(fileName));

// И для ошибок:
error(description: AppLocalizations.of(context)!.createFileError(e.toString()));
```

### Исправление проблемы #4:

```dart
// Создать MonacoEditor виджет
class MonacoEditor extends StatefulWidget {
  final String filePath;
  final String language;
  
  // Интеграция с webview_flutter
  // Загрузка Monaco Editor из CDN
  // Настройка языков и тем
}
```

### Исправление проблемы #5:

```dart
// Inline создание файла в FileExplorerTree
Widget _buildInlineFileCreator() {
  return TextField(
    autofocus: true,
    decoration: InputDecoration(
      hintText: 'Введите имя файла...',
    ),
    onSubmitted: (fileName) {
      // Создать файл и обновить дерево
    },
  );
}
```

---

## Порядок выполнения

1. **Фаза 1** (1-2 дня): Критические исправления для стабильности
2. **Фаза 2** (2-3 дня): Интеграция Monaco Editor  
3. **Фаза 3** (2-3 дня): Улучшение UX создания файлов
4. **Фаза 4** (1 день): Тестирование и оптимизация

**Общее время:** 6-9 дней

---

## Риски и митигация

1. **Риск:** Monaco Editor может быть медленным на мобильных устройствах
   **Митигация:** Добавить опцию переключения на простой редактор

2. **Риск:** Сложность интеграции webview_flutter
   **Митигация:** Использовать готовые решения и пошаговую интеграцию

3. **Риск:** Потеря данных при изменении пути создания файлов
   **Митигация:** Тщательное тестирование и валидация путей

4. **Риск:** Обратная совместимость с существующими проектами
   **Митигация:** Сохранить текущую логику как fallback