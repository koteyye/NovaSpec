# Отчет по ревью: Нарушения использования стандартных Flutter тостов

**Дата ревью**: 2025-01-XX  
**Ревьюер**: AI Agent  
**Статус**: ⚠️ КРИТИЧЕСКИЕ НАРУШЕНИЯ ОБНАРУЖЕНЫ  
**Приоритет**: P1 - Высокий

---

## 🔴 Краткое резюме

**Обнаружено**: **24 нарушения** использования стандартных Flutter `SnackBar` и `ScaffoldMessenger`  
**Правило проекта**: FR-016 из AGENTS.md - "Стандартные Flutter компоненты (кнопки, диалоги, снэкбары и другие) ЗАПРЕЩЕНЫ"  
**Должно использоваться**: Кастомный `ToastService` из `lib/core/services/toast_service.dart`

---

## 📊 Статистика нарушений

| Категория | Количество | Приоритет |
|-----------|------------|-----------|
| Диалоги создания/сохранения проекта | 4 | 🔴 Высокий |
| File renderers | 16 | 🟡 Средний |
| Поисковый диалог | 2 | 🟡 Средний |
| AI Chat placeholder | 1 | 🟢 Низкий |
| Demo страница | 1 | 🟢 Низкий |
| **ИТОГО** | **24** | - |

---

## 📁 Детальный список нарушений

### 🔴 Критический приоритет (4 нарушения)

#### 1. `lib/app/screens/main_screen.dart` - Диалоги проекта

**Класс**: `_CreateProjectDialogState`

**Нарушение #1** (строка 607-609):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Введите имя проекта'))
);
```

**Нарушение #2** (строка 614-616):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Выберите директорию'))
);
```

**Класс**: `_SaveProjectAsDialogState`

**Нарушение #3** (строка 726-728):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Введите имя проекта'))
);
```

**Нарушение #4** (строка 733-735):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Выберите директорию'))
);
```

**Почему критично**: Эти диалоги используются для основной функциональности - создания и сохранения проектов. Пользователи часто видят эти сообщения.

**Рекомендуемое исправление**:
```dart
// Вместо ScaffoldMessenger
import '../../../core/services/toast_service.dart' as toast;

// В методе валидации
if (_nameController.text.trim().isEmpty) {
  toast.ToastService().showError(
    description: 'Введите имя проекта',
  );
  return;
}

if (_directoryController.text.trim().isEmpty) {
  toast.ToastService().showError(
    description: 'Выберите директорию',
  );
  return;
}
```

---

### 🟡 Средний приоритет (18 нарушений)

#### 2. `lib/features/workspace/widgets/file_renderers/code_editor.dart`

**Класс**: `_CodeEditorState`

**Нарушение #5** (строка 71-76):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Файл сохранен'),
    backgroundColor: Colors.green,
  ),
);
```

**Нарушение #6** (строка 79-86):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Ошибка сохранения: $e'),
    backgroundColor: Colors.red,
  ),
);
```

**Нарушение #7** (строка 121-128):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
  ),
);
```

**Рекомендуемое исправление**:
```dart
import '../../../../../core/services/toast_service.dart' as toast;

// Успешное сохранение
toast.ToastService().showSuccess(
  description: 'Файл сохранен',
);

// Ошибка сохранения
toast.ToastService().showError(
  description: 'Ошибка сохранения: $e',
);

// Метод _showError
void _showError(String message) {
  toast.ToastService().showError(
    description: message,
  );
}
```

---

#### 3. `lib/features/workspace/widgets/file_renderers/audio_player.dart`

**Класс**: `_AudioPlayerWidgetState`

**Нарушение #8** (строка 451-458):
```dart
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../../core/services/toast_service.dart' as toast;

