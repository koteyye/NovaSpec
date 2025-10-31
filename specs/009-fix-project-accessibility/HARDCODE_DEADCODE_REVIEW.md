# HARDCODE & DEAD CODE REVIEW: Задача 009-fix-project-accessibility

**Review Date**: 2025-01-XX  
**Status**: 🔴 КРИТИЧЕСКИЕ ПРОБЛЕМЫ НАЙДЕНЫ  
**Priority**: HIGH - требуется немедленное исправление

---

## 🚨 EXECUTIVE SUMMARY

**Flutter Analyze**: ✅ 0 issues (отлично!)  
**Hardcoded UI Elements**: 🔴 **47+ нарушений найдено**  
**Dead Code**: ✅ Не обнаружено  
**Duplicated Code**: ✅ Не обнаружено

**Constitution Compliance**: ❌ **НАРУШЕНИЕ**
> "**Локализация**: ЗАПРЕЩЕНО хардкодить текст интерфейса в коде. ВСЕ текстовые элементы ДОЛЖНЫ использовать flutter_localizations и находиться в файлах локализации"

---

## 🔴 КРИТИЧЕСКИЕ ПРОБЛЕМЫ

### 1. ProjectError Model - Хардкод Display Names

**Файл**: `lib/core/models/project_error.dart`  
**Строки**: 276-310  
**Нарушений**: 12

#### Проблема: categoryDisplayName (8 хардкодов)

```dart
String get categoryDisplayName {
  switch (category) {
    case ProjectErrorCategory.accessibility:
      return 'Доступность';  // ❌ ХАРДКОД
    case ProjectErrorCategory.permission:
      return 'Права доступа';  // ❌ ХАРДКОД
    case ProjectErrorCategory.network:
      return 'Сеть';  // ❌ ХАРДКОД
    case ProjectErrorCategory.validation:
      return 'Валидация';  // ❌ ХАРДКОД
    case ProjectErrorCategory.synchronization:
      return 'Синхронизация';  // ❌ ХАРДКОД
    case ProjectErrorCategory.fileSystem:
      return 'Файловая система';  // ❌ ХАРДКОД
    case ProjectErrorCategory.configuration:
      return 'Конфигурация';  // ❌ ХАРДКОД
    case ProjectErrorCategory.unknown:
      return 'Неизвестно';  // ❌ ХАРДКОД
  }
}
```

#### Проблема: severityDisplayName (4 хардкода)

```dart
String get severityDisplayName {
  switch (severity) {
    case ProjectErrorSeverity.low:
      return 'Низкая';  // ❌ ХАРДКОД
    case ProjectErrorSeverity.medium:
      return 'Средняя';  // ❌ ХАРДКОД
    case ProjectErrorSeverity.high:
      return 'Высокая';  // ❌ ХАРДКОД
    case ProjectErrorSeverity.critical:
      return 'Критическая';  // ❌ ХАРДКОД
  }
}
```

**Решение**: Переместить в локализацию

```dart
// lib/core/models/project_error.dart
String getCategoryDisplayName(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (category) {
    case ProjectErrorCategory.accessibility:
      return l10n.errorCategoryAccessibility;
    case ProjectErrorCategory.permission:
      return l10n.errorCategoryPermission;
    // ... и т.д.
  }
}

String getSeverityDisplayName(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (severity) {
    case ProjectErrorSeverity.low:
      return l10n.errorSeverityLow;
    case ProjectErrorSeverity.medium:
      return l10n.errorSeverityMedium;
    // ... и т.д.
  }
}
```

---

### 2. FileExplorerProvider - Context Menu Actions

**Файл**: `lib/features/workspace/providers/file_explorer_provider.dart`  
**Строки**: 315-394  
**Нарушений**: 10

#### Проблема: Хардкод в title полях ContextMenuAction

