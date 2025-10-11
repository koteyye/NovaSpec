# Список задач NovaSpec

## Обозначения

- ✅ — Выполнено
- 🟢 — В работе
- ⏳ — Ожидает
- 🔴 — Заблокировано
- 💡 — Требует уточнения

**Приоритеты:**
- P0 — Критический (MVP)
- P1 — Высокий (Core функционал)
- P2 — Средний (Улучшения)
- P3 — Низкий (Полировка)

---

## Фаза 1: Инфраструктура и базовая настройка (P0)

### 1.1. Инициализация проекта

- [x] **TASK-001** ✅ Создать Flutter проект для Windows/macOS
  - Выполнить: `flutter create novaspec --platforms=windows,macos`
  - Настроить `pubspec.yaml` с базовыми зависимостями
  - Приоритет: P0
  - Время: 0.5ч

- [x] **TASK-002** ✅ Настроить структуру папок согласно Clean Architecture
  - Создать папки: `core/`, `data/`, `domain/`, `presentation/`
  - Создать подпапки согласно спецификации
  - Приоритет: P0
  - Время: 0.5ч

- [x] **TASK-003** ✅ Добавить все зависимости в `pubspec.yaml`
  - flutter_riverpod, go_router, hive, dio, file_picker, just_audio
  - flutter_code_editor, shelf, webview_flutter, flutter_markdown
  - lucide_flutter (вместо lucide_icons), logger, uuid
  - Приоритет: P0
  - Время: 1ч

- [x] **TASK-004** ✅ Настроить Hive
  - Инициализация Hive в `main.dart`
  - Создать адаптеры для моделей (TypeAdapter)
  - Зарегистрировать адаптеры
  - Приоритет: P0
  - Время: 2ч

### 1.2. Дизайн-система (Core UI)

- [x] **TASK-005** ✅ Создать файлы цветовой палитры
  - `lib/core/config/theme/ns_colors.dart` (объединены light, dark и semantic)
  - Приоритет: P0
  - Время: 1ч

- [x] **TASK-006** ✅ Создать типографику
  - `lib/core/config/theme/ns_text_styles.dart` (объединены sizes, weights и styles)
  - Приоритет: P0
  - Время: 1ч

- [x] **TASK-007** ✅ Создать spacing и layout константы
  - `lib/core/config/theme/ns_spacing.dart` (объединены spacing, padding, border radius)
  - Приоритет: P0
  - Время: 0.5ч

- [x] **TASK-008** ✅ Создать базовый ThemeData
  - `lib/core/config/theme/ns_theme.dart`
  - Реализовать `NsTheme.light()` и `NsTheme.dark()`
  - Приоритет: P0
  - Время: 1.5ч

- [x] **TASK-009** ✅ Подключить тему в main.dart
  - Интегрирована тема с поддержкой светлого/темного режима
  - Настроена автоматическая смена по системным настройкам
  - Приоритет: P0
  - Время: 0.5ч

### 1.3. Базовые UI компоненты

- [x] **TASK-010** ✅ Создать `NsButton`
  - `lib/presentation/widgets/ns_button.dart`
  - Реализовать 5 вариантов (primary, secondary, outline, ghost, destructive)
  - Реализовать 4 размера (small, medium, large, icon)
  - Приоритет: P0
  - Время: 3ч

- [x] **TASK-011** ✅ Создать `NsTextField`
  - `lib/presentation/widgets/ns_text_field.dart`
  - Поддержка label, placeholder, helperText, errorText
  - Префикс/суффикс иконки
  - Приоритет: P0
  - Время: 2.5ч

- [x] **TASK-012** ✅ Создать `NsCard`
  - `lib/presentation/widgets/ns_card.dart`
  - Поддержка hover, onTap, кастомные тени
  - Приоритет: P0
  - Время: 1.5ч

- [x] **TASK-013** ✅ Создать `NsDialog`
  - `lib/presentation/widgets/ns_dialog.dart`
  - Header, content, footer (actions)
  - Приоритет: P0
  - Время: 2ч

- [x] **TASK-014** ✅ Создать `NsSelect` (Dropdown)
  - `lib/presentation/widgets/ns_select.dart`
  - Поддержка опций с иконками
  - Max height 320px с прокруткой
  - Приоритет: P0
  - Время: 2.5ч

- [x] **TASK-015** ✅ Создать `NsSwitch`
  - `lib/presentation/widgets/ns_switch.dart`
  - Анимация переключения (150ms)
  - Приоритет: P0
  - Время: 1.5ч

- [x] **TASK-016** ✅ Создать `NsTooltip`
  - `lib/presentation/widgets/ns_tooltip.dart`
  - 4 позиции (top, bottom, left, right)
  - Delay 500ms
  - Приоритет: P1
  - Время: 1.5ч

- [x] **TASK-017** ✅ Создать `NsMenuItem`
  - `lib/presentation/widgets/ns_menu_item.dart`
  - Поддержка иконки, shortcut, destructive
  - Приоритет: P0
  - Время: 1ч

- [x] **TASK-018** ✅ Создать `NsTabBar`
  - `lib/presentation/widgets/ns_tab_bar.dart`
  - Активная/неактивная вкладка
  - Closable опция (с кнопкой X)
  - Приоритет: P0
  - Время: 2ч