void _showError(String message) {
  toast.ToastService().showError(
    description: message,
  );
}
```

---

#### 4. `lib/features/workspace/widgets/file_renderers/image_viewer.dart`

**Класс**: `_ImageViewerState`

**Нарушение #9** (строка 355-360):
```dart
void _copyFilePath() {
  // TODO: Implement clipboard functionality
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Путь скопирован в буфер обмена')),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../../core/services/toast_service.dart' as toast;

void _copyFilePath() {
  // TODO: Implement clipboard functionality
  toast.ToastService().showSuccess(
    description: 'Путь скопирован в буфер обмена',
  );
}
```

---

#### 5. `lib/features/workspace/widgets/file_renderers/pdf_viewer.dart`

**Класс**: `_PdfViewerState`

**Нарушение #10** (строка 583-587):
```dart
void _printPdf() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Функция печати будет доступна в следующей версии')),
  );
}
```

**Нарушение #11** (строка 589-593):
```dart
void _exportPdf() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Функция экспорта будет доступна в следующей версии')),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../../core/services/toast_service.dart' as toast;

void _printPdf() {
  toast.ToastService().showInfo(
    description: 'Функция печати будет доступна в следующей версии',
  );
}

void _exportPdf() {
  toast.ToastService().showInfo(
    description: 'Функция экспорта будет доступна в следующей версии',
  );
}
```

---

#### 6. `lib/features/workspace/widgets/file_renderers/swagger_viewer.dart`

**Класс**: `_SwaggerViewerState`

**Нарушение #12** (строка 372-377):
```dart
Future<void> _openInBrowser() async {
  // TODO: Implement opening in external browser
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Функция открытия в браузере будет добавлена')),
  );
}
```

**Нарушение #13** (строка 448-453):
```dart
onPressed: () {
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Экспорт будет добавлен в следующей версии')),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../../core/services/toast_service.dart' as toast;

Future<void> _openInBrowser() async {
  toast.ToastService().showInfo(
    description: 'Функция открытия в браузере будет добавлена',
  );
}

// В onPressed
onPressed: () {
  Navigator.pop(context);
  toast.ToastService().showInfo(
    description: 'Экспорт будет добавлен в следующей версии',
  );
}
```

---

#### 7. `lib/features/workspace/widgets/file_renderers/unsupported_file_viewer.dart`

**Класс**: `_UnsupportedFileViewerState`

**Нарушение #14** (строка 48-55):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Файл сохранен в: $result'),
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),
);
```

**Нарушение #15** (строка 58-65):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Ошибка сохранения файла: $e'),
    backgroundColor: Theme.of(context).colorScheme.error,
  ),
);
```

**Нарушение #16** (строка 78-85):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Содержимое скопировано в буфер обмена'),
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),
);
```

**Нарушение #17** (строка 87-94):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Ошибка копирования: $e'),
    backgroundColor: Theme.of(context).colorScheme.error,
  ),
);
```

**Рекомендуемое исправление**:
```dart
import '../../../../../core/services/toast_service.dart' as toast;

// Успешное сохранение
toast.ToastService().showSuccess(
  description: 'Файл сохранен в: $result',
);

// Ошибка сохранения
toast.ToastService().showError(
  description: 'Ошибка сохранения файла: $e',
);

// Успешное копирование
toast.ToastService().showSuccess(
  description: 'Содержимое скопировано в буфер обмена',
);

// Ошибка копирования
toast.ToastService().showError(
  description: 'Ошибка копирования: $e',
);
```

---

#### 8. `lib/features/workspace/widgets/file_renderers/video_viewer.dart`

**Класс**: `_VideoViewerState`

**Нарушение #18** (строка 344-349):
```dart
void _toggleFullscreen() {
  // TODO: Implement fullscreen functionality
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Полноэкранный режим будет добавлен в следующей версии')),
  );
}
```

**Нарушение #19** (строка 496-500):
```dart
void _showQualityDialog() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Изменение качества будет доступно в следующей версии')),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../../core/services/toast_service.dart' as toast;

void _toggleFullscreen() {
  toast.ToastService().showInfo(
    description: 'Полноэкранный режим будет добавлен в следующей версии',
  );
}

