# Component Mapping Table: React/TypeScript → Flutter/Dart

## Обзор

Детальная таблица соответствия между всеми компонентами TypeScript проекта и их Flutter эквивалентами. Включает сложность миграции и необходимые зависимости.

## 1. Основные компоненты приложения (Custom Components)

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **AIAssistant.tsx** | `AIAssistant` (StatefulWidget) | Высокая | Provider, monaco_editor, webview_flutter | Сложный компонент с чатом, историей, Monaco Editor |
| **FileExplorer.tsx** | `FileExplorer` (StatefulWidget) | Средняя | file_picker | Дерево файлов с раскрытием/сворачиванием |
| **TextEditor.tsx** | `TextEditor` (StatefulWidget) | Средняя | - | Простой текстовый редактор |
| **SpecPreview.tsx** | `SpecPreview` (StatefulWidget) | Высокая | flutter_markdown, flutter_html, webview_flutter | Поддержка MD/HTML/Swagger |
| **SwaggerViewer.tsx** | `SwaggerViewer` (StatelessWidget) | Средняя | webview_flutter | WebView для Swagger UI |
| **StatusBar.tsx** | `StatusBar` (StatelessWidget) | Низкая | - | Статусная информация |
| **TopBar.tsx** | `TopBar` (StatelessWidget) | Средняя | - | Меню с индикаторами |

### AIAssistant детальная миграция
```dart
// Основные зависимости
dependencies:
  provider: ^6.0.5
  monaco_editor: ^0.0.1+2
  flutter_svg: ^2.0.7
  
// Структура классов
class AIAssistant extends StatefulWidget { ... }
class _AIAssistantState extends State<AIAssistant> { ... }
class Message { ... }
class ChatHistory { ... }
class FileReference { ... }
```

### FileExplorer детальная миграция
```dart
// Зависимости
dependencies:
  file_picker: ^6.1.1
  
// Структура
class FileExplorer extends StatelessWidget { ... }
class FileTreeItem extends StatefulWidget { ... }
class FileNode { ... }
```

## 2. Диалоговые окна (Dialogs)

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **AboutDialog.tsx** | `AboutDialog` (StatelessWidget) | Низкая | - | Стандартный AlertDialog |
| **AddTemplateDialog.tsx** | `AddTemplateDialog` (StatefulWidget) | Средняя | - | Форма добавления шаблона |
| **AddTemplateTypeDialog.tsx** | `AddTemplateTypeDialog` (StatefulWidget) | Средняя | - | Выбор типа шаблона |
| **ErrorDialog.tsx** | `ErrorDialog` (StatelessWidget) | Низкая | - | Показ ошибок |
| **MusicifyDialog.tsx** | `MusicifyDialog` (StatefulWidget) | Средняя | audioplayers | Музыкальные настройки |
| **OnboardingDialog.tsx** | `OnboardingDialog` (StatefulWidget) | Средняя | - | Онбординг страниц |
| **SettingsDialog.tsx** | `SettingsDialog` (StatefulWidget) | Высокая | shared_preferences, flutter_secure_storage | Множество настроек |
| **TemplatesDialog.tsx** | `TemplatesDialog` (StatefulWidget) | Средняя | - | Управление шаблонами |

### Dialog паттерн миграции
```dart
// Базовый класс для всех диалогов
abstract class BaseDialog extends StatelessWidget {
  const BaseDialog({Key? key}) : super(key: key);
  
  Widget build(BuildContext context) {
    return AlertDialog(
      title: buildTitle(context),
      content: buildContent(context),
      actions: buildActions(context),
    );
  }
  
  Widget buildTitle(BuildContext context);
  Widget buildContent(BuildContext context);
  List<Widget> buildActions(BuildContext context);
}

// Пример использования
class AboutDialog extends BaseDialog {
  @override
  Widget buildTitle(BuildContext context) => Text('О программе');
  
  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/novaspec-logo.svg', height: 64),
        SizedBox(height: 16),
        Text('NovaSpec v1.0.0'),
        Text('Создание технических заданий с ИИ'),
      ],
    );
  }
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Закрыть'),
      ),
    ];
  }
}
```