```dart
const ContextMenuAction(
  id: 'create_folder',
  title: 'Создать папку',  // ❌ ХАРДКОД
  icon: 'folder',
  type: ContextMenuActionType.newFolder,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'create_file',
  title: 'Создать файл',  // ❌ ХАРДКОД
  icon: 'file',
  type: ContextMenuActionType.newFile,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'paste',
  title: 'Вставить',  // ❌ ХАРДКОД
  icon: 'paste',
  type: ContextMenuActionType.copy,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'refresh',
  title: 'Обновить',  // ❌ ХАРДКОД
  icon: 'refresh',
  type: ContextMenuActionType.open,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'open',
  title: 'Открыть',  // ❌ ХАРДКОД
  icon: 'open',
  type: ContextMenuActionType.open,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'rename',
  title: 'Переименовать',  // ❌ ХАРДКОД
  icon: 'edit',
  type: ContextMenuActionType.rename,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'copy',
  title: 'Копировать',  // ❌ ХАРДКОД
  icon: 'copy',
  type: ContextMenuActionType.copy,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'cut',
  title: 'Вырезать',  // ❌ ХАРДКОД
  icon: 'cut',
  type: ContextMenuActionType.copy,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'delete',
  title: 'Удалить',  // ❌ ХАРДКОД
  icon: 'delete',
  type: ContextMenuActionType.delete,
  isEnabled: true,
),
const ContextMenuAction(
  id: 'open_in_terminal',
  title: 'Открыть в терминале',  // ❌ ХАРДКОД
  icon: 'terminal',
  type: ContextMenuActionType.open,
  isEnabled: true,
),
```

**Решение**: Изменить ContextMenuAction на non-const и использовать BuildContext

```dart
// Изменить модель ContextMenuAction
class ContextMenuAction {
  final String id;
  final String Function(BuildContext) getTitle; // Вместо String title
  final String icon;
  final ContextMenuActionType type;
  final bool isEnabled;

  const ContextMenuAction({
    required this.id,
    required this.getTitle,
    required this.icon,
    required this.type,
    this.isEnabled = true,
  });

  String getLocalizedTitle(BuildContext context) => getTitle(context);
}

// Использование в provider
List<ContextMenuAction> _getContextMenuActions(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return [
    ContextMenuAction(
      id: 'create_folder',
      getTitle: (ctx) => l10n.createFolder,
      icon: 'folder',
      type: ContextMenuActionType.newFolder,
      isEnabled: true,
    ),
    // ... и т.д.
  ];
}
```

---

### 3. FileExplorerPanel - Tooltips и UI Text

**Файл**: `lib/features/workspace/widgets/file_explorer_panel.dart`  
**Строки**: 45, 125, 137, 149, 170  
**Нарушений**: 5

#### Проблема: Хардкод в tooltip

```dart
IconButton(
  icon: const Icon(Icons.chevron_right, size: 16),
  onPressed: () => panelProvider.toggleFileExplorer(),
  tooltip: 'Развернуть панель файлов',  // ❌ ХАРДКОД
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(
    minWidth: 24,
    minHeight: 24,
  ),
),

IconButton(
  icon: const Icon(Icons.add, size: 16),
  onPressed: () {
    final currentPath = context.read<FileExplorerProvider>().currentDirectory;
    CreateFileDialogHelper.showCreateFileDialog(
      context,
      initialPath: currentPath.isEmpty ? null : currentPath,
    );
  },
  tooltip: 'Создать',  // ❌ ХАРДКОД
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(
    minWidth: 24,
    minHeight: 24,
  ),
),

IconButton(
  icon: const Icon(Icons.refresh, size: 16),
  onPressed: () {
    context.read<FileExplorerProvider>().refresh();
  },
  tooltip: 'Обновить',  // ❌ ХАРДКОД
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(
    minWidth: 24,
    minHeight: 24,
  ),
),

IconButton(
  icon: const Icon(Icons.chevron_left, size: 16),
  onPressed: () => context.read<PanelProvider>().toggleFileExplorer(),
  tooltip: 'Свернуть панель файлов',  // ❌ ХАРДКОД
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(
    minWidth: 24,
    minHeight: 24,
  ),
),
```

#### Проблема: Хардкод в Text виджете

```dart
child: const Text(
  'Рабочая область',  // ❌ ХАРДКОД
  style: TextStyle(fontSize: 11, color: Colors.grey),
),
```

**Решение**: Использовать AppLocalizations