void _showQualityDialog() {
  toast.ToastService().showInfo(
    description: 'Изменение качества будет доступно в следующей версии',
  );
}
```

---

#### 9. `lib/features/workspace/widgets/search_dialog.dart`

**Класс**: `_SearchDialogState`

**Нарушение #20** (строка 126-134):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Ошибка поиска: $e'),
    backgroundColor: Colors.red,
  ),
);
```

**Нарушение #21** (строка 182-191):
```dart
void _showFileInExplorer(FileExplorerNode file) {
  // TODO: Implement showing file in explorer
  Navigator.of(context).pop();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Файл "${file.name}" найден'),
      backgroundColor: Colors.green,
    ),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../core/services/toast_service.dart' as toast;

// Ошибка поиска
toast.ToastService().showError(
  description: 'Ошибка поиска: $e',
);

// Файл найден
void _showFileInExplorer(FileExplorerNode file) {
  Navigator.of(context).pop();
  toast.ToastService().showSuccess(
    description: 'Файл "${file.name}" найден',
  );
}
```

---

### 🟢 Низкий приоритет (2 нарушения)

#### 10. `lib/features/workspace/widgets/ai_chat_placeholder.dart`

**Класс**: `AIChatPlaceholder`

**Нарушение #22** (строка 319-327):
```dart
onPressed: () {
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Вы подписаны на уведомления!'),
      backgroundColor: Colors.green,
    ),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../core/services/toast_service.dart' as toast;

onPressed: () {
  Navigator.pop(context);
  toast.ToastService().showSuccess(
    description: 'Вы подписаны на уведомления!',
  );
}
```

---

#### 11. `lib/features/workspace/screens/file_explorer_demo_page.dart`

**Класс**: `_FileExplorerDemoPageState`

**Нарушение #23** (строка 346-353):
```dart
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Directory picker not implemented yet'),
      backgroundColor: Colors.orange,
    ),
  );
}
```

**Рекомендуемое исправление**:
```dart
import '../../../../core/services/toast_service.dart' as toast;

if (mounted) {
  toast.ToastService().showWarning(
    description: 'Directory picker not implemented yet',
  );
}
```

---

### ✅ Правильная реализация (для сравнения)

#### Хорошие примеры из проекта:

**1. `lib/core/utils/helpers.dart`** - метод `showSnackBar`:
```dart
static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
  // Use ToastService instead of ScaffoldMessenger
  if (backgroundColor == Colors.green || backgroundColor == Colors.lightGreen) {
    success(description: message);
  } else if (backgroundColor == Colors.red || backgroundColor == Colors.redAccent) {
    error(description: message);
  } else if (backgroundColor == Colors.orange || backgroundColor == Colors.amber) {
    warning(description: message);
  } else {
    show(description: message);
  }
}
```

**2. `lib/features/project/providers/project_provider.dart`** - метод `_showSnackBar`:
```dart
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
```

**3. `lib/features/workspace/widgets/create_file_dialog.dart`** (из задачи 010):
```dart
import '../../../core/services/toast_service.dart' as toast;

// Успех
toast.ToastService().showSuccess(
  description: l10n.fileCreated(fileName),
);

// Ошибка
toast.ToastService().showError(
  description: errorMessage,
);
```

---

## 🛠️ План исправления

### Приоритет 1: Критические нарушения (4 файла)

1. ✅ `lib/app/screens/main_screen.dart`
   - Исправить 4 использования в диалогах создания/сохранения проекта
   - Добавить локализацию сообщений об ошибках

### Приоритет 2: Средний (6 файлов)

2. ✅ `lib/features/workspace/widgets/file_renderers/code_editor.dart` (3 нарушения)
3. ✅ `lib/features/workspace/widgets/file_renderers/audio_player.dart` (1 нарушение)
4. ✅ `lib/features/workspace/widgets/file_renderers/image_viewer.dart` (1 нарушение)
5. ✅ `lib/features/workspace/widgets/file_renderers/pdf_viewer.dart` (2 нарушения)
6. ✅ `lib/features/workspace/widgets/file_renderers/swagger_viewer.dart` (2 нарушения)
7. ✅ `lib/features/workspace/widgets/file_renderers/unsupported_file_viewer.dart` (4 нарушения)
8. ✅ `lib/features/workspace/widgets/file_renderers/video_viewer.dart` (2 нарушения)
9. ✅ `lib/features/workspace/widgets/search_dialog.dart` (2 нарушения)