## 3. UI компоненты (49 компонентов)

### 3.1 Формы и ввод данных

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **button.tsx** | `CustomButton` (StatelessWidget) | Средняя | - | 6 вариантов, 4 размера |
| **input.tsx** | `CustomTextField` (StatelessWidget) | Низкая | - | TextField с кастомными стилями |
| **textarea.tsx** | `CustomTextArea` (StatelessWidget) | Низкая | - | TextField с maxLines |
| **select.tsx** | `CustomDropdown` (StatelessWidget) | Средняя | - | DropdownButton |
| **checkbox.tsx** | `CustomCheckbox` (StatelessWidget) | Низкая | - | CheckboxListTile |
| **radio-group.tsx** | `CustomRadioGroup` (StatefulWidget) | Средняя | - | RadioListTile |
| **switch.tsx** | `CustomSwitch` (StatelessWidget) | Низкая | - | Switch |
| **label.tsx** | `CustomLabel` (StatelessWidget) | Низкая | - | Text с стилями |
| **form.tsx** | `CustomForm` (StatefulWidget) | Средняя | - | Form + TextFormField |
| **input-otp.tsx** | `OTPInput` (StatefulWidget) | Средняя | - | Поля для OTP кода |

### Button компонент детальная миграция
```dart
enum ButtonVariant { default, destructive, outline, secondary, ghost, link }
enum ButtonSize { default, small, large, icon }

class CustomButton extends StatelessWidget {
  final ButtonVariant variant;
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Widget? child;
  final bool isLoading;
  
  const CustomButton({
    Key? key,
    this.variant = ButtonVariant.default,
    this.size = ButtonSize.default,
    this.onPressed,
    this.child,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Определение стиля в зависимости от варианта
    ButtonStyle style;
    Widget buttonChild;
    
    switch (variant) {
      case ButtonVariant.default:
        style = ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
        break;
      case ButtonVariant.outline:
        style = OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.outline),
        );
        break;
      case ButtonVariant.ghost:
        style = TextButton.styleFrom(
          backgroundColor: Colors.transparent,
        );
        break;
      // ... другие варианты
    }
    
    // Размеры
    double? height;
    EdgeInsetsGeometry? padding;
    
    switch (size) {
      case ButtonSize.small:
        height = 36;
        padding = EdgeInsets.symmetric(horizontal: 12);
        break;
      case ButtonSize.large:
        height = 44;
        padding = EdgeInsets.symmetric(horizontal: 24);
        break;
      case ButtonSize.icon:
        height = 40;
        padding = EdgeInsets.zero;
        break;
      default:
        height = 40;
        padding = EdgeInsets.symmetric(horizontal: 16);
    }
    
    // Содержимое
    if (isLoading) {
      buttonChild = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      buttonChild = child ?? SizedBox();
    }
    
    return SizedBox(
      height: height,
      child: variant == ButtonVariant.outline
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: buttonChild,
            )
          : variant == ButtonVariant.ghost
              ? TextButton(
                  onPressed: isLoading ? null : onPressed,
                  style: style,
                  child: buttonChild,
                )
              : ElevatedButton(
                  onPressed: isLoading ? null : onPressed,
                  style: style,
                  child: buttonChild,
                ),
    );
  }
}
```

### 3.2 Навигация и меню

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **navigation-menu.tsx** | `NavigationMenu` (StatefulWidget) | Высокая | - | Сложная навигация |
| **menubar.tsx** | `MenuBar` (StatelessWidget) | Средняя | - | Row с кнопками |
| **dropdown-menu.tsx** | `DropdownMenu` (StatelessWidget) | Средняя | - | PopupMenuButton |
| **context-menu.tsx** | `ContextMenu` (StatelessWidget) | Средняя | - | GestureDetector + Menu |
| **breadcrumb.tsx** | `Breadcrumb` (StatelessWidget) | Низкая | - | Row с Text/Icon |
| **tabs.tsx** | `CustomTabs` (StatefulWidget) | Средняя | - | TabBar + TabBarView |
| **pagination.tsx** | `Pagination` (StatefulWidget) | Средняя | - | Row с кнопками |