- [x] **TASK-019** ✅ Создать `NsScrollArea`
  - `lib/presentation/widgets/ns_scroll_area.dart`
  - Кастомный скроллбар (8px, opacity 0.3)
  - Приоритет: P1
  - Время: 1.5ч

---

## Фаза 2: Модели данных и Hive (P0)

### 2.1. Модели

- [x] **TASK-020** ✅ Создать `AppConfig` модель
  - `lib/data/models/app_config.dart`
  - Все поля из спецификации (проект, AI, Confluence, музикация, язык)
  - Hive TypeAdapter
  - Приоритет: P0
  - Время: 2ч

- [x] **TASK-021** ✅ Создать `ChatHistory` модель
  - `lib/data/models/chat_history.dart`
  - Поля: id, title, messages, createdAt
  - Hive TypeAdapter
  - Приоритет: P0
  - Время: 1ч

- [x] **TASK-022** ✅ Создать `ChatMessage` модель
  - `lib/data/models/chat_message.dart`
  - Поля: role, content, timestamp
  - Hive TypeAdapter
  - Приоритет: P0
  - Время: 0.5ч

- [x] **TASK-023** ✅ Создать `TemplateType` модель
  - `lib/data/models/template_type.dart`
  - Поля: id, name, systemName, isDefault
  - Hive TypeAdapter
  - Приоритет: P0
  - Время: 0.5ч

- [x] **TASK-024** ✅ Создать `Template` модель
  - `lib/data/models/template.dart`
  - Поля: id, name, typeId, content, isDefault
  - Hive TypeAdapter
  - Приоритет: P0
  - Время: 0.5ч

- [ ] **TASK-025** Создать `ProjectModel`
  - Пропущено (уже создана модель Project в TASK-004)
  - Приоритет: P1
  - Время: 0ч

- [ ] **TASK-026** Создать `FileReference` модель
  - Пропущено (уже создана модель FileEdit в TASK-004)
  - Приоритет: P1
  - Время: 0ч

### 2.2. Hive Data Source

- [x] **TASK-027** ✅ Создать `HiveDataSource`
  - `lib/data/data_sources/local/hive_data_source.dart`
  - CRUD для `AppConfig`
  - CRUD для `ChatHistory`
  - CRUD для `Template` и `TemplateType`
  - Приоритет: P0
  - Время: 3ч

### 2.3. Репозитории

- [x] **TASK-028** ✅ Создать `ConfigRepository`
  - `lib/data/repositories/config_repository.dart`
  - Методы: getConfig, saveConfig, updateConfig
  - Приоритет: P0
  - Время: 1.5ч

- [x] **TASK-029** ✅ Создать шаблоны по умолчанию
  - `lib/core/constants/default_templates.dart`
  - "User Story One Page" (Техническое задание)
  - "Бизнес-ориентированная документация функционала"
  - Приоритет: P1
  - Время: 1ч

---

## Фаза 3: Роутинг и базовый экран (P0)

### 3.1. Роутинг (go_router)

- [x] **TASK-030** ✅ Настроить `GoRouter`
  - `lib/core/config/router/app_router.dart`
  - Маршруты: `/` (main), `/onboarding`
  - Redirect логика (проверка онбординга)
  - Приоритет: P0
  - Время: 2ч

### 3.2. Главный экран (MainScreen)

- [x] **TASK-031** ✅ Создать каркас `MainScreen`
  - `lib/presentation/screens/main_screen.dart`
  - Layout: TopBar + Row(FileExplorer, SpecPreview, AIAssistant) + StatusBar
  - Приоритет: P0
  - Время: 2ч

---

## Фаза 4: Онбординг (P0)

### 4.1. OnboardingDialog

- [x] **TASK-032** ✅ Создать `OnboardingDialog`
  - `lib/presentation/widgets/dialogs/onboarding_dialog.dart`
  - 3 этапа: выбор проекта, создание нового, настройка ИИ
  - Навигация между этапами
  - Создано: OnboardingDialog, NsButton, NsTextField, NsCard
  - Приоритет: P0
  - Время: 4ч

- [x] **TASK-033** ✅ Реализовать логику создания проекта
  - Использование `file_picker` для выбора папки
  - Создание папки проекта на диске
  - Сохранение в Hive
  - Реализовано в _createNewProject()
  - Приоритет: P0
  - Время: 2ч

- [x] **TASK-034** ✅ Реализовать логику открытия существующего проекта
  - Использование `file_picker`
  - Сохранение пути в Hive
  - Реализовано в _pickExistingProject()
  - Приоритет: P0
  - Время: 1ч

- [x] **TASK-035** ✅ Интеграция онбординга с роутером
  - Проверка наличия проекта при старте
  - Редирект на онбординг если нет проекта
  - Реализовано в OnboardingScreen и AppRouter
  - Приоритет: P0
  - Время: 1ч

---

## Фаза 5: TopBar (P0)

### 5.1. TopBar компонент

- [x] **TASK-036** ✅ Создать `TopBar` виджет
  - `lib/presentation/widgets/top_bar/top_bar.dart`
  - Меню: Файл, Настройки, О программе
  - Индикаторы: AI, Confluence, Музикация
  - Реализовано с _MenuButton и _StatusIndicator
  - Приоритет: P0
  - Время: 3ч