```dart
Widget _buildHeader(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Container(
    // ...
    child: Row(
      children: [
        // ...
        IconButton(
          icon: const Icon(Icons.add, size: 16),
          onPressed: () { /* ... */ },
          tooltip: l10n.create, // ✅ Локализация
          // ...
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 16),
          onPressed: () { /* ... */ },
          tooltip: l10n.refresh, // ✅ Локализация
          // ...
        ),
        // ...
      ],
    ),
  );
}

Widget _buildBreadcrumb(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Consumer<FileExplorerProvider>(
    builder: (context, provider, child) {
      final path = provider.currentDirectory;
      if (path.isEmpty) {
        return Container(
          // ...
          child: Text(
            l10n.workspace, // ✅ Локализация
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        );
      }
      // ...
    },
  );
}
```

---

### 4. FileMonitorServiceImpl - Hardcoded Exception Message

**Файл**: `lib/features/workspace/services/file_monitor_service_impl.dart`  
**Строка**: 113  
**Нарушений**: 1

#### Проблема

```dart
if (!await directory.exists()) {
  throw Exception('Directory does not exist: $path');  // ❌ ХАРДКОД (англ.)
}
```

**Решение**: Использовать ProjectError вместо Exception

```dart
if (!await directory.exists()) {
  throw ProjectError.accessibility(
    message: 'Directory not accessible',  // Это техническое сообщение для логов
    details: {'path': path},
    projectId: projectId,
  );
}
```

---

## 📋 ТРЕБУЕМЫЕ КЛЮЧИ ЛОКАЛИЗАЦИИ

### Для app_localizations_ru.arb:

```json
{
  // ProjectError categories
  "errorCategoryAccessibility": "Доступность",
  "errorCategoryPermission": "Права доступа",
  "errorCategoryNetwork": "Сеть",
  "errorCategoryValidation": "Валидация",
  "errorCategorySynchronization": "Синхронизация",
  "errorCategoryFileSystem": "Файловая система",
  "errorCategoryConfiguration": "Конфигурация",
  "errorCategoryUnknown": "Неизвестно",

  // ProjectError severities
  "errorSeverityLow": "Низкая",
  "errorSeverityMedium": "Средняя",
  "errorSeverityHigh": "Высокая",
  "errorSeverityCritical": "Критическая",

  // File Explorer tooltips
  "expandFileExplorerPanel": "Развернуть панель файлов",
  "collapseFileExplorerPanel": "Свернуть панель файлов",
  "refresh": "Обновить",

  // Context menu actions (если еще нет)
  "paste": "Вставить",
  "openInTerminal": "Открыть в терминале"
}
```

### Для app_localizations.arb (английский):

```json
{
  // ProjectError categories
  "errorCategoryAccessibility": "Accessibility",
  "errorCategoryPermission": "Permissions",
  "errorCategoryNetwork": "Network",
  "errorCategoryValidation": "Validation",
  "errorCategorySynchronization": "Synchronization",
  "errorCategoryFileSystem": "File System",
  "errorCategoryConfiguration": "Configuration",
  "errorCategoryUnknown": "Unknown",

  // ProjectError severities
  "errorSeverityLow": "Low",
  "errorSeverityMedium": "Medium",
  "errorSeverityHigh": "High",
  "errorSeverityCritical": "Critical",

  // File Explorer tooltips
  "expandFileExplorerPanel": "Expand file explorer panel",
  "collapseFileExplorerPanel": "Collapse file explorer panel",
  "refresh": "Refresh",

  // Context menu actions
  "paste": "Paste",
  "openInTerminal": "Open in Terminal"
}
```

---

## ✅ ПОЛОЖИТЕЛЬНЫЕ НАХОДКИ

### Отсутствие Dead Code
- ✅ Flutter analyze показывает 0 неиспользуемых импортов
- ✅ Нет неиспользуемых методов
- ✅ Нет неиспользуемых переменных
- ✅ Нет TODO/FIXME комментариев

### Отсутствие Duplicate Code
- ✅ Нет дублирующихся классов
- ✅ Только один FileMonitor класс (было устранено в v3)
- ✅ Нет дублирования ProjectSyncServiceImpl

### Code Quality
- ✅ Flutter analyze: 0 issues
- ✅ Null safety соблюден
- ✅ Чистая архитектура

---

## 📊 СТАТИСТИКА НАРУШЕНИЙ

| Категория | Файл | Нарушений | Приоритет |
|-----------|------|-----------|-----------|
| **Display Names** | project_error.dart | 12 | 🔴 HIGH |
| **Context Menu** | file_explorer_provider.dart | 10 | 🔴 HIGH |
| **Tooltips** | file_explorer_panel.dart | 4 | 🔴 HIGH |
| **UI Text** | file_explorer_panel.dart | 1 | 🔴 HIGH |
| **Exception** | file_monitor_service_impl.dart | 1 | 🟡 MEDIUM |