### 3.3 Диалоги и окна

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **dialog.tsx** | `CustomDialog` (StatelessWidget) | Средняя | - | AlertDialog |
| **alert-dialog.tsx** | `AlertDialog` (StatelessWidget) | Низкая | - | AlertDialog |
| **drawer.tsx** | `Drawer` (StatelessWidget) | Низкая | - | Drawer |
| **sheet.tsx** | `BottomSheet` (StatelessWidget) | Средняя | - | showModalBottomSheet |
| **popover.tsx** | `Popover` (StatelessWidget) | Высокая | - | Overlay + Positioned |

### 3.4 Уведомления и обратная связь

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **alert.tsx** | `CustomAlert` (StatelessWidget) | Низкая | - | Container с иконкой |
| **toast.tsx** | `Toast` (StatelessWidget) | Средняя | - | Overlay + Positioned |
| **toaster.tsx** | `ToastManager` (StatefulWidget) | Высокая | - | Управление toast |
| **sonner.tsx** | `SonnerToast` (StatelessWidget) | Средняя | - | SnackBar |
| **progress.tsx** | `ProgressBar` (StatelessWidget) | Низкая | - | LinearProgressIndicator |
| **skeleton.tsx** | `Skeleton` (StatelessWidget) | Средняя | - | Container с анимацией |
| **loading-widget.tsx** | `LoadingWidget` (StatelessWidget) | Низкая | - | CircularProgressIndicator |

### 3.5 Отображение данных

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **card.tsx** | `CustomCard` (StatelessWidget) | Низкая | - | Card + Column |
| **table.tsx** | `CustomTable` (StatelessWidget) | Высокая | - | DataTable |
| **accordion.tsx** | `Accordion` (StatefulWidget) | Средняя | - | ExpansionPanelList |
| **collapsible.tsx** | `Collapsible` (StatefulWidget) | Средняя | - | AnimatedSize |
| **scroll-area.tsx** | `ScrollArea` (StatelessWidget) | Низкая | - | SingleChildScrollView |
| **separator.tsx** | `Separator` (StatelessWidget) | Низкая | - | Divider |
| **badge.tsx** | `Badge` (StatelessWidget) | Низкая | - | Container + Text |
| **avatar.tsx** | `Avatar` (StatelessWidget) | Средняя | - | CircleAvatar |

### 3.6 Интерактивные элементы

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **slider.tsx** | `CustomSlider` (StatefulWidget) | Низкая | - | Slider |
| **toggle.tsx** | `Toggle` (StatefulWidget) | Низкая | - | ToggleButtons |
| **toggle-group.tsx** | `ToggleGroup` (StatefulWidget) | Средняя | - | ToggleButtons |
| **resizable.tsx** | `Resizable` (StatefulWidget) | Высокая | - | GestureDetector + LayoutBuilder |
| **command.tsx** | `CommandPalette` (StatefulWidget) | Высокая | - | Overlay + TextField |

### 3.7 Вспомогательные компоненты

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **tooltip.tsx** | `Tooltip` (StatelessWidget) | Низкая | - | Tooltip |
| **hover-card.tsx** | `HoverCard` (StatefulWidget) | Средняя | - | MouseRegion |
| **aspect-ratio.tsx** | `AspectRatio` (StatelessWidget) | Низкая | - | AspectRatio |
| **calendar.tsx** | `Calendar` (StatefulWidget) | Высокая | - | Custom календарь |
| **chart.tsx** | `Chart` (StatelessWidget) | Высокая | fl_chart | Графики |
| **carousel.tsx** | `Carousel` (StatefulWidget) | Средняя | carousel_slider | Карусель |

### 3.8 Хуки

| TypeScript компонент | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **use-toast.ts** | `ToastManager` (StatefulWidget) | Средняя | - | Provider паттерн |

## 4. Стили и темы

| TypeScript концепция | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **Tailwind CSS** | `ThemeData` | Средняя | - | Material Design 3 |
| **CVA варианты** | `enum` параметры | Низкая | - | Перечисления |
| **CSS переменные** | `ColorScheme` | Низкая | - | Цветовая схема |
| **Темная тема** | `darkTheme` | Низкая | - | Встроенная поддержка |
| **Анимации** | `AnimationController` | Средняя | - | Flutter анимации |

## 5. Интеграции

| TypeScript библиотека | Flutter эквивалент | Сложность | Зависимости | Примечания |
|---------------------|-------------------|-----------|-------------|------------|
| **Radix UI** | Material widgets | Низкая | - | Встроенная доступность |
| **Lucide React** | Icons | Низкая | - | Material Icons |
| **Sonner** | SnackBar | Низкая | - | Встроенные уведомления |
| **Swagger UI** | webview_flutter | Средняя | webview_flutter | WebView |
| **File picker** | file_picker | Низкая | file_picker | Пакет доступен |

## 6. Приоритеты миграции

### Фаза 1: Базовые UI компоненты (Приоритет: Высокий)
1. **button.tsx** → `CustomButton`
2. **input.tsx** → `CustomTextField`
3. **textarea.tsx** → `CustomTextArea`
4. **dialog.tsx** → `CustomDialog`
5. **tooltip.tsx** → `Tooltip`

### Фаза 2: Компоненты приложения (Приоритет: Высокий)
1. **FileExplorer.tsx** → `FileExplorer`
2. **TextEditor.tsx** → `TextEditor`
3. **StatusBar.tsx** → `StatusBar`
4. **TopBar.tsx** → `TopBar`

### Фаза 3: Сложные компоненты (Приоритет: Средний)
1. **SpecPreview.tsx** → `SpecPreview`
2. **SwaggerViewer.tsx** → `SwaggerViewer`
3. **AIAssistant.tsx** → `AIAssistant`

### Фаза 4: Остальные UI компоненты (Приоритет: Низкий)
1. **table.tsx** → `CustomTable`
2. **calendar.tsx** → `Calendar`
3. **chart.tsx** → `Chart`
4. **command.tsx** → `CommandPalette`

## 7. Оценка трудозатрат

| Компонент | Часы на миграцию | Сложность | Риски |
|-----------|------------------|-----------|-------|
| CustomButton | 8-12 часов | Средняя | Варианты стилей |
| CustomTextField | 4-6 часов | Низкая | Валидация |
| CustomDialog | 6-8 часов | Средняя | Анимации |
| FileExplorer | 16-24 часов | Средняя | Рекурсия, состояние |
| TextEditor | 8-12 часов | Средняя | Monaco Editor |
| AIAssistant | 40-60 часов | Высокая | Чат, Monaco, состояние |
| SpecPreview | 24-36 часов | Высокая | Markdown, HTML, Swagger |
| Все UI компоненты | 120-160 часов | Средняя | 49 компонентов |

**Итого:** ~226-324 часов на полную миграцию компонентов

## 8. Рекомендации по реализации

### 1. Создать базовые классы
```dart
abstract class BaseWidget extends StatelessWidget {
  const BaseWidget({Key? key}) : super(key: key);
  
  @protected
  ThemeData getTheme(BuildContext context) => Theme.of(context);
  
  @protected
  TextTheme getTextTheme(BuildContext context) => Theme.of(context).textTheme;
  
  @protected
  ColorScheme getColorScheme(BuildContext context) => Theme.of(context).colorScheme;
}
```

### 2. Использовать enum для вариантов
```dart
enum ButtonVariant { primary, secondary, outline, ghost, destructive }
enum ButtonSize { small, medium, large, icon }
enum InputVariant { outlined, filled, underlined }
```

### 3. Создать систему тем
```dart
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      // Кастомные компоненты темы
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}
```

### 4. Использовать Provider для состояния
```dart
class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// В main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppState()),
    // Другие провайдеры
  ],
  child: Consumer<AppState>(
    builder: (context, appState, child) {
      return MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        // ...
      );
    },
  ),
)
```