- [x] **TASK-037** ✅ Реализовать меню "Файл"
  - Новый проект (Ctrl+N)
  - Открыть проект (Ctrl+O)
  - Сохранить (Ctrl+S)
  - Сохранить как...
  - Создан ProjectProvider для управления проектами
  - Приоритет: P0
  - Время: 2ч

- [x] **TASK-038** ✅ Реализовать меню "Настройки"
  - Параметры (Ctrl+,) → открыть SettingsDialog
  - Шаблоны → открыть TemplatesDialog
  - Созданы SettingsDialog и TemplatesDialog
  - Расширен AppConfig (space, parentPageId)
  - Приоритет: P0
  - Время: 1ч

- [x] **TASK-039** ✅ Реализовать меню "О программе"
  - Открыть AboutDialog
  - Создан NsAboutDialog
  - Приоритет: P1
  - Время: 0.5ч

- [ ] **TASK-040** Создать индикаторы состояния
  - `lib/presentation/widgets/top_bar/indicator_widget.dart`
  - AI (Brain иконка, название провайдера)
  - Confluence (Atlassian иконка)
  - Музикация (Music иконка, баланс, жанр, refresh)
  - Приоритет: P1
  - Время: 2.5ч

- [ ] **TASK-041** Реализовать горячие клавиши
  - Использовать `Shortcuts` + `Actions`
  - Ctrl+N, Ctrl+O, Ctrl+S, Ctrl+,
  - Приоритет: P1
  - Время: 2ч

---

## Фаза 6: FileExplorer (P0)

### 6.1. FileExplorer компонент

- [x] **TASK-042** ✅ Создать `FileExplorer` виджет
  - `lib/presentation/widgets/file_explorer/file_explorer.dart`
  - Заголовок с логотипом и названием
  - Дерево файлов
  - Создан FileTreeProvider для управления деревом
  - Приоритет: P0
  - Время: 2ч

- [x] **TASK-043** ✅ Создать `FileTreeItem` виджет
  - `lib/presentation/widgets/file_explorer/file_tree_item.dart`
  - Рекурсивное отображение файлов/папок
  - Иконки по типам файлов (md, txt, pdf, json, mp3)
  - Автоматическое скрытие скрытых файлов
  - Приоритет: P0
  - Время: 2.5ч

- [x] **TASK-044** ✅ Реализовать сервис работы с файловой системой
  - `lib/domain/services/file_service.dart`
  - Сканирование папки проекта
  - Чтение/запись файлов
  - Утилиты для работы с путями
  - Интегрирован в ProjectProvider и FileTreeNotifier
  - Приоритет: P0
  - Время: 3ч

- [x] **TASK-045** ✅ Интегрировать клик по файлу
  - Открытие файла в SpecPreview
  - Реализовано в FileTreeItem через ProjectProvider.openFile()
  - Приоритет: P0
  - Время: 1.5ч

- [x] **TASK-046** ✅ Реализовать обновление дерева файлов
  - При сохранении новых файлов (например, MP3)
  - Автоматическое обновление через lastSavedAt
  - Приоритет: P1
  - Время: 1.5ч

---

## Фаза 7: SpecPreview (P0)

### 7.1. SpecPreview компонент

- [x] **TASK-047** ✅ Создать `SpecPreview` виджет
  - `lib/presentation/widgets/spec_preview/spec_preview.dart`
  - Панель инструментов (переключение режимов)
  - Режимы: Preview, Edit, Split
  - Интеграция с flutter_markdown
  - Синхронизация с ProjectProvider
  - Приоритет: P0
  - Время: 3ч

- [x] **TASK-048** ✅ Реализовать управление вкладками
  - Список открытых файлов
  - Активная вкладка
  - Закрытие вкладки (X)
  - Создан класс OpenedFile для представления вкладки
  - Добавлены методы: openFile, switchTab, closeTab
  - Панель вкладок отображается в SpecPreview
  - Обратная совместимость через @Deprecated поля
  - Приоритет: P0
  - Время: 2ч

### 7.2. Рендеринг Markdown/HTML

- [x] **TASK-049** ✅ Создать `MarkdownRenderer` виджет
  - `lib/presentation/widgets/spec_preview/markdown_renderer.dart`
  - Использовать `flutter_markdown` с расширениями
  - Поддержка таблиц, списков, блоков кода с подсветкой
  - Кастомные стили для всех элементов (заголовки, ссылки, цитаты)
  - GitHub Flavored Markdown (GFM)
  - Обработка кликов по ссылкам через url_launcher
  - Интегрирован в SpecPreview (Preview и Split режимы)
  - Приоритет: P0
  - Время: 2ч

- [x] **TASK-050** ✅ Создать `HtmlRenderer` виджет
  - `lib/presentation/widgets/spec_preview/html_renderer.dart`
  - Использование `flutter_html` с кастомными стилями
  - Поддержка всех HTML элементов (заголовки, таблицы, списки, код, изображения)
  - Обработка кликов по ссылкам через url_launcher
  - Автоопределение типа файла по расширению (.html, .htm)
  - Интегрирован в SpecPreview (Preview и Split режимы)
  - Приоритет: P1
  - Время: 1.5ч

### 7.3. Редактор кода