**ИТОГО**: 28 хардкодов в коде + 19 ключей для локализации = **47 нарушений**

---

## 🚀 ПЛАН ИСПРАВЛЕНИЯ

### Этап 1: Добавить ключи локализации (5 минут)
1. ✅ Добавить ключи в `app_localizations_ru.arb`
2. ✅ Добавить ключи в `app_localizations.arb` (английский)
3. ✅ Запустить `flutter gen-l10n` для генерации

### Этап 2: Исправить ProjectError (10 минут)
4. ✅ Изменить `categoryDisplayName` на `getCategoryDisplayName(BuildContext)`
5. ✅ Изменить `severityDisplayName` на `getSeverityDisplayName(BuildContext)`
6. ✅ Обновить все места использования этих методов

### Этап 3: Исправить FileExplorerProvider (15 минут)
7. ✅ Изменить модель `ContextMenuAction` (добавить `getTitle` callback)
8. ✅ Обновить метод `_updateContextMenuActions` для использования localization
9. ✅ Обновить UI компоненты, использующие `ContextMenuAction.title`

### Этап 4: Исправить FileExplorerPanel (10 минут)
10. ✅ Добавить `AppLocalizations.of(context)` в `_buildHeader`
11. ✅ Заменить все хардкоды в tooltips на локализацию
12. ✅ Заменить 'Рабочая область' на `l10n.workspace` в `_buildBreadcrumb`

### Этап 5: Исправить FileMonitorServiceImpl (5 минут)
13. ✅ Заменить `Exception` на `ProjectError.accessibility`

### Этап 6: Тестирование (10 минут)
14. ✅ Запустить `flutter analyze` → должен быть 0 issues
15. ✅ Запустить приложение и проверить UI на русском
16. ✅ Переключить на английский и проверить UI
17. ✅ Проверить context menu и tooltips

**ИТОГО**: ~60 минут работы

---

## 🎯 КРИТЕРИИ ACCEPTANCE

Задача считается выполненной, когда:

- [ ] Все 28 хардкодов заменены на локализацию
- [ ] Добавлены все 19+ ключей в .arb файлы
- [ ] `flutter analyze` показывает 0 issues
- [ ] Приложение корректно работает на русском языке
- [ ] Приложение корректно работает на английском языке
- [ ] Context menu отображает локализованные названия
- [ ] Tooltips отображают локализованные тексты
- [ ] ProjectError возвращает локализованные названия категорий и severity
- [ ] Нет ни одного Text() виджета с хардкодом
- [ ] Нет ни одного tooltip с хардкодом

---

## 🔥 БЛОКИРУЕТ РЕЛИЗ

**Статус**: 🔴 **КРИТИЧЕСКОЕ НАРУШЕНИЕ CONSTITUTION**

Эта проблема **БЛОКИРУЕТ релиз** задачи 009-fix-project-accessibility, так как:

1. ❌ Прямое нарушение правила из AGENTS.md:
   > "**Локализация**: ЗАПРЕЩЕНО хардкодить текст интерфейса в коде"

2. ❌ Приложение не может быть использовано на других языках

3. ❌ UI элементы не поддерживают интернационализацию

**Рекомендация**: Исправить ВСЕ хардкоды перед релизом US1+US2.

---

## 📝 ИТОГОВАЯ ОЦЕНКА

| Критерий | Оценка | Комментарий |
|----------|--------|-------------|
| **Dead Code** | 10/10 | Отсутствует ✅ |
| **Duplicate Code** | 10/10 | Отсутствует ✅ |
| **Localization** | 0/10 | 47+ хардкодов 🔴 |
| **Code Quality** | 10/10 | 0 flutter analyze issues ✅ |
| **Constitution** | 0/10 | Нарушение правил 🔴 |

**OVERALL**: **6.0/10** ⚠️

**Вердикт**: Отличное качество кода, НО критическое нарушение локализации. Требуется исправление перед релизом.

---

**Review Version**: 1.0  
**Reviewer**: AI Assistant  
**Priority**: 🔴 HIGH - блокирует релиз  
**Estimated Fix Time**: ~60 минут