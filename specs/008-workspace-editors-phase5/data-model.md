# Модель данных: Workspace and Editors Phase 5.1

**Дата**: 2025-10-26  
**Версия**: 1.0

## Сущности

### WorkspaceTab

Вкладка открытого файла в рабочей области.

```dart
class WorkspaceTab {
  final String id;
  final String filePath;
  final String fileName;
  final FileContentType contentType;
  final TabMode mode;
  final bool isModified;
  final DateTime lastModified;
  final String? content;
  
  // Конструкторы и методы
}
```

**Поля**:
- `id`: Уникальный идентификатор вкладки
- `filePath`: Полный путь к файлу
- `fileName`: Имя файла для отображения
- `contentType`: Тип контента файла
- `mode`: Режим отображения (render/edit)
- `isModified`: Флаг изменений в файле
- `lastModified`: Время последнего изменения
- `content`: Кэшированный контент файла

**Валидация**:
- `filePath` должен существовать
- `fileName` не должен быть пустым
- `id` должен быть уникальным в рамках сессии

### FileExplorerNode

Узел файловой структуры в проводнике.

```dart
class FileExplorerNode {
  final String id;
  final String name;
  final String path;
  final FileNodeType type;
  final List<FileExplorerNode> children;
  final bool isExpanded;
  final bool isRenaming;
  final String? editingName;
  
  // Конструкторы и методы
}
```

**Поля**:
- `id`: Уникальный идентификатор узла
- `name`: Отображаемое имя
- `path`: Полный путь к файлу/папке
- `type`: Тип узла (файл/папка)
- `children`: Дочерние узлы (для папок)
- `isExpanded`: Состояние раскрытия папки
- `isRenaming`: Флаг режима переименования
- `editingName`: Временное имя при переименовании

**Валидация**:
- `name` не должен быть пустым
- `path` должен быть валидным путем
- `children` только для узлов типа `folder`

### WorkspacePanel

Панель рабочего пространства.

```dart
class WorkspacePanel {
  final PanelType type;
  final double width;
  final bool isVisible;
  final bool isResizable;
  final double minWidth;
  final double maxWidth;
  
  // Конструкторы и методы
}
```

**Поля**:
- `type`: Тип панели (explorer, workArea, aiChat)
- `width`: Текущая ширина панели
- `isVisible`: Флаг видимости
- `isResizable`: Возможность изменения размера
- `minWidth`: Минимальная ширина
- `maxWidth`: Максимальная ширина

**Валидация**:
- `width` должен быть в диапазоне [minWidth, maxWidth]
- `minWidth` должен быть > 0

### OpenFile

Открытый файл с метаданными.

```dart
class OpenFile {
  final String path;
  final String name;
  final FileContentType contentType;
  final String content;
  final int size;
  final DateTime lastModified;
  final bool isTextFile;
  final Map<String, dynamic> metadata;
  
  // Конструкторы и методы
}
```

**Поля**:
- `path`: Путь к файлу
- `name`: Имя файла
- `contentType`: Тип контента
- `content**: Содержимое файла
- `size`: Размер в байтах
- `lastModified`: Время изменения
- `isTextFile`: Является ли файл текстовым
- `metadata`: Дополнительные метаданные

**Валидация**:
- `path` должен существовать
- `size` должен быть >= 0
- `content` не должен быть null для текстовых файлов

### ContextMenuAction

Действие контекстного меню.

```dart
class ContextMenuAction {
  final String id;
  final String title;
  final String icon;
  final ContextMenuActionType type;
  final bool isEnabled;
  final VoidCallback? action;
  
  // Конструкторы и методы
}
```

**Поля**:
- `id`: Уникальный идентификатор
- `title`: Заголовок действия
- `icon`: Иконка действия
- `type`: Тип действия
- `isEnabled`: Флаг доступности
- `action`: Обработчик действия

### FileOperation

Операция с файлом.

```dart
class FileOperation {
  final String id;
  final FileOperationType type;
  final String sourcePath;
  final String? targetPath;
  final Map<String, dynamic> parameters;
  final FileOperationStatus status;
  final String? error;
  
  // Конструкторы и методы
}
```

**Поля**:
- `id`: Уникальный идентификатор операции
- `type`: Тип операции
- `sourcePath`: Исходный путь
- `targetPath`: Целевой путь (для переименования/копирования)
- `parameters`: Параметры операции
- `status`: Статус выполнения
- `error`: Ошибка выполнения

## Перечисления

### FileContentType

```dart
enum FileContentType {
  markdown,
  html,
  audio,
  swagger,
  text,
  binary,
  unknown
}
```

### TabMode

```dart
enum TabMode {
  render,
  edit
}
```

### FileNodeType

```dart
enum FileNodeType {
  file,
  folder
}
```

### PanelType

```dart
enum PanelType {
  explorer,
  workArea,
  aiChat
}
```

### ContextMenuActionType

```dart
enum ContextMenuActionType {
  open,
  rename,
  delete,
  copy,
  newFile,
  newFolder
}
```

### FileOperationType

```dart
enum FileOperationType {
  create,
  delete,
  rename,
  copy
}
```

### FileOperationStatus

```dart
enum FileOperationStatus {
  pending,
  inProgress,
  completed,
  failed
}
```

## Отношения между сущностями

```
WorkspaceScreen
├── List<WorkspacePanel> (3 панели: explorer, workArea, aiChat)
├── List<WorkspaceTab> (открытые вкладки)
├── FileExplorerNode (корневой узел файловой структуры)
└── List<OpenFile> (кэш открытых файлов)

WorkspaceTab
├── OpenFile (данные файла)
└── TabMode (режим отображения)

FileExplorerNode
├── List<FileExplorerNode> (дочерние узлы)
└── ContextMenuAction (доступные действия)

FileOperation
├── FileOperationType (тип операции)
└── FileOperationStatus (статус)
```

## Валидационные правила

### WorkspaceTab
- Идентификатор должен быть уникальным
- Путь к файлу должен существовать
- Имя файла не должно быть пустым

### FileExplorerNode
- Путь должен быть валидным
- Имя не должно содержать недопустимых символов
- Дочерние узлы только для папок

### WorkspacePanel
- Ширина должна быть в допустимом диапазоне
- Минимальная ширина должна обеспечивать читаемость

### OpenFile
- Размер файла должен соответствовать реальному
- Контент должен соответствовать типу файла
- Метаданные должны быть валидными JSON

## Состояния и переходы

### TabMode
```
render → edit (кнопка редактирования)
edit → render (кнопка просмотра, сохранение)
```

### FileExplorerNode
```
normal → renaming (контекстное меню → переименовать)
renaming → normal (Enter, Escape, клик вне поля)
```

### WorkspacePanel
```
visible → hidden (кнопка сворачивания)
hidden → visible (кнопка развертывания)
```

### FileOperation
```
pending → inProgress → completed
pending → inProgress → failed
```