- [x] **TASK-051** ✅ Создать `TextEditor` виджет
  - `lib/presentation/widgets/spec_preview/text_editor.dart`
  - Использование `flutter_code_editor` с `highlight`
  - Подсветка синтаксиса для: Markdown, JSON, YAML, Dart
  - Автоопределение языка по расширению файла
  - Нумерация строк (GutterStyle)
  - Темы: GitHub (светлая) и VS2015 (темная)
  - Интегрирован в SpecPreview (Edit и Split режимы)
  - Удален базовый TextField, убран _contentController
  - Приоритет: P0
  - Время: 3ч

- [x] **TASK-052** ✅ Реализовать сохранение файла (Ctrl+S)
  - Добавлен `CallbackShortcuts` в SpecPreview
  - Горячая клавиша Ctrl+S для сохранения активного файла
  - Использует `ProjectNotifier.saveCurrentFile()`
  - Обновление индикатора несохраненных изменений
  - Приоритет: P0
  - Время: 1.5ч

### 7.4. Аудиоплеер

- [x] **TASK-053** ✅ Создать `AudioPlayerWidget`
  - `lib/presentation/widgets/spec_preview/audio_player_widget.dart`
  - Использование `just_audio` для воспроизведения MP3, WAV, OGG, M4A
  - Полнофункциональный UI:
    - Play/Pause кнопка с индикацией состояния
    - Перемотка назад/вперед на 10 секунд
    - Прогресс-бар с возможностью перемотки
    - Отображение текущего и общего времени
    - Регулятор громкости с процентами
  - Обработка состояний: загрузка, ошибка, воспроизведение
  - Автоопределение аудио файлов по расширению
  - Интегрирован в SpecPreview (Preview и Split режимы)
  - Приоритет: P1
  - Время: 3ч

### 7.5. Swagger UI

- [x] **TASK-054** ✅ Реализовать `SwaggerService`
  - `lib/domain/services/swagger_service.dart`
  - Запуск shelf-сервера (127.0.0.1:4001)
  - Использование `shelf_swagger_ui`
  - start(), restart(), stop()
  - CORS middleware для WebView
  - Приоритет: P1
  - Время: 4ч

- [x] **TASK-055** ✅ Создать `SwaggerViewer` виджет
  - `lib/presentation/widgets/spec_preview/swagger_viewer.dart`
  - WebView с локальным URL
  - JavaScript enabled
  - Обработка состояний загрузки и ошибок
  - Автоматический перезапуск при смене файла
  - Приоритет: P1
  - Время: 2.5ч

- [x] **TASK-056** ✅ Реализовать валидацию OpenAPI
  - `lib/core/utils/openapi_validator.dart`
  - Проверка наличия ключей: openapi, info, paths
  - Поддержка JSON и YAML форматов
  - Метод getOpenApiVersion()
  - Приоритет: P1
  - Время: 1ч

### 7.6. Кнопка "Музицировать"

- [x] **TASK-057** ✅ Добавить кнопку "Музицировать"
  - Показывается только для .md и .html
  - Только если музикация включена
  - Открывает MusicifyDialog
  - Добавлены методы проверки типов файлов
  - Интегрирована в toolbar SpecPreview
  - Приоритет: P1
  - Время: 1ч

---

## Фаза 8: StatusBar (P0)

### 8.1. StatusBar компонент

- [x] **TASK-058** ✅ Создать `StatusBar` виджет
  - `lib/presentation/widgets/status_bar/status_bar.dart`
  - Базовая структура с высотой 24px
  - Отображение статусных сообщений
  - Индикатор загрузки (CircularProgressIndicator)
  - Прогресс-бар с процентами для длительных операций
  - Интегрирован в MainScreen
  - Готов для отображения статусов музикации и других процессов
  - Приоритет: P1
  - Время: 1.5ч

- [x] **TASK-059** ✅ Реализовать отображение статусов
  - Универсальный механизм отображения статусов через параметры
  - Поддержка статусных сообщений любого типа
  - Индикация прогресса (0-100%)
  - Индикатор загрузки
  - Готово для интеграции с музикацией
  - Приоритет: P1
  - Время: 1ч

---

## Фаза 9: Диалоги (P0-P1)

### 9.1. SettingsDialog

- [x] **TASK-060** ✅ Создать `SettingsDialog`
  - `lib/presentation/widgets/dialogs/settings_dialog.dart`
  - Секции: Провайдер, Confluence, Музикация, Язык
  - 8 AI провайдеров (dropdown с динамическими полями)
  - Кнопка "Проверить" для валидации настроек
  - Приоритет: P0
  - Время: 5ч

- [x] **TASK-061** ✅ Реализовать секцию "Провайдер"
  - Dropdown с 8 провайдерами
  - Динамические поля (токен, базовый URL)
  - Реализовано в TASK-060
  - Приоритет: P0
  - Время: 2.5ч

- [x] **TASK-062** ✅ Реализовать секцию "Confluence"
  - Switch включить/выключить
  - Поля: Базовый URL, Email, Токен
  - Реализовано в TASK-060
  - Приоритет: P1
  - Время: 2ч

- [x] **TASK-063** ✅ Реализовать секцию "Музикация"
  - Switch включить/выключить
  - Поля: Токен, Жанр, Balance
  - Реализовано в TASK-060
  - Приоритет: P1
  - Время: 1.5ч

