# Quick Start: Workspace and Editors Phase 5.1

**Дата**: 2025-10-26  
**Версия**: 1.0

## Обзор

Рабочее пространство NovaSpec с тремя панелями: файловый проводник, рабочая область с вкладками, и AI чат заглушка. Поддержка различных типов файлов и операций управления.

## Ключевые компоненты

### 1. WorkspaceScreen
Главный экран рабочего пространства с тремя панелями.

```dart
class WorkspaceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Файловый проводник
        FileExplorerPanel(),
        
        // Рабочая область с вкладками
        Expanded(child: WorkAreaPanel()),
        
        // AI чат заглушка
        AIChatPanel(),
      ],
    );
  }
}
```

### 2. FileExplorerPanel
Левая панель с файловой структурой проекта.

```dart
class FileExplorerPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FileExplorerProvider>(
      builder: (context, provider, child) {
        return Container(
          width: provider.panelWidth,
          child: Column(
            children: [
              // Заголовок проводника
              ExplorerHeader(),
              
              // Дерево файлов
              Expanded(child: FileTree()),
            ],
          ),
        );
      },
    );
  }
}
```

### 3. WorkAreaPanel
Центральная панель с вкладками и контентом.

```dart
class WorkAreaPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Панель вкладок
            TabBar(tabs: provider.tabs),
            
            // Область контента
            Expanded(
              child: provider.currentTab != null
                ? FileContentRenderer(tab: provider.currentTab!)
                : EmptyWorkspacePlaceholder(),
            ),
          ],
        );
      },
    );
  }
}
```

## Провайдеры состояния

### WorkspaceProvider
Основной провайдер рабочего пространства.

```dart
class WorkspaceProvider extends ChangeNotifier {
  List<WorkspacePanel> _panels = [];
  List<WorkspaceTab> _tabs = [];
  WorkspaceTab? _currentTab;
  
  // Геттеры
  List<WorkspacePanel> get panels => _panels;
  List<WorkspaceTab> get tabs => _tabs;
  WorkspaceTab? get currentTab => _currentTab;
  
  // Методы
  void openTab(String filePath) { /* ... */ }
  void closeTab(String tabId) { /* ... */ }
  void switchTab(String tabId) { /* ... */ }
  void saveTab(String tabId) { /* ... */ }
}
```

### FileExplorerProvider
Провайдер файлового проводника.

```dart
class FileExplorerProvider extends ChangeNotifier {
  FileExplorerNode? _rootNode;
  List<ContextMenuAction> _contextActions = [];
  
  // Геттеры
  FileExplorerNode? get rootNode => _rootNode;
  List<ContextMenuAction> get contextActions => _contextActions;
  
  // Методы
  Future<void> loadDirectory(String path) { /* ... */ }
  void toggleNodeExpansion(String nodeId) { /* ... */ }
  void showContextMenu(String nodeId) { /* ... */ }
  Future<void> createFile(String parentPath, String name) { /* ... */ }
  Future<void> deleteFile(String path) { /* ... */ }
  Future<void> renameFile(String path, String newName) { /* ... */ }
}
```

## Рендереры файлов

### MarkdownRenderer
Рендеринг markdown файлов.

```dart
class MarkdownRenderer extends StatelessWidget {
  final String content;
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Панель инструментов
        RendererToolbar(
          onEdit: onEdit,
          onCopy: onCopy,
        ),
        
        // Markdown контент
        Expanded(
          child: Markdown(data: content),
        ),
      ],
    );
  }
}
```

### CodeEditor
Редактор кода на основе Monaco Editor.

```dart
class CodeEditor extends StatelessWidget {
  final String content;
  final String language;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSave;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Панель инструментов
        EditorToolbar(
          onSave: onSave,
        ),
        
        // Monaco Editor
        Expanded(
          child: MonacoEditor(
            value: content,
            language: language,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
```

## Контекстное меню

### ContextMenu
Кастомное контекстное меню.

```dart
class ContextMenu extends StatelessWidget {
  final List<ContextMenuAction> actions;
  final VoidCallback? onClose;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) => 
          ContextMenuItem(action: action)
        ).toList(),
      ),
    );
  }
}
```

## Интеграция с DI

### Регистрация сервисов

```dart
// В di_container.dart
void setupWorkspaceServices() {
  // Провайдеры
  getIt.registerSingleton<WorkspaceProvider>(WorkspaceProvider());
  getIt.registerSingleton<FileExplorerProvider>(FileExplorerProvider());
  getIt.registerSingleton<TabProvider>(TabProvider());
  
  // Сервисы
  getIt.registerSingleton<FileService>(FileService());
  getIt.registerSingleton<WorkspaceService>(WorkspaceService());
  getIt.registerSingleton<ClipboardService>(ClipboardService());
}
```

## Навигация

### Маршрутизация

```dart
// В app.dart
class NovaSpecApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/workspace': (context) => WorkspaceScreen(),
      },
      initialRoute: '/workspace',
    );
  }
}
```

## Локализация

### Поддерживаемые языки

```dart
// В app_localizations.dart
class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ru', 'RU'),
  ];
  
  // Workspace строки
  String get fileExplorer => 'File Explorer';
  String get workArea => 'Work Area';
  String get aiChat => 'AI Chat';
  String get openFile => 'Open File';
  String get saveFile => 'Save File';
  String get deleteFile => 'Delete File';
  String get renameFile => 'Rename File';
  String get copyFile => 'Copy File';
  String get newFile => 'New File';
  String get newFolder => 'New Folder';
}
```

## Тестирование

### Ручное тестирование

1. **Открытие проекта**: Проверить отображение файловой структуры
2. **Работа с вкладками**: Открыть несколько файлов, переключаться между вкладками
3. **Рендеринг файлов**: Проверить корректное отображение разных типов файлов
4. **Операции с файлами**: Создать, переименовать, удалить, скопировать файлы
5. **Изменение размеров панелей**: Проверить изменение размеров и сворачивание
6. **Сохранение изменений**: Проверить сохранение изменений в файлах

## Производительность

### Оптимизации

- Ленивая загрузка контента вкладок
- Кэширование отрендеренного контента
- Асинхронная загрузка больших файлов
- Оптимизация рендеринга файлового дерева

### Метрики

- Открытие файлов < 1 секунды
- Поддержка до 20 вкладок
- Рендеринг markdown < 2 секунд
- Плавная работа на 4GB RAM