### Приоритет 3: Низкий (2 файла)

10. ✅ `lib/features/workspace/widgets/ai_chat_placeholder.dart` (1 нарушение)
11. ✅ `lib/features/workspace/screens/file_explorer_demo_page.dart` (1 нарушение)

---

## 📋 Чеклист для каждого файла

При исправлении каждого файла необходимо:

- [ ] Добавить импорт: `import '...путь.../toast_service.dart' as toast;`
- [ ] Заменить все `ScaffoldMessenger.of(context).showSnackBar(...)` на `toast.ToastService().showXXX(...)`
- [ ] Выбрать правильный метод ToastService:
  - `showSuccess()` - для успешных операций (зеленый)
  - `showError()` - для ошибок (красный)
  - `showWarning()` - для предупреждений (оранжевый)
  - `showInfo()` - для информационных сообщений
  - `show()` - для нейтральных сообщений
- [ ] Добавить локализацию для хардкодных строк (где необходимо)
- [ ] Убрать `backgroundColor` параметры (ToastService сам определяет цвета)
- [ ] Проверить работоспособность после исправления
- [ ] Запустить `flutter analyze` - должно быть 0 ошибок

---

## 🎯 API ToastService

Для справки, доступные методы:

```dart
import 'package:novaspec/core/services/toast_service.dart' as toast;

// Успех (зеленый)
toast.ToastService().showSuccess(
  description: 'Операция выполнена успешно',
);

// Ошибка (красный)
toast.ToastService().showError(
  description: 'Произошла ошибка',
);

// Предупреждение (оранжевый)
toast.ToastService().showWarning(
  description: 'Внимание!',
);

// Информация (синий)
toast.ToastService().showInfo(
  description: 'Информационное сообщение',
);

// Нейтральный (серый)
toast.ToastService().show(
  description: 'Обычное сообщение',
);
```

Также есть сокращенные глобальные функции:
```dart
success(description: 'Успех');
error(description: 'Ошибка');
warning(description: 'Предупреждение');
show(description: 'Сообщение');
```

---

## 📈 Метрики качества

### До исправления:
- ✅ Использование кастомного ToastService: ~85%
- ❌ Использование стандартного SnackBar: ~15%
- ⚠️ Нарушений правил проекта: 24

### После исправления (целевые метрики):
- ✅ Использование кастомного ToastService: 100%
- ✅ Использование стандартного SnackBar: 0%
- ✅ Нарушений правил проекта: 0

---

## ⚠️ Важные замечания

1. **НЕ использовать** `ScaffoldMessenger` нигде в проекте
2. **НЕ использовать** `SnackBar` виджет
3. **ВСЕГДА использовать** `ToastService` для уведомлений
4. **Добавлять локализацию** для всех пользовательских сообщений
5. **Проверять** `flutter analyze` после каждого исправления

---

## 🎯 Критерии приемки

Задача считается выполненной, когда:

- [ ] Все 24 нарушения исправлены
- [ ] `flutter analyze` показывает 0 ошибок/предупреждений
- [ ] Все сообщения используют ToastService
- [ ] Пользовательские строки локализованы
- [ ] Ручное тестирование подтверждает работоспособность

---

## 📝 Итоговая рекомендация

**Статус**: ⚠️ Требуется исправление

**Рекомендация**: Создать задачу **011-replace-standard-snackbars** с приоритетом P1 для устранения всех нарушений.

**Оценка трудоемкости**: ~2-3 часа работы

**Риски**: Низкие - простая замена без изменения логики

**Польза**: 
- Соответствие правилам проекта
- Единообразный UX для пользователей
- Улучшенная визуальная идентичность

---

**Конец отчета**