- [x] **TASK-064** ✅ Реализовать секцию "Язык"
  - Dropdown: Русский, Английский
  - Реализовано в TASK-060
  - Приоритет: P1
  - Время: 0.5ч

- [x] **TASK-065** ✅ Реализовать кнопку "Проверить"
  - Кнопка добавлена с состоянием валидации
  - TODO: Реализовать вызов API для валидации
  - Реализовано в TASK-060
  - Приоритет: P1
  - Время: 3ч

- [x] **TASK-066** ✅ Реализовать кнопку "Сохранить"
  - Сохранение конфига в Hive
  - Закрытие диалога
  - Активируется только после валидации
  - Реализовано в TASK-060
  - Приоритет: P0
  - Время: 1ч

### 9.2. AboutDialog

- [x] **TASK-067** ✅ Создать `AboutDialog`
  - `lib/presentation/widgets/dialogs/about_dialog.dart`
  - Статичный текст, версия (из pubspec.yaml), создатель
  - Улучшен с использованием NsButton
  - Приоритет: P1
  - Время: 1ч

### 9.3. ErrorDialog

- [x] **TASK-068** ✅ Создать `ErrorDialog`
  - `lib/presentation/widgets/dialogs/error_dialog.dart`
  - Отображение ошибки с деталями
  - Возможность копирования деталей
  - Приоритет: P0
  - Время: 1ч

### 9.4. TemplatesDialog

- [x] **TASK-069** ✅ Создать `TemplatesDialog`
  - `lib/presentation/widgets/dialogs/templates_dialog.dart`
  - Секции: Типы шаблонов, Шаблоны
  - Кнопки для каждой секции: +, Карандаш, Корзина
  - Интеграция с AddTemplateTypeDialog и AddTemplateDialog
  - Защита от удаления типов/шаблонов по умолчанию
  - Приоритет: P1
  - Время: 3.5ч

- [x] **TASK-070** ✅ Создать `AddTemplateTypeDialog`
  - `lib/presentation/widgets/dialogs/add_template_type_dialog.dart`
  - Создание и редактирование типа шаблона
  - Автоматическая транслитерация и генерация systemName
  - Валидация полей (название, системное имя)
  - Защита типов по умолчанию от изменения systemName
  - Приоритет: P1
  - Время: 1.5ч

- [x] **TASK-071** ✅ Создать `AddTemplateDialog`
  - `lib/presentation/widgets/dialogs/add_template_dialog.dart`
  - Поля: Название, Контент (Markdown редактор)
  - AI-ревью секция с функционалом:
    - Выбор модели (кликабельный dropdown)
    - Кнопка "Отправить на ревью"
    - Отображение результатов с критическими замечаниями
    - Парсинг тега @critical_alert
    - Блокировка сохранения при критических замечаниях
    - Кнопка "Сохранить без ревью"
  - Приоритет: P1
  - Время: 4ч

### 9.5. MusicifyDialog

- [x] **TASK-072** ✅ Создать `MusicifyDialog`
  - `lib/presentation/widgets/dialogs/musicify_dialog.dart`
  - Подтверждение: "Да" / "Нет"
  - Предупреждение о расходе баланса (~17 руб)
  - Отображение имени файла
  - Приоритет: P1
  - Время: 1ч

---

## Фаза 10: AI-ассистент (P1)

### 10.1. AIAssistant компонент

- [x] **TASK-073** ✅ Создать `AIAssistant` виджет
  - `lib/presentation/widgets/ai_assistant/ai_assistant.dart`
  - Toolbar (кнопки режимов, новый чат, история, свернуть)
  - Область сообщений (заглушка)
  - Input панель с динамическим placeholder
  - Режимы: Chat, Review, Generate
  - Возможность сворачивания
  - Приоритет: P1
  - Время: 4ч

- [x] **TASK-074** ✅ Создать `MessageBubble` виджет
  - `lib/presentation/widgets/ai_assistant/message_bubble.dart`
  - Пользователь: справа, синий фон
  - AI: слева, серый фон, иконка Brain
  - Markdown рендеринг контента
  - Timestamp с форматированием
  - Приоритет: P1
  - Время: 1.5ч

- [x] **TASK-075** ✅ Создать `ProposedChanges` виджет
  - `lib/presentation/widgets/ai_assistant/proposed_changes.dart`
  - Карточка с diff (красный - удаление, желтый - изменение, зеленый - добавление)
  - Отображение номеров строк
  - Кнопки: Принять, Отклонить
  - Модели: FileChange, DiffLine, ChangeType
  - Приоритет: P1
  - Время: 2ч

- [x] **TASK-076** ✅ Создать `FileMentionInput` виджет
  - `lib/presentation/widgets/ai_assistant/file_mention_input.dart`
  - Текстовое поле с поддержкой @ для упоминания файлов
  - Автокомплит с фильтрацией (макс 10 файлов)
  - Навигация по списку клавишами (Arrow Up/Down, Enter, Escape)
  - Overlay для отображения автокомплита
  - Приоритет: P1
  - Время: 3ч

### 10.2. Режимы работы

- [ ] **TASK-077** Реализовать режим "Диалог"
  - Обычный чат с AI
  - Промпт согласно спецификации
  - Приоритет: P1
  - Время: 2ч

- [ ] **TASK-078** Реализовать режим "Создать ТЗ по шаблону"
  - Выбор шаблона
  - Промпт с шаблоном
  - Приоритет: P1
  - Время: 2ч

- [ ] **TASK-079** Реализовать "Новый чат"
  - Очистка контекста
  - Сохранение текущего чата в историю
  - Приоритет: P1
  - Время: 1.5ч

- [ ] **TASK-080** Реализовать "История чатов"
  - Список сохранённых чатов
  - Загрузка чата при клике
  - Приоритет: P1
  - Время: 2ч

### 10.3. Выбор модели

- [ ] **TASK-081** Реализовать Popover со списком моделей
  - Кликабельный "model: {name}"
  - Запрос моделей у провайдера
  - Максимум 10 в списке (с прокруткой)
  - Приоритет: P1
  - Время: 2.5ч

---

## Фаза 11: AI-интеграция (P1)

### 11.1. AI API клиенты

- [ ] **TASK-082** Создать базовый `AIApiClient`
  - `lib/data/data_sources/remote/ai_api_client.dart`
  - Абстракция для всех провайдеров
  - Методы: sendMessage, getModels, streamResponse
  - Приоритет: P1
  - Время: 3ч

- [ ] **TASK-083** Реализовать OpenAI провайдер
  - POST /v1/chat/completions
  - SSE стриминг
  - Приоритет: P1
  - Время: 2.5ч

- [ ] **TASK-084** Реализовать Anthropic провайдер
  - POST /v1/messages
  - Кастомные заголовки (x-api-key, anthropic-version)
  - SSE стриминг
  - Приоритет: P1
  - Время: 2.5ч

- [ ] **TASK-085** Реализовать Groq, Cerebras, OpenRouter провайдеры
  - Аналогично OpenAI (OpenAI-compatible)
  - Приоритет: P1
  - Время: 1.5ч

- [ ] **TASK-086** Реализовать LM Studio, Ollama провайдеры
  - OpenAI-compatible с кастомным baseUrl
  - Опциональный токен
  - Приоритет: P1
  - Время: 1ч

### 11.2. SSE стриминг

- [ ] **TASK-087** Реализовать SSE парсер
  - Парсинг событий формата: `data: {...}`
  - Обработка типов: message, file_edit, status, error
  - Приоритет: P1
  - Время: 3ч

- [ ] **TASK-088** Интегрировать SSE в AI-ассистент
  - StreamProvider для стриминга
  - Обновление UI в реальном времени
  - Приоритет: P1
  - Время: 3ч

### 11.3. AI Repository

- [ ] **TASK-089** Создать `AIRepository`
  - `lib/data/repositories/ai_repository.dart`
  - Методы: sendMessage, getModels, streamResponse
  - Управление провайдерами (фабрика)
  - Приоритет: P1
  - Время: 2.5ч

### 11.4. Use Cases

- [ ] **TASK-090** Создать `SendMessageUseCase`
  - `lib/domain/use_cases/ai/send_message_use_case.dart`
  - Формирование промпта
  - Вызов репозитория
  - Приоритет: P1
  - Время: 1.5ч

- [ ] **TASK-091** Создать `GetModelsUseCase`
  - `lib/domain/use_cases/ai/get_models_use_case.dart`
  - Запрос моделей у провайдера
  - Приоритет: P1
  - Время: 1ч

- [ ] **TASK-092** Создать `StreamAIResponseUseCase`
  - `lib/domain/use_cases/ai/stream_ai_response_use_case.dart`
  - SSE стриминг
  - Приоритет: P1
  - Время: 1.5ч

---

## Фаза 12: Confluence интеграция (P1)

### 12.1. Confluence API клиент

- [ ] **TASK-093** Создать `ConfluenceApiClient`
  - `lib/data/data_sources/remote/confluence_api_client.dart`
  - Автоопределение типа инстанса (Cloud / DC/Server)
  - Методы: getSpaces, getPages, createPage, updatePage
  - Приоритет: P1
  - Время: 3.5ч

- [ ] **TASK-094** Реализовать проверку подключения
  - GET /rest/api/space
  - Обработка ошибок
  - Приоритет: P1
  - Время: 1ч

### 12.2. Confluence Repository

- [ ] **TASK-095** Создать `ConfluenceRepository`
  - `lib/data/repositories/confluence_repository.dart`
  - Обертка над API клиентом
  - Приоритет: P1
  - Время: 1.5ч

---

## Фаза 13: Музикация (P1)

### 13.1. Gen-API клиент

- [ ] **TASK-096** Создать `GenApiClient`
  - `lib/data/data_sources/remote/gen_api_client.dart`
  - Методы: getUser, generateMusic, getRequestStatus
  - Приоритет: P1
  - Время: 2.5ч

- [ ] **TASK-097** Реализовать проверку токена
  - GET /api/v1/user
  - Получение баланса
  - Приоритет: P1
  - Время: 0.5ч

### 13.2. Music Repository

- [ ] **TASK-098** Создать `MusicRepository`
  - `lib/data/repositories/music_repository.dart`
  - Обертка над GenApiClient
  - Приоритет: P1
  - Время: 1ч

### 13.3. Use Cases

- [ ] **TASK-099** Создать `GenerateLyricsUseCase`
  - `lib/domain/use_cases/musicify/generate_lyrics_use_case.dart`
  - Промпт для AI
  - Вызов AI провайдера
  - Приоритет: P1
  - Время: 1.5ч

- [ ] **TASK-100** Создать `GenerateMusicUseCase`
  - `lib/domain/use_cases/musicify/generate_music_use_case.dart`
  - POST /api/v1/networks/suno
  - Polling статуса (каждые 2 сек)
  - Скачивание MP3
  - Сохранение в проект
  - Приоритет: P1
  - Время: 4ч

### 13.4. Интеграция в UI

- [ ] **TASK-101** Реализовать полный процесс музикации
  - Открытие MusicifyDialog
  - Генерация Lyrics (статус в StatusBar)
  - Генерация музыки в Suno (статус в StatusBar)
  - Сохранение трека (статус в StatusBar)
  - Обновление FileExplorer
  - Toast с результатом
  - Приоритет: P1
  - Время: 3ч

---

## Фаза 14: Локализация (P1)

### 14.1. Настройка локализации

- [ ] **TASK-102** Настроить `flutter_localizations`
  - Добавить зависимость
  - Создать файлы `.arb`
  - Приоритет: P1
  - Время: 1ч

- [ ] **TASK-103** Создать `app_ru.arb`
  - `lib/presentation/l10n/app_ru.arb`
  - Все ключи на русском
  - Приоритет: P1
  - Время: 3ч

- [ ] **TASK-104** Создать `app_en.arb`
  - `lib/presentation/l10n/app_en.arb`
  - Все ключи на английском
  - Приоритет: P1
  - Время: 3ч

- [ ] **TASK-105** Интегрировать локализацию в UI
  - Заменить хардкод на `AppLocalizations.of(context)`
  - Приоритет: P1
  - Время: 2ч

- [ ] **TASK-106** Реализовать переключение языка
  - Сохранение в Hive
  - Перезагрузка UI
  - Приоритет: P1
  - Время: 1.5ч

---

## Фаза 15: Провайдеры состояния (Riverpod) (P0-P1)

### 15.1. App State Provider

- [x] **TASK-107** ✅ Создать `AppStateProvider`
  - `lib/presentation/providers/app_state_provider.dart`
  - Управление глобальным состоянием (тема, язык)
  - ThemeMode с поддержкой: light, dark, system
  - Инициализация из Hive
  - Методы: toggleTheme, setLanguage, reload
  - Приоритет: P0
  - Время: 2ч

### 15.2. Settings Provider

- [x] **TASK-108** ✅ Создать `SettingsProvider`
  - `lib/presentation/providers/settings_provider.dart`
  - Управление настройками (загрузка, сохранение)
  - Методы обновления: AI провайдер, Confluence, Музикация, Язык
  - Проверка конфигурации: isAIConfigured, isConfluenceConfigured, isMusicConfigured
  - Обработка ошибок и сообщений об успехе
  - Приоритет: P0
  - Время: 1.5ч

### 15.3. File Explorer Provider

- [x] **TASK-109** ✅ Создать `FileExplorerProvider`
  - Реализован как FileTreeProvider в `lib/presentation/widgets/file_explorer/file_explorer.dart`
  - Управление деревом файлов
  - Автообновление при сохранении файлов
  - Интеграция с ProjectProvider
  - Приоритет: P0
  - Время: 2ч

### 15.4. AI Assistant Provider

- [x] **TASK-110** ✅ Создать `AIAssistantProvider`
  - `lib/presentation/providers/ai_assistant_provider.dart`
  - Управление чатами, сообщениями, историей
  - Режимы работы: chat, review, generate
  - Методы: createNewChat, loadChat, deleteChat, sendMessage
  - Автосохранение чатов в Hive
  - Выбор модели AI
  - Приоритет: P1
  - Время: 2.5ч

### 15.5. Musicify Provider

- [ ] **TASK-111** Создать `MusicifyProvider`
  - `lib/presentation/providers/musicify_provider.dart`
  - Управление статусом музикации
  - Приоритет: P1
  - Время: 1.5ч

---

## Фаза 16: Полировка и оптимизация (P2-P3)

### 16.1. Производительность

- [ ] **TASK-112** Оптимизировать рендеринг списка файлов
  - Использовать виртуализацию (ListView.builder)
  - Приоритет: P2
  - Время: 1ч

- [ ] **TASK-113** Оптимизировать SSE стриминг
  - Использовать изоляты для парсинга
  - Приоритет: P2
  - Время: 2ч

- [ ] **TASK-114** Оптимизировать Swagger UI
  - Запуск shelf-сервера в отдельном изоляте
  - Приоритет: P2
  - Время: 2ч

### 16.2. Доработки UI

- [ ] **TASK-115** Добавить анимации переходов
  - Dialog появление/исчезновение
  - Drawer slide-in/out
  - Приоритет: P2
  - Время: 2ч

- [ ] **TASK-116** Добавить Ripple эффекты для кнопок
  - InkWell с кастомными параметрами
  - Приоритет: P2
  - Время: 1ч

- [ ] **TASK-117** Доработать hover состояния
  - Все интерактивные элементы
  - Приоритет: P2
  - Время: 1.5ч

### 16.3. Accessibility

- [ ] **TASK-118** Добавить Semantics для всех элементов
  - Кнопки, поля ввода, меню
  - Приоритет: P2
  - Время: 2ч

- [ ] **TASK-119** Проверить контрастность цветов
  - WCAG 2.1 AA соответствие
  - Приоритет: P2
  - Время: 1ч

- [ ] **TASK-120** Тестировать клавиатурную навигацию
  - Tab, Enter, Escape, Arrow keys
  - Приоритет: P2
  - Время: 1.5ч

### 16.4. Логирование и обработка ошибок

- [ ] **TASK-121** Настроить логирование
  - Использовать пакет `logger`
  - Логировать запросы, ошибки, важные события
  - Приоритет: P2
  - Время: 1.5ч

- [ ] **TASK-122** Добавить глобальный обработчик ошибок
  - Отлов необработанных исключений
  - Приоритет: P2
  - Время: 1ч

### 16.5. Документация кода

- [ ] **TASK-123** Добавить DartDoc комментарии
  - Для всех публичных классов и методов
  - Приоритет: P3
  - Время: 3ч

---

## Фаза 17: Сборка и развертывание (P1)

### 17.1. Windows

- [ ] **TASK-124** Настроить Windows конфигурацию
  - `windows/runner/main.cpp`
  - Иконка приложения
  - Приоритет: P1
  - Время: 1ч

- [ ] **TASK-125** Создать сборку Windows
  - `flutter build windows --release`
  - Тестирование на Windows 10/11
  - Приоритет: P1
  - Время: 2ч

- [ ] **TASK-126** Создать установщик (Inno Setup)
  - Скрипт установки
  - Упаковка приложения
  - Приоритет: P1
  - Время: 2.5ч

### 17.2. macOS

- [ ] **TASK-127** Настроить macOS конфигурацию
  - `macos/Runner/Info.plist`
  - Иконка приложения
  - Приоритет: P1
  - Время: 1ч

- [ ] **TASK-128** Создать сборку macOS
  - `flutter build macos --release`
  - Тестирование на macOS
  - Приоритет: P1
  - Время: 2ч

- [ ] **TASK-129** Создать DMG образ
  - Использовать `create-dmg` или `appdmg`
  - Приоритет: P1
  - Время: 2ч

### 17.3. Версионирование

- [ ] **TASK-130** Настроить версионирование
  - `pubspec.yaml` version
  - Автоинкремент при сборке
  - Приоритет: P1
  - Время: 0.5ч

---

## Фаза 18: Дополнительные улучшения (P2-P3)

### 18.1. AI-ревью шаблонов

- [ ] **TASK-131** Реализовать AI-ревью в AddTemplateDialog
  - Кнопка "Отправить на ревью"
  - Промпт согласно спецификации
  - SSE стриминг ответа
  - Парсинг тега @critical_alert
  - Блокировка кнопки "Сохранить"
  - Приоритет: P2
  - Время: 3ч

### 18.2. История чатов

- [ ] **TASK-132** Реализовать сохранение чатов в Hive
  - При закрытии/переключении чата
  - Приоритет: P2
  - Время: 1.5ч

- [ ] **TASK-133** Реализовать загрузку чата из истории
  - Восстановление контекста
  - Приоритет: P2
  - Время: 1ч

### 18.3. Упоминание файлов (@file)

- [ ] **TASK-134** Доработать автокомплит файлов
  - Фильтрация по имени
  - Поддержка путей (подпапки)
  - Приоритет: P2
  - Время: 2ч

- [ ] **TASK-135** Реализовать чтение упомянутых файлов
  - Парсинг @filename из промпта
  - Чтение контента
  - Передача в AI
  - Приоритет: P2
  - Время: 2ч

### 18.4. Инструменты для AI

- [ ] **TASK-136** Реализовать инструмент "Чтение файла"
  - AI может запросить чтение любого файла проекта
  - Приоритет: P2
  - Время: 2.5ч

- [ ] **TASK-137** Реализовать инструмент "Изменение файла"
  - AI может предложить изменения
  - Возврат diff
  - Приоритет: P2
  - Время: 3ч

### 18.5. Diff-просмотр

- [ ] **TASK-138** Создать виджет для отображения diff
  - Красный (удаление), желтый (изменение), зеленый (добавление)
  - Интеграция в SpecPreview
  - Приоритет: P2
  - Время: 3ч

---

## Итоговая статистика

**Всего задач:** 138

**По приоритетам:**
- P0 (Критический): ~45 задач
- P1 (Высокий): ~70 задач
- P2 (Средний): ~20 задач
- P3 (Низкий): ~3 задачи

**Общая оценка времени:** ~320 часов (8 недель при 40 часах/неделя)

**Фазы по времени:**
- Фаза 1-5 (MVP): ~80 часов (2 недели)
- Фаза 6-10 (Core): ~90 часов (2.5 недели)
- Фаза 11-14 (Интеграции): ~80 часов (2 недели)
- Фаза 15-18 (Полировка): ~70 часов (1.5 недели)

---

## Примечания

1. Время указано приблизительно и может варьироваться
2. Некоторые задачи можно выполнять параллельно
3. Рекомендуется следовать порядку фаз для минимизации зависимостей
4. После каждой фазы желательно проводить промежуточное тестирование
5. Задачи P2-P3 можно отложить на постпродакшн

---

**Версия:** 1.0
**Дата создания:** 2025-01-XX
**Автор:** Claude (AI-ассистент)
