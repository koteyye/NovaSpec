# Быстрый старт Фазы 3: Онбординг и верхняя панель

## Начало работы

### Предварительные требования
- Установлен Flutter 3.x
- Фаза 2 NovaSpec завершена (функциональность настроек работает)
- Ветка git `003-onboarding-topbar` выбрана

### Начальная настройка
```bash
# Убедитесь, что вы на правильной ветке
git checkout 003-onboarding-topbar

# Запустите Flutter для проверки настройки
flutter run
```

## Рабочий процесс разработки

### 1. Реализация диалога онбординга
**Файл**: `lib/features/onboarding/screens/onboarding_dialog.dart`

```dart
// Базовая структура соответствующая эталону TypeScript
class OnboardingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 300,
        child: Column(
          children: [
            // Заголовок соответствующий дизайну TypeScript
            Text('Добро пожаловать в NovaSpec'),
            // Компоненты ModernButton для действий
            ModernButton(
              text: 'Создать новый проект',
              onPressed: () => _createProject(context),
            ),
            ModernButton(
              text: 'Открыть существующий проект', 
              onPressed: () => _openProject(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Настройка сервиса проектов
**Файл**: `lib/core/services/project_service.dart`

```dart
class ProjectService {
  Future<Project> createProject(String name, String directory) async {
    // Валидация входных данных
    // Создание файла .novaspec
    // Возврат объекта Project
  }
  
  Future<Project> openProject(String filePath) async {
    // Загрузка и парсинг файла .novaspec
    // Возврат объекта Project
  }
}
```

### 3. Компонент верхней панели
**Файл**: `lib/features/topbar/widgets/top_bar.dart` (Windows/Linux)

```dart
class TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      child: Row(
        children: [
          // Имя проекта
          Text(_projectName),
          // Меню файла используя CustomStyledDropdown
          CustomStyledDropdown(
            items: ['Новый', 'Открыть', 'Сохранить', 'Сохранить как', 'Выход'],
            onSelected: _handleFileAction,
          ),
          // Меню редактирования
          CustomStyledDropdown(
            items: ['Отменить', 'Повторить', 'Вырезать', 'Копировать', 'Вставить'],
            onSelected: _handleEditAction,
          ),
          // Индикаторы статуса
          Spacer(),
          Text(_projectStatus),
        ],
      ),
    );
  }
}
```

**Файл**: `lib/features/topbar/widgets/macos_menu_bar.dart` (macOS)
```dart
class MacOSMenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Использование системной панели меню macOS
    return MenuBar(
      children: [
        Menu(label: 'Файл', children: [
          MenuItem(label: 'Новый', shortcut: 'Cmd+N'),
          MenuItem(label: 'Открыть', shortcut: 'Cmd+O'),
          // ...
        ]),
      ],
    );
  }
}
```

## Ключевые замечания по реализации

### Соответствие конституции
- **ДОЛЖЕН** использовать ModernButton для всех действий
- **ДОЛЖЕН** использовать CustomStyledDropdown для меню
- **ДОЛЖЕН** использовать ModernToast для уведомлений
- **НЕ ДОЛЖЕН** использовать стандартные кнопки Flutter

### Требования к структуре файлов
```
lib/features/onboarding/
lib/features/topbar/
lib/features/project/
```

### Паттерн управления состоянием
```dart
class ProjectProvider extends ChangeNotifier {
  Project? _currentProject;
  bool _hasUnsavedChanges = false;
  
  Project? get currentProject => _currentProject;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  
  Future<void> createProject(String name, String path) async {
    // Реализация
    notifyListeners();
  }
}
```

## Подход к тестированию

### Чеклист ручного тестирования
- [ ] Диалог онбординга появляется при первом запуске
- [ ] Рабочий процесс создания проекта завершается успешно
- [ ] Рабочий процесс открытия проекта загружает существующие проекты
- [ ] Отмена онбординга открывает приложение с пустым проектом
- [ ] Верхняя панель правильно отображает имя проекта (Windows/Linux)
- [ ] Системная меню панель работает корректно (macOS)
- [ ] Опции меню файла работают как ожидается
- [ ] Опции меню редактирования доступны
- [ ] Индикаторы статуса обновляются соответствующим образом
- [ ] Недоступные файлы проектов автоматически скрываются
- [ ] Сообщения об ошибках отображаются корректно
- [ ] Поврежденные файлы не открываются с ошибкой о повреждении

### Шаги валидации
1. Запуск приложения свежо → должен появиться онбординг
2. Создание нового проекта → должен загрузиться основной интерфейс с верхней панелью
3. Тест всех опций меню → должен работать без сбоев
4. Проверка индикаторов статуса → должен отражать состояние проекта

## Распространенные проблемы и решения

### Проблема: Онбординг не появляется
**Решение**: Проверить инициализацию AppProvider и обнаружение первого запуска

### Проблема: Создание проекта не удается
**Решение**: Проверить права доступа к директории и интеграцию file_picker

### Проблема: Стилизация верхней панели не соответствует эталону
**Решение**: Сравнить с TypeScript TopBar.tsx и настроить стилизацию

### Проблема: Выпадающие меню не работают
**Решение**: Убедиться, что CustomStyledDropdown правильно реализован

### Проблема: macOS меню не интегрируется с системой
**Решение**: Использовать нативную интеграцию или специализированные пакеты для macOS

### Проблема: Файлы проекта не исчезают при недоступности
**Решение**: Реализовать фоновый мониторинг доступности файлов

### Проблема: Поврежденные файлы открываются с ошибками
**Решение**: Добавить валидацию формата файла перед открытием

## Следующие шаги

1. Реализовать диалог онбординга (Задача 3.1)
2. Создать сервис проектов (Задача 3.2)
3. Построить компонент верхней панели (Задача 3.3)
4. Добавить управление состоянием проекта (Задача 3.4)
5. Протестировать полный рабочий процесс
6. Реализовать оставшиеся задачи P2 и P3

## Ресурсы

### Эталонные файлы
- `nova-spec-ide-studio-main/src/components/TopBar.tsx`
- `nova-spec-ide-studio-main/src/components/dialogs/OnboardingDialog.tsx`

### Существующие компоненты
- `lib/shared/widgets/modern_button.dart`
- `lib/shared/widgets/modern_toast.dart`
- `lib/shared/widgets/custom_styled_dropdown.dart`

### Сервисы
- `lib/core/services/config_service.dart` (для паттерна эталона)
- `lib/core/di/service_locator.dart` (для регистрации DI)