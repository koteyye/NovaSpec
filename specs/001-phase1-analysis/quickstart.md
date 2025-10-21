# Быстрый старт: Фаза 1 - Анализ и подготовка

**Дата**: 2025-10-19  
**Цель**: Пошаговое руководство для выполнения анализа TypeScript проекта и настройки Flutter основы

## Предварительные требования

### Инструменты
- Flutter SDK 3.x
- Dart 3.x
- Visual Studio Code или IntelliJ IDEA
- Git

### Доступ к ресурсам
- Репозиторий с TypeScript проектом `nova-spec-ide-studio-main`
- Права на создание Flutter проекта
- SVG иконки (`atlassian-icon.svg`, `novaspec-logo.svg`)

## Шаг 1: Анализ TypeScript проекта

### 1.1 Изучение структуры проекта
```bash
# Проект уже находится в корневой папке
cd nova-spec-ide-studio-main

# Изучите структуру
tree src/
```

### 1.2 Анализ UI компонентов
1. **Используйте готовый анализ**:
   - См. `components-analysis.md` - полный анализ всех компонентов
   - Изучите каталог 45+ UI компонентов shadcn/ui
   - Ознакомьтесь с 6 основными компонентами приложения

2. **Анализ стилей**:
   - Цветовая схема MTS Granat (фиолетовый, серый, желтый)
   - Tailwind CSS конфигурация
   - Темная/светлая тема

3. **Анализ состояния**:
   - React Context для глобального состояния
   - useState/useReducer для локального состояния
   - ThemeContext, SettingsContext, ChatContext

### 1.3 Создание документации
Готовая документация:
- `components-analysis.md` - полный анализ компонентов
- Карта миграции с эквивалентами Flutter
- Рекомендации по архитектуре

## Шаг 2: Настройка Flutter проекта

### 2.1 Создание проекта
```bash
# Создайте новый Flutter проект
flutter create novaspec_flutter
cd novaspec_flutter

# Настройте для desktop поддержки
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

### 2.2 Настройка зависимостей
Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # HTTP и API
  dio: ^5.3.2
  
  # Файлы и хранение
  file_picker: ^6.1.1
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # UI компоненты
  flutter_svg: ^2.0.9
  monaco_editor: ^0.0.1+2
  webview_flutter: ^4.4.2
  
  # Редакторы и рендеринг
  flutter_markdown: ^0.6.18
  flutter_html: ^3.0.0
  
  # Аудио
  audioplayers: ^5.2.1
  
  # State management
  provider: ^6.1.1
  
  # Утилиты
  path_provider: ^2.1.1
  package_info_plus: ^4.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### 2.3 Структура проекта
Создайте базовую структуру:

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes/
│   │   └── app_routes.dart
│   └── themes/
│       └── app_theme.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── utils/
│   │   └── helpers.dart
│   └── services/
│       ├── storage_service.dart
│       ├── api_service.dart
│       └── file_service.dart
├── shared/
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_widget.dart
│   └── models/
│       ├── component_model.dart
│       └── migration_model.dart
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_ru.dart
    └── app_localizations_en.dart
```

## Шаг 3: Интеграция ресурсов

### 3.1 SVG иконки
1. **Скопируйте иконки**:
```bash
# Скопируйте SVG файлы из nova-spec-ide-studio-main
mkdir -p assets/images
cp nova-spec-ide-studio-main/assets/atlassian-icon.svg assets/images/
cp nova-spec-ide-studio-main/assets/novaspec-logo.svg assets/images/
```

2. **Настройте pubspec.yaml**:
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

### 3.2 Настройка локализации
1. **Сгенерируйте локализацию**:
```bash
flutter gen-l10n
```

2. **Настройте MaterialApp**:
```dart
MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('ru'), // Русский
    Locale('en'), // Английский
  ],
  // ...
)
```

## Шаг 4: Создание документации миграции

### 4.1 Карта миграции компонентов
Используйте готовую карту из `components-analysis.md`:

```markdown
# Карта миграции компонентов

## Базовые компоненты
| TypeScript | Flutter | Пакет | Сложность |
|------------|---------|-------|-----------|
| Button | ElevatedButton/TextButton | Material | LOW |
| Dialog | AlertDialog/Dialog | Material | LOW |
| Input | TextField | Material | LOW |
| Select | DropdownButton | Material | MEDIUM |
| Table | DataTable | data_table_2 | MEDIUM |

## Сложные компоненты
| TypeScript | Flutter подход | Сложность | Примечания |
|------------|----------------|-----------|------------|
| AIAssistant | Custom Widget + Monaco | HIGH | Требует Monaco Editor |
| FileExplorer | Custom Widget | MEDIUM | TreeView реализация |
| TextEditor | Monaco Editor | HIGH | Через monaco_editor пакет |
```

### 4.2 Руководство по архитектуре
Создайте `architecture-guide.md`:

```markdown
# Архитектура NovaSpec Flutter

## MVVM паттерн
- View: Flutter виджеты
- ViewModel: Provider/ChangeNotifier
- Model: Data классы

## Dependency Injection
Используйте get_it для регистрации сервисов.

## State Management
Provider для локального состояния, глобальное состояние через сервисы.
```

## Шаг 5: Валидация

### 5.1 Проверка проекта
```bash
# Проверьте зависимости
flutter pub get

# Запустите анализ
flutter analyze

# Проверьте на целевых платформах
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

### 5.2 Проверка ресурсов
```bash
# Убедитесь что SVG иконки доступны
flutter test --integration
# (Примечание: тесты только для проверки ресурсов)
```

## Шаг 6: Завершение

### 6.1 Итоговая проверка
- [ ] Все TypeScript компоненты задокументированы
- [ ] Flutter проект создан и настроен
- [ ] Зависимости установлены без конфликтов
- [ ] SVG ресурсы интегрированы
- [ ] Локализация настроена
- [ ] Документация миграции создана

### 6.2 Подготовка к следующей фазе
- Зафиксируйте все изменения в Git
- Создайте merge request
- Подготовьте демонстрацию для команды

## Частые проблемы

### Проблема: Конфликты версий зависимостей
**Решение**: Используйте `flutter pub deps` для анализа дерева зависимостей

### Проблема: SVG иконки не отображаются
**Решение**: Проверьте путь в pubspec.yaml и перезапустите приложение

### Проблема: Локализация не работает
**Решение**: Убедитесь что сгенерированы файлы локализации и настроены делегаты

## Поддержка

При возникновении проблем:
1. Проверьте официальную документацию Flutter
2. Изучите код TypeScript проекта
3. Консультируйтесь с командой разработки

## Следующие шаги

После завершения Фазы 1:
1. Переходите к Фазе 2: Базовая архитектура и ядро
2. Начните реализацию MVVM паттерна
3. Создайте базовые UI компоненты