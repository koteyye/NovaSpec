# Техническая спецификация NovaSpec

## 1. Обзор проекта

**NovaSpec** — десктопное приложение для macOS и Windows, разработанное на Flutter, предназначенное для совместной выработки технических заданий с AI-ассистентом. Приложение позволяет пользователям создавать, редактировать и музицировать документацию с интеграцией AI-провайдеров, Confluence и сервиса генерации музыки.

### 1.1. Цель проекта

Переписать существующий TypeScript UI-референс на Flutter с полной функциональной бизнес-логикой, сохранив визуальную идентичность и улучшив производительность за счет нативных десктопных возможностей.

### 1.2. Технический стек

- **Фреймворк:** Flutter SDK (latest stable)
- **Язык:** Dart
- **Управление состоянием:** Riverpod
- **Навигация:** go_router
- **Локальное хранилище:** Hive
- **HTTP-клиент:** dio
- **Работа с файлами:** path_provider, file_picker
- **Аудиоплеер:** just_audio
- **Редактор кода:** flutter_code_editor
- **Swagger UI:** shelf + shelf_swagger_ui + webview_flutter
- **Локализация:** flutter_localizations (русский и английский)
- **SSE (Server-Sent Events):** http или sse пакет для стриминга от AI

---

## 2. Архитектура приложения

### 2.1. Структура проекта

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   └── router/
│   │       └── app_router.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── utils/
│       ├── file_utils.dart
│       └── openapi_validator.dart
├── data/
│   ├── models/
│   │   ├── project_model.dart
│   │   ├── settings_model.dart
│   │   ├── template_model.dart
│   │   ├── ai_provider_model.dart
│   │   ├── chat_history_model.dart
│   │   └── file_reference_model.dart
│   ├── repositories/
│   │   ├── config_repository.dart
│   │   ├── ai_repository.dart
│   │   ├── confluence_repository.dart
│   │   └── music_repository.dart
│   └── data_sources/
│       ├── local/
│       │   └── hive_data_source.dart
│       └── remote/
│           ├── ai_api_client.dart
│           ├── confluence_api_client.dart
│           └── gen_api_client.dart
├── domain/
│   ├── entities/
│   ├── use_cases/
│   │   ├── onboarding/
│   │   │   ├── create_project_use_case.dart
│   │   │   └── open_project_use_case.dart
│   │   ├── settings/
│   │   │   ├── verify_integrations_use_case.dart
│   │   │   └── save_settings_use_case.dart
│   │   ├── ai/
│   │   │   ├── send_message_use_case.dart
│   │   │   ├── get_models_use_case.dart
│   │   │   └── stream_ai_response_use_case.dart
│   │   ├── templates/
│   │   │   ├── manage_templates_use_case.dart
│   │   │   └── ai_review_template_use_case.dart
│   │   └── musicify/
│   │       ├── generate_lyrics_use_case.dart
│   │       └── generate_music_use_case.dart
│   └── services/
│       ├── file_service.dart
│       ├── swagger_service.dart
│       └── audio_service.dart
├── presentation/
│   ├── providers/
│   │   ├── app_state_provider.dart
│   │   ├── settings_provider.dart
│   │   ├── ai_assistant_provider.dart
│   │   ├── file_explorer_provider.dart
│   │   └── musicify_provider.dart
│   ├── screens/
│   │   └── main_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── ns_button.dart
│   │   │   ├── ns_text_field.dart
│   │   │   ├── ns_card.dart
│   │   │   └── ns_dialog.dart
│   │   ├── top_bar/
│   │   │   ├── top_bar.dart
│   │   │   └── indicator_widget.dart
│   │   ├── file_explorer/
│   │   │   ├── file_explorer.dart
│   │   │   └── file_tree_item.dart
│   │   ├── spec_preview/
│   │   │   ├── spec_preview.dart
│   │   │   ├── text_editor.dart
│   │   │   ├── markdown_renderer.dart
│   │   │   ├── html_renderer.dart
│   │   │   ├── audio_player_widget.dart
│   │   │   └── swagger_viewer.dart
│   │   ├── ai_assistant/
│   │   │   ├── ai_assistant.dart
│   │   │   ├── message_bubble.dart
│   │   │   ├── file_mention_input.dart
│   │   │   └── proposed_changes.dart
│   │   ├── status_bar/
│   │   │   └── status_bar.dart
│   │   └── dialogs/
│   │       ├── onboarding_dialog.dart
│   │       ├── settings_dialog.dart
│   │       ├── templates_dialog.dart
│   │       ├── add_template_dialog.dart
│   │       ├── add_template_type_dialog.dart
│   │       ├── musicify_dialog.dart
│   │       ├── about_dialog.dart
│   │       └── error_dialog.dart
│   └── l10n/
│       ├── app_en.arb
│       └── app_ru.arb
└── generated/
    └── l10n/
```

### 2.2. Паттерны и принципы

- **Clean Architecture** — разделение на слои data, domain, presentation
- **Riverpod** для управления состоянием (StateNotifier, FutureProvider, StreamProvider)
- **Repository Pattern** для работы с данными
- **Dependency Injection** через Riverpod
- **SOLID принципы**
- **Явная типизация** — избегать `var` и `dynamic`

---

## 3. Управление данными (Hive)

### 3.1. Структура конфигурации

**Box: `app_config`**

```dart
class AppConfig {
  // Проект
  String? currentProjectPath;
  String? currentProjectName;

  // AI Provider
  String? aiProvider; // openai, openai_competitive, anthropic, cerebras, groq, lm_studio, ollama, openrouter
  String? aiProviderBaseUrl;
  String? aiProviderToken;
  String? aiSelectedModel;

  // Confluence
  bool confluenceEnabled;
  String? confluenceBaseUrl;
  String? confluenceEmail;
  String? confluenceToken;
  String? confluenceInstanceType; // cloud | datacenter

  // Музикация
  bool musicEnabled;
  String? musicToken;
  String musicGenre; // системное имя: pop, russian_rap, rock, jazz, classic, electro_music, hip_hop, r&b
  int? musicBalance;

  // Язык
  String language; // ru | en

  // Модель для AI-ревью шаблонов
  String? templateReviewModel;

  // История чатов
  List<ChatHistory> chatHistories;

  // Шаблоны
  List<TemplateType> templateTypes;
  List<Template> templates;
}
```

### 3.2. Модели

```dart
@HiveType(typeId: 0)
class ChatHistory {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<ChatMessage> messages;

  @HiveField(3)
  DateTime createdAt;
}

@HiveType(typeId: 1)
class ChatMessage {
  @HiveField(0)
  String role; // user | assistant

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime timestamp;
}

@HiveType(typeId: 2)
class TemplateType {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // Отображаемое имя

  @HiveField(2)
  String systemName; // Системное имя

  @HiveField(3)
  bool isDefault; // Если true, нельзя удалить
}

@HiveType(typeId: 3)
class Template {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String typeId;

  @HiveField(3)
  String content;

  @HiveField(4)
  bool isDefault; // Если true, нельзя удалить
}
```

---

## 4. Детальное описание экранов и функционала

### 4.1. Онбординг (OnboardingDialog)

**Условие появления:** Открывается при первом запуске приложения, когда в Hive нет записи `app_config` или `currentProjectPath` пуст.

#### Этап 1: Выбор проекта

**UI компоненты:**
- Заголовок: "Добро пожаловать в NovaSpec"
- Описание: "Создайте новый проект или откройте существующий, чтобы начать работу"
- Две большие кнопки:
  - **Создать новый проект** (иконка FileText)
  - **Открыть существующий проект** (иконка FolderOpen)

**Логика:**
- При нажатии "Создать новый проект" → переход на **Этап 2**
- При нажатии "Открыть существующий проект" → вызов `file_picker` с режимом выбора папки → сохранение `currentProjectPath` в Hive → переход на **Этап 3**

#### Этап 2: Создание нового проекта

**UI компоненты:**
- Заголовок: "Создание нового проекта"
- Поля:
  - **Имя проекта** (Input)
  - **Путь к папке** (Input + кнопка "Обзор")
- Кнопки:
  - **Назад** → возврат на **Этап 1**
  - **Продолжить** (активна только если заполнены оба поля)

**Логика:**
- При клике на "Обзор" → вызов `file_picker` для выбора родительской папки → запись пути в поле
- При нажатии "Продолжить":
  - Создать папку `{selectedPath}/{projectName}`
  - Сохранить `currentProjectPath` и `currentProjectName` в Hive
  - Переход на **Этап 3**

#### Этап 3: Настройка ИИ и интеграций

**UI компоненты:**
- Заголовок: "Настройка ИИ и интеграций"
- Описание: "Настройте AI-провайдера и интеграции для полноценной работы с приложением"
- Кнопки:
  - **Пропустить** → закрыть онбординг, перейти на главный экран
  - **Настроить** → закрыть онбординг, открыть **SettingsDialog**, перейти на главный экран

**Логика:**
- При нажатии "Пропустить" → `onboardingCompleted = true`, переход на главный экран
- При нажатии "Настроить" → открыть SettingsDialog

---

### 4.2. Главный экран (MainScreen)

Главный экран состоит из 5 основных секций:

1. **TopBar** (верхняя панель)
2. **FileExplorer** (левая панель — проводник)
3. **SpecPreview** (центральная панель — рабочая область)
4. **AIAssistant** (правая панель — AI-ассистент)
5. **StatusBar** (нижняя панель — статусы)

#### 4.2.1. TopBar

**Компоненты:**
- **Меню "Файл":**
  - Новый проект (Ctrl+N) → OnboardingDialog (этап 2)
  - Открыть проект (Ctrl+O) → file_picker → сохранить путь в Hive, обновить FileExplorer
  - Сохранить → сохранить текущий открытый файл
  - Сохранить как... → file_picker (save mode) → сохранить файл с новым именем

- **Меню "Настройки":**
  - Параметры (Ctrl+,) → открыть SettingsDialog
  - Шаблоны → открыть TemplatesDialog

- **Меню "О программе":**
  - Открыть AboutDialog

**Индикаторы (справа):**
1. **AI-провайдер:**
   - Иконка Brain
   - Текст: название провайдера (если настроен)
   - Цвет: зеленый если настроен, серый если нет
   - Tooltip: "AI-провайдер"

2. **Confluence:**
   - Иконка Atlassian (SVG)
   - Цвет: оригинальный если активен, grayscale если нет
   - Tooltip: "Интеграция с Confluence"

3. **Музикация:**
   - Иконка Music
   - Цвет: зеленый если активна, серый если нет
   - Если активна:
     - Отображается баланс: `{balance} ₽`
     - Точка-разделитель
     - Жанр (локализованное название)
     - Иконка RefreshCw (кликабельна)
   - Tooltip: "Музикация"

**Логика обновления баланса:**
- При клике на иконку RefreshCw → вызов `GET https://api.gen-api.ru/api/v1/user` с токеном из конфига → обновление `musicBalance` в Hive → обновление UI → показать toast "Баланс обновлен"

---

#### 4.2.2. FileExplorer

**UI:**
- Заголовок: логотип NovaSpec + текст "NovaSpec"
- Дерево файлов текущего проекта

**Функционал:**
- Рекурсивное отображение файлов и папок
- Иконки для файлов по расширению:
  - `.md` → FileText (синий)
  - `.html` → FileCode (оранжевый)
  - `.json` → FileJson (желтый)
  - `.xml` → FileCode (зеленый)
  - `.yaml` / `.yml` → FileCode (фиолетовый)
  - `.mp3` → Music (розовый)
  - `.wav` → FileAudio (голубой)
  - `.txt` → FileText (серый)
  - Остальные → File (серый по умолчанию)

**Логика:**
- При клике на файл:
  - Если вкладка с этим файлом уже открыта → переключиться на неё
  - Если нет → открыть новую вкладку в SpecPreview

**Обновление:**
- При сохранении новых файлов (например, MP3 после музикации) → автоматически обновить дерево

---

#### 4.2.3. SpecPreview (Рабочая область)

**UI:**
- **Вкладки файлов** (вверху):
  - Список открытых файлов
  - Активная вкладка подсвечивается
  - Кнопка "X" для закрытия вкладки

- **Панель инструментов** (под вкладками, если применимо):
  - Кнопка переключения режима (Code/Eye):
    - Для `.md`, `.html` → переключение между режимом рендера и редактирования
    - Для `.yaml`, `.json` (OpenAPI) → переключение между Swagger UI и редактором кода
  - Кнопка "Музицировать" (Music):
    - Показывается только для `.md` и `.html`, если музикация включена

**Режимы отображения:**

1. **Markdown (`.md`) / HTML (`.html`):**
   - **Режим рендера (по умолчанию):**
     - Отрисовка markdown с помощью `flutter_markdown` или HTML с `flutter_html`
     - Поддержка таблиц, списков, заголовков, кода
   - **Режим редактирования:**
     - `flutter_code_editor` с подсветкой синтаксиса
     - Возможность редактирования и сохранения

2. **JSON / YAML:**
   - Проверка: является ли файл OpenAPI спецификацией?
     - **Да (OpenAPI):**
       - **Режим Swagger UI (по умолчанию):**
         - Запуск локального shelf-сервера на `127.0.0.1:4001`
         - Использование `shelf_swagger_ui` для рендера спецификации
         - Отображение в `webview_flutter`
       - **Режим редактирования:**
         - `flutter_code_editor` с подсветкой JSON/YAML
     - **Нет (обычный JSON/YAML):**
       - Только режим редактирования кода

3. **MP3 / WAV:**
   - Минималистичный аудиоплеер на базе `just_audio`:
     - Кнопка Play/Pause
     - Прогресс-бар
     - Время (текущее / общее)
     - Кнопки перемотки (опционально)
   - Дизайн в едином стиле с основным UI

4. **Остальные форматы (`.txt`, `.dart`, `.py`, и т.д.):**
   - `flutter_code_editor` с подсветкой синтаксиса (если поддерживается)

**Функция "Музицировать":**
- Открывается **MusicifyDialog**

---

#### 4.2.4. AIAssistant (AI-ассистент)

**UI:**

**Заголовок (toolbar):**
- Иконки:
  - **Новый чат** (MessageSquarePlus) → очистить контекст, начать новый чат
  - **История чатов** (History) → открыть панель истории чатов
  - Разделитель
  - **Режим "Диалог"** (MessageCircle) → активируется по умолчанию
  - **Режим "Создать ТЗ по шаблону"** (FileText) → переключает режим
  - Иконка **Свернуть** (ChevronRight) → свернуть AI-панель вправо

**Основная область:**
- **Если открыта история:**
  - Список сохранённых чатов
  - При клике на чат → загрузить его сообщения, скрыть историю

- **Если режим "Создать ТЗ по шаблону":**
  - Сверху карточка с текущим шаблоном: "Текущий шаблон: {template_name}"

- **Сообщения:**
  - Пользователь: справа, синий фон
  - AI: слева, серый фон, иконка Brain

- **Предлагаемые изменения (если AI предложил изменения):**
  - Карточка с заголовком "AI предлагает изменения:"
  - Diff (красный фон — удаление, желтый фон — изменение)
  - Кнопки:
    - **Принять** (Check) → применить изменения к файлу, показать diff в SpecPreview
    - **Отклонить** (XCircle) → закрыть карточку

**Нижняя панель (input):**
- Кнопки (опционально, можно скрыть по требованию):
  - **Регенерировать** (RotateCw) → повторно отправить последний промпт
  - **Уточнить** (не реализовывать, по требованиям не нужна)
  - **Расширить** (не реализовывать, по требованиям не нужна)

- **model:** кликабельный текст → открывает Popover со списком моделей:
  - При клике → запрос к AI-провайдеру для получения списка моделей
  - Максимум 10 моделей в списке, если больше → скролл
  - При выборе → сохранить `aiSelectedModel` в конфиг

- **Поле ввода (Textarea):**
  - Placeholder: "Например: добавь раздел про уведомления. Используйте @ для выбора файла."
  - Поддержка упоминания файлов:
    - При вводе `@` → открыть список файлов из проекта
    - Фильтрация по введенному тексту после `@`
    - При выборе → вставить `@filename.ext` с визуальным отличием (например, жирный текст)

- **Кнопка "Отправить"** (Send):
  - При нажатии или Enter → отправить сообщение в AI

**Логика отправки сообщения:**

1. **Режим "Диалог":**
   - Промпт:
     ```
     Ты AI-ассистент в программе NovaSpec.
     Ты профессиональный системный/бизнес аналитик. Умеешь грамотно составлять аналитические артефакты (технические задания, спецификаций, функциональной документации, openAPI и т.п.)
     Пользователь через программу написал тебе сообщение: {user_message}
     Контент файлов, которые указал пользователь: {mentioned_files_content}
     У пользователь в рабочей области приложения открыт файл: {active_file_content}

     ВАЖНО: Ответ должен быть в формате Server-Sent Events (SSE) с JSON-стримингом.
     Каждое событие должно быть в формате:
     data: {"type":"message|file_edit|status|error","id":"...","conversation_id":"...","timestamp":...,"data":{...}}

     Для текстового ответа используй тип "message" с полем "text" в data.
     Для предложения изменений файла используй тип "file_edit" с полями "file_path" и "diff" в data.
     Для статусов используй тип "status" с полем "status" в data (значения: thinking, generating, done, failed).
     Для ошибок используй тип "error" с полем "error_message" в data.
     ```

2. **Режим "Создать ТЗ по шаблону":**
   - Промпт:
     ```
     Ты AI-ассистент в программе NovaSpec.
     Ты профессиональный системный/бизнес аналитик. Умеешь грамотно составлять аналитические артефакты (технические задания, спецификаций, функциональной документации, openAPI и т.п.)
     Пользователь через программу написал тебе сообщение: {user_message}
     Контент файлов, которые указал пользователь: {mentioned_files_content}
     По сообщению пользователя необходимо составь аналитический артефакт {template_type} по шаблону: {template_content}

     ВАЖНО: Ответ должен быть в формате Server-Sent Events (SSE) с JSON-стримингом.
     Каждое событие должно быть в формате:
     data: {"type":"message|file_edit|status|error","id":"...","conversation_id":"...","timestamp":...,"data":{...}}

     Для текстового ответа используй тип "message" с полем "text" в data.
     Для предложения изменений файла используй тип "file_edit" с полями "file_path" и "diff" в data.
     Для статусов используй тип "status" с полем "status" в data (значения: thinking, generating, done, failed).
     Для ошибок используй тип "error" с полем "error_message" в data.
     ```

3. **Инструменты для AI:**
   - AI должен иметь инструменты для чтения любых файлов в проекте
   - AI может предлагать изменения в файлах (возвращать diff)

**SSE-интеграция:**
- Использовать HTTP SSE для потоковой передачи ответа от AI
- Формат событий:
  ```json
  {
    "type": "message|file_edit|status|error",
    "id": "string",
    "conversation_id": "string",
    "timestamp": 1712345678,
    "data": {
      "text": "string",
      "file_path": "string",
      "diff": "string",
      "status": "thinking|generating|done|failed",
      "error_message": "string"
    }
  }
  ```

- **Обработка событий:**
  - `type: message` → добавить текст в сообщение AI
  - `type: file_edit` → показать карточку "AI предлагает изменения" с diff
  - `type: status` → обновить статус (показать индикатор "думает", "генерирует")
  - `type: error` → показать уведомление с ошибкой

---

#### 4.2.5. StatusBar

**UI:**
- Слева: пустое место (или логи, если нужно)
- Справа: статус музикации (если активен процесс)

**Статусы музикации:**
1. **"Генерирую Lyrics"** (3 секунды)
2. **"Генерирую музыку в Suno"** (до получения `status: success`)
3. **"Сохраняю трек"** (моментально)
4. **"Музикация выполнена"** (3 секунды, затем исчезает)

**Дополнительно (для отладки):**
- Скрытая кнопка для повторного показа онбординга (через Ctrl+Shift+D)

---

### 4.3. Диалоговые окна

#### 4.3.1. SettingsDialog (Параметры)

**UI:**
- Заголовок: "Параметры"
- Секции:

**1. Провайдер:**
- **Выберите провайдера** (Select):
  - OpenAI
  - OpenAI Competitive
  - Anthropic
  - Cerebras
  - Groq
  - LM Studio
  - Ollama
  - OpenRouter

- **Поля (зависят от провайдера):**
  - **OpenAI:** Токен
  - **OpenAI Competitive:** Базовый URL, Токен
  - **Anthropic:** Токен
  - **Cerebras:** Токен
  - **Groq:** Токен
  - **LM Studio / Ollama:** Базовый URL, Токен (опционально)
  - **OpenRouter:** Токен

**2. Интеграция с Confluence:**
- **Переключатель** (Switch) — включить/выключить
- Если включено:
  - **Базовый URL** (Input)
  - **Email** (Input)
  - **Токен** (Input, password)

- **Автоопределение типа инстанса:**
  - Если домен оканчивается на `.atlassian.net` → **Cloud**
    - Базовый URL для API: `https://<site>.atlassian.net/wiki/rest/api`
  - Иначе → **Data Center / Server**
    - Базовый URL для API: `{baseUrl}/rest/api`

**3. Музикация:**
- **Переключатель** (Switch)
- Если включено:
  - **Токен** (Input, password)
  - **Жанр** (Select):
    - Русский UI: Поп, Русский рэп, Рок, Джаз, Классика, Электронная музыка, Хип-хоп, R&B
    - Английский UI: Pop, Russian rap, Rock, Jazz, Classic, Electro music, Hip-hop, R&B
    - В конфиг сохраняется системное имя: `pop`, `russian_rap`, `rock`, `jazz`, `classic`, `electro_music`, `hip_hop`, `r&b`
  - Подсказка: "Токен можно получить на gen-api.ru"

**4. Язык:**
- **Выберите язык** (Select):
  - Русский
  - Английский

**Кнопки:**
- **Проверить:**
  - Вызвать API каждого настроенного сервиса:
    - **AI-провайдер:** запрос списка моделей
    - **Confluence:** запрос списка пространств (spaces)
    - **Музикация:** `GET https://api.gen-api.ru/api/v1/user`
  - Если все 200 → показать toast "Все интеграции успешно прошли проверку"
  - Если хотя бы одна ошибка → показать ErrorDialog с деталями ошибки
  - **После успешной проверки:** кнопка "Сохранить" становится активной

- **Сохранить:**
  - По умолчанию неактивна
  - Активна только после успешной проверки
  - При нажатии → сохранить все настройки в Hive, закрыть диалог

**Логика:**
- Если пользователь закрыл диалог без сохранения → изменения не сохраняются

---

#### 4.3.2. TemplatesDialog (Шаблоны)

**UI:**
- Заголовок: "Шаблоны"

**Секция 1: Тип шаблона**
- **Раскрывающийся список** с типами шаблонов
- Кнопки:
  - **+** (Plus) → открыть AddTemplateTypeDialog (создание)
  - **Карандаш** (Pencil) → открыть AddTemplateTypeDialog (редактирование)
  - **Корзина** (Trash) → удалить тип (если не по умолчанию)

**Типы по умолчанию:**
- Техническое задание
- Функциональная документация
(Нельзя удалить)

**Секция 2: Шаблон**
- **Раскрывающийся список** с шаблонами (фильтруется по выбранному типу)
- Кнопки:
  - **+** (Plus) → открыть AddTemplateDialog (создание)
  - **Карандаш** (Pencil) → открыть AddTemplateDialog (редактирование)
  - **Корзина** (Trash) → удалить шаблон (если не по умолчанию)

**Шаблоны по умолчанию:**
- Для "Техническое задание": "User Story One Page" (контент из требований)
- Для "Функциональная документация": "Бизнес-ориентированная документация функционала" (контент из требований)

**Кнопка:**
- **Закрыть** → закрыть диалог

---

#### 4.3.3. AddTemplateTypeDialog

**UI:**
- Заголовок: "Добавить тип шаблона" (или "Редактировать тип шаблона")
- Поля:
  - **Название типа шаблона** (Input)
  - **Имя типа** (Input) — системное имя (например, `technical_spec`)
- Кнопки:
  - **Отменить** → закрыть диалог
  - **Сохранить** → сохранить тип в Hive

**Логика:**
- При редактировании → поля предзаполнены
- При сохранении → если создание, добавить новый тип; если редактирование, обновить существующий

---

#### 4.3.4. AddTemplateDialog

**UI:**
- Заголовок: "Добавить шаблон" (или "Редактировать шаблон")
- Поля:
  - **Название шаблона** (Input)
  - **Контент шаблона** (CodeEditor) — `flutter_code_editor` с подсветкой Markdown

**AI-ревью (справа или снизу):**
- **model:** кликабельный текст → Popover со списком моделей (аналогично AI-ассистенту)
- **Кнопка "Отправить на ревью":**
  - Промпт:
    ```
    Ты AI-ассистент в программе NovaSpec, и в рамках данного запроса пользователь отправляет тебе на ревью свой шаблон {template_type}.
    Ты как методолог системных/бизнес аналитиков должен провести ревью шаблона и дать свою экспертную оценку и рекомендации по изменению шаблона.
    В рамках своей экспертной оценки ты должен разделить свои комментарии на критические и рекомендации.
    Критические указываешь, если в шаблоне есть явные несостыковки, которые могут привести генерацию артефакта по данному шаблону к негативным последствиям
    А рекомендации, если это не сильно повлияет на конечный результат.
    Если есть критические замечания, то в ответе обязательно указывай тег @critical_alert, тогда приложение посчитает, что AI-ревью не пройдено и пользователь не сможет сохранить шаблон.
    Относись к критическим замечаниям максимально серьезно! Не стоит по мелачам проставлять замечание как критическое, иначе пользователь перестанет воспринимать тебя в серьез

    ВАЖНО: Ответ должен быть в формате Server-Sent Events (SSE) с JSON-стримингом.
    Каждое событие должно быть в формате:
    data: {"type":"message|status|error","id":"...","conversation_id":"...","timestamp":...,"data":{...}}

    Используй тип "message" для отправки текста ревью (включая тег @critical_alert если нужно).
    Используй тип "status" для индикации процесса (thinking, generating, done).
    Используй тип "error" при возникновении ошибок.
    ```
  - Ответ от AI отображается в стриминг-режиме (SSE)
  - Если в ответе есть `@critical_alert` → кнопка "Сохранить" остаётся неактивной

**Кнопки:**
- **Сохранить без ревью** (активна всегда) → сохранить шаблон в Hive
- **Сохранить** (активна только если ревью пройдено или не было критических замечаний)
- **Отмена** → закрыть диалог

---

#### 4.3.5. MusicifyDialog

**UI:**
- Заголовок: "Музицировать документ"
- Текст: "Вы уверены, что хотите музицировать данный документ? Это займет некоторое время и будет расходываться баланс (~17 руб)."
- Кнопки:
  - **Нет** → закрыть диалог
  - **Да** → запустить процесс музикации

**Логика:**

1. **Генерирую Lyrics:**
   - StatusBar показывает статус "Генерирую Lyrics"
   - Промпт:
     ```
     Составь текст песни, чтобы зачитать данные требования в жанре {music_genre}.
     Текст должен быть сделан в виде Lyrics пригодным для Suno
     В ответе не указывай ничего лишнего, исключительно Lyrics
     Требования: {file_content}
     ```
   - Модель: текущая модель AI из конфига
   - Сохранить полученные lyrics

2. **Генерирую музыку в Suno:**
   - StatusBar показывает статус "Генерирую музыку в Suno"
   - API:
     ```bash
     POST https://api.gen-api.ru/api/v1/networks/suno
     Headers:
       Authorization: Bearer {music_token}
       Content-Type: application/json
     Body:
     {
       "title": "{project_name или file_name}",
       "tags": "{music_genre}",
       "prompt": "{lyrics}",
       "translate_input": false,
       "model": "v5"
     }
     ```

   - **Обработка ответа:**
     - **200/201:** получить `request_id`, начать polling
     - **402:** показать ErrorDialog "Недостаточно средств на балансе gen-api"
     - **Другие ошибки:** показать ErrorDialog с деталями

3. **Polling (каждые 2 секунды):**
   - API:
     ```bash
     GET https://api.gen-api.ru/api/v1/request/get/{request_id}
     Headers:
       Authorization: Bearer {music_token}
     ```
   - Следить за полем `status`
   - Когда `status == "success"` → перейти к следующему шагу

4. **Сохраняю трек:**
   - StatusBar показывает статус "Сохраняю трек"
   - Из ответа взять массив `full_response`, найти элементы с полем `url`
   - Скачать каждый MP3-файл с помощью `dio`
   - Сохранить файлы в папку проекта с именами из URL
   - Обновить FileExplorer (добавить файлы в дерево)

5. **Музикация выполнена:**
   - StatusBar показывает "Музикация выполнена" на 3 секунды
   - Затем статус исчезает
   - Показать toast с именами сохранённых файлов

**Ошибки:**
- Если на любом этапе ошибка → показать ErrorDialog с деталями

---

#### 4.3.6. AboutDialog

**UI:**
- Заголовок: "О программе"
- Текст:
  ```
  NovaSpec
  Профессиональный инструмент для совместной выработки технических заданий с ИИ-ассистентом. Превращает идеи в структурированную документацию.
  ```
- **Версия:** `{version из pubspec.yaml}`
- **Создатель:** `Koteyye` (или из pubspec.yaml)

**Кнопка:**
- **Закрыть**

---

#### 4.3.7. ErrorDialog

**UI:**
- Заголовок: "Ошибка"
- Иконка: красный крест или AlertTriangle
- Текст ошибки (переданный при вызове)
- Кнопка: **OK**

**Логика:**
- Показывается при ошибках во всех действиях, кроме AI-ассистента (там используются toast-уведомления)

---

## 5. AI-интеграция

### 5.1. Поддерживаемые провайдеры

#### 5.1.1. OpenAI

**Endpoint:**
```
POST https://api.openai.com/v1/chat/completions
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Body:**
```json
{
  "model": "gpt-4o",
  "messages": [{"role": "user", "content": "..."}],
  "stream": true
}
```

#### 5.1.2. OpenAI Competitive

Аналогично OpenAI, но с кастомным `baseUrl`:
```
POST {baseUrl}/v1/chat/completions
```

#### 5.1.3. Anthropic

**Endpoint:**
```
POST https://api.anthropic.com/v1/messages
```

**Headers:**
```
x-api-key: {token}
anthropic-version: 2023-06-01
Content-Type: application/json
```

**Body:**
```json
{
  "model": "claude-3-5-sonnet-20240620",
  "max_tokens": 4096,
  "messages": [{"role": "user", "content": "..."}],
  "stream": true
}
```

**Получение моделей:**
```
GET https://api.anthropic.com/v1/models
Headers:
  x-api-key: {token}
  anthropic-version: 2023-06-01
```

#### 5.1.4. Cerebras

**Endpoint:**
```
POST https://api.cerebras.ai/openai/v1/chat/completions
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Получение моделей:**
```
GET https://api.cerebras.ai/openai/v1/models
Headers:
  Authorization: Bearer {token}
```

#### 5.1.5. Groq

**Endpoint:**
```
POST https://api.groq.com/openai/v1/chat/completions
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

#### 5.1.6. LM Studio / Ollama

Аналогично OpenAI Competitive, но токен опционален:
```
POST {baseUrl}/v1/chat/completions
Headers:
  Authorization: Bearer {token} (опционально)
```

#### 5.1.7. OpenRouter

**Endpoint:**
```
POST https://openrouter.ai/api/v1/chat/completions
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

### 5.2. Общие требования

- Все запросы должны поддерживать **streaming (SSE)**
- Обработка ошибок для каждого провайдера
- Таймауты: 120 секунд для обычных запросов, без таймаута для streaming

---

## 6. Confluence-интеграция

### 6.1. Определение типа инстанса

- Если домен оканчивается на `.atlassian.net` → **Cloud**
  - Базовый URL: `https://<site>.atlassian.net/wiki/rest/api`
- Иначе → **Data Center / Server**
  - Базовый URL: `{siteUrl}/rest/api`

### 6.2. Проверка интеграции

**Endpoint (Cloud):**
```
GET https://<site>.atlassian.net/wiki/rest/api/space
Headers:
  Authorization: Basic {base64(email:token)}
```

**Endpoint (DC/Server):**
```
GET {baseUrl}/rest/api/space
Headers:
  Authorization: Basic {base64(username:password)}
```

**Успешный ответ:** 200, список пространств

---

## 7. Музикация (gen-api.ru)

### 7.1. Проверка токена

**Endpoint:**
```
GET https://api.gen-api.ru/api/v1/user
Headers:
  Authorization: Bearer {token}
```

**Ответ:**
```json
{
  "name": "...",
  "email": "...",
  "balance": 1250,
  ...
}
```

### 7.2. Генерация музыки

**Endpoint:**
```
POST https://api.gen-api.ru/api/v1/networks/suno
Headers:
  Authorization: Bearer {token}
  Content-Type: application/json
Body:
{
  "title": "...",
  "tags": "{genre}",
  "prompt": "{lyrics}",
  "translate_input": false,
  "model": "v5"
}
```

**Ответ (200/201):**
```json
{
  "request_id": 28104643,
  "model": "suno",
  "status": "processing"
}
```

**Ошибки:**
- **402:** Недостаточно средств
- **400:** Запрос не найден
- **401:** Неверный токен
- **404:** Несуществующая нейросеть
- **503/419:** Ошибка сервера

### 7.3. Polling статуса

**Endpoint:**
```
GET https://api.gen-api.ru/api/v1/request/get/{request_id}
Headers:
  Authorization: Bearer {token}
```

**Ответ (успешный):**
```json
{
  "id": 28104643,
  "status": "success",
  "progress": 100,
  "full_response": [
    {"url": "https://...mp3"},
    {"url": "https://...mp3"},
    ...
  ],
  ...
}
```

---

## 8. Локализация

### 8.1. Поддерживаемые языки

- Русский (ru)
- Английский (en)

### 8.2. Ключи локализации

**Примеры:**
```
onboarding_title
onboarding_description
file_menu
new_project
open_project
save
save_as
settings_menu
parameters
templates
about_program
ai_provider
confluence_integration
musicification
error_dialog_title
musicify_confirm_title
musicify_confirm_message
...
```

### 8.3. Жанры музыки

**Русский:**
```
pop: Поп
russian_rap: Русский рэп
rock: Рок
jazz: Джаз
classic: Классика
electro_music: Электронная музыка
hip_hop: Хип-хоп
r&b: R&B
```

**Английский:**
```
pop: Pop
russian_rap: Russian rap
rock: Rock
jazz: Jazz
classic: Classic
electro_music: Electro music
hip_hop: Hip-hop
r&b: R&B
```

---

## 9. Дизайн-система (NsTheme)

### 9.1. Цвета

**Светлая тема:**
```dart
const Color nsBackgroundLight = Color(0xFFF5F5F5);
const Color nsPanelLight = Color(0xFFFFFFFF);
const Color nsEditorLight = Color(0xFFFAFAFA);
const Color nsBorderLight = Color(0xFFE0E0E0);
const Color nsPrimaryLight = Color(0xFF2563EB);
const Color nsAccentLight = Color(0xFFFBBF24);
const Color nsIndicatorActive = Color(0xFF10B981);
const Color nsIndicatorInactive = Color(0xFF9CA3AF);
```

**Тёмная тема:**
```dart
const Color nsBackgroundDark = Color(0xFF1E1E1E);
const Color nsPanelDark = Color(0xFF252525);
const Color nsEditorDark = Color(0xFF1E1E1E);
const Color nsBorderDark = Color(0xFF3E3E3E);
const Color nsPrimaryDark = Color(0xFF3B82F6);
const Color nsAccentDark = Color(0xFFFBBF24);
```

### 9.2. Компоненты

**NsButton:**
- Variants: primary, secondary, outline, ghost
- Sizes: small, medium, large
- Border radius: 8px
- Padding: 12px 24px (medium)

**NsTextField:**
- Border: 1px solid nsBorder
- Border radius: 8px
- Padding: 10px 12px
- Focus border: nsPrimary

**NsCard:**
- Background: nsPanel
- Border: 1px solid nsBorder
- Border radius: 12px
- Padding: 16px

**NsDialog:**
- Overlay: черный с opacity 0.5
- Background: nsPanel
- Border radius: 16px
- Max width: зависит от контента

---

## 10. Структура файловой системы проекта

При создании нового проекта создаётся папка:
```
{selected_path}/{project_name}/
```

Внутри могут находиться любые файлы, созданные пользователем или генерируемые (MP3, MD, HTML, JSON, YAML и т.д.)

---

## 11. Обработка ошибок

### 11.1. Диалоговое окно (ErrorDialog)

Используется для всех ошибок, **кроме ошибок AI-ассистента**.

**Примеры:**
- Ошибка при проверке интеграций в SettingsDialog
- Ошибка при музикации

### 11.2. Toast-уведомления

Используются для:
- Успешные действия ("Баланс обновлен", "Трек сохранён")
- Ошибки в AI-ассистенте

---

## 12. Особенности реализации

### 12.1. Swagger UI

**Архитектура:**
1. Запустить фоновый `shelf`-сервер на `127.0.0.1:4001`
2. Использовать `shelf_swagger_ui.fromFile()` для рендера спецификации
3. Открыть в `webview_flutter` с `javascriptMode: JavascriptMode.unrestricted`
4. При выборе другого файла → перезапустить сервер с новой спецификацией

**Проверка OpenAPI:**
- Проверить наличие ключей: `openapi`, `info`, `paths`

### 12.2. Аудиоплеер

- Использовать `just_audio`
- Минималистичный UI:
  - Play/Pause button
  - Seek bar
  - Time display (current / total)
  - Volume control (опционально)

### 12.3. Редактор кода

- Использовать `flutter_code_editor`
- Подсветка синтаксиса для: Markdown, HTML, JSON, YAML, Dart, Python, JavaScript, и т.д.
- Сохранение изменений при Ctrl+S

### 12.4. Работа с файлами

- **Чтение:** `File.readAsString()`, `File.readAsBytes()`
- **Запись:** `File.writeAsString()`, `File.writeAsBytes()`
- **Выбор папки:** `file_picker` с `directoryPath`
- **Выбор файла для сохранения:** `file_picker` в режиме save

### 12.5. Горячие клавиши

- **Ctrl+N:** Новый проект
- **Ctrl+O:** Открыть проект
- **Ctrl+S:** Сохранить
- **Ctrl+,:** Параметры
- **Enter:** Отправить сообщение в AI (в фокусе textarea)

**Реализация:** `Shortcuts` + `Actions` или `raw_keyboard`

---

## 13. Нефункциональные требования

### 13.1. Производительность

- Плавная прокрутка списка файлов
- Быстрое переключение между вкладками
- SSE-стриминг без задержек

### 13.2. Безопасность

- Токены хранятся в Hive (зашифровано)
- Не логировать токены в консоль

### 13.3. Совместимость

- macOS 10.14+
- Windows 10+

### 13.4. Доступность

- Поддержка клавиатурной навигации
- Tooltips для всех иконок

---

## 14. Миграция с TypeScript

### 14.1. Соответствие компонентов

| TypeScript | Flutter |
|------------|---------|
| `TopBar.tsx` | `top_bar.dart` |
| `FileExplorer.tsx` | `file_explorer.dart` |
| `SpecPreview.tsx` | `spec_preview.dart` |
| `AIAssistant.tsx` | `ai_assistant.dart` |
| `StatusBar.tsx` | `status_bar.dart` |
| `OnboardingDialog.tsx` | `onboarding_dialog.dart` |
| `SettingsDialog.tsx` | `settings_dialog.dart` |
| `TemplatesDialog.tsx` | `templates_dialog.dart` |
| `MusicifyDialog.tsx` | `musicify_dialog.dart` |
| `AboutDialog.tsx` | `about_dialog.dart` |
| `ErrorDialog.tsx` | `error_dialog.dart` |

### 14.2. UI-библиотеки

| TypeScript (shadcn/ui) | Flutter |
|------------------------|---------|
| `Button` | `NsButton` |
| `Input` | `NsTextField` |
| `Select` | `DropdownButton` или кастомный `NsSelect` |
| `Dialog` | `showDialog()` с кастомным `NsDialog` |
| `Tooltip` | `Tooltip` |
| `Switch` | `Switch` |
| `Textarea` | `TextField(maxLines: null)` |
| `ScrollArea` | `SingleChildScrollView` |
| `Tabs` | `TabBar` + `TabBarView` |

### 14.3. Иконки

- Использовать пакет `lucide_icons` (аналог Lucide React)
- Если иконки нет → заменить на `Icons.*` из Material

---

## 16. Развёртывание

### 16.1. macOS

- Сборка: `flutter build macos --release`
- Подписание: Xcode или manual signing
- DMG: использовать `appdmg` или `create-dmg`

### 16.2. Windows

- Сборка: `flutter build windows --release`
- Installer: Inno Setup или NSIS

---

## 17. Дополнительные требования

### 17.1. Логирование

- Использовать `logger` пакет
- Логировать:
  - Сетевые запросы (без токенов)
  - Ошибки
  - Важные действия пользователя

### 17.2. Аналитика (опционально)

- Можно добавить в будущем

### 17.3. Обновления (опционально)

- Auto-updater для проверки новых версий

---

## 18. Зависимости (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1

  # Routing
  go_router: ^14.2.0

  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.3

  # HTTP
  dio: ^5.5.0
  http: ^1.2.1

  # File operations
  file_picker: ^8.0.3

  # Audio
  just_audio: ^0.9.38

  # Code editor
  flutter_code_editor: ^0.3.3

  # Swagger UI
  shelf: ^1.4.1
  shelf_swagger_ui: ^1.0.0
  webview_flutter: ^4.8.0

  # Markdown/HTML rendering
  flutter_markdown: ^0.7.3
  flutter_html: ^3.0.0-beta.2

  # Icons
  lucide_icons: ^0.1.0

  # Utils
  intl: ^0.19.0
  logger: ^2.3.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
  flutter_lints: ^4.0.0
```

---

## 19. Приоритеты реализации

### Фаза 1 (MVP):
1. Онбординг (создание/открытие проекта)
2. Главный экран (TopBar, FileExplorer, SpecPreview без AI)
3. Настройки (SettingsDialog) — базовая версия
4. Работа с файлами (чтение, редактирование, сохранение)
5. Hive-конфигурация

### Фаза 2:
1. AI-ассистент (базовый диалог)
2. Интеграция с одним AI-провайдером (OpenAI)
3. Режим "Диалог" в AI
4. Шаблоны (TemplatesDialog, дефолтные шаблоны)

### Фаза 3:
1. Музикация (MusicifyDialog, gen-api интеграция)
2. Все AI-провайдеры
3. Confluence-интеграция
4. SSE-стриминг для AI
5. Swagger UI для OpenAPI

### Фаза 4:
1. Аудиоплеер для MP3/WAV
2. AI-ревью шаблонов
3. Режим "Создать ТЗ по шаблону"
4. История чатов
5. Упоминание файлов (@file)

### Фаза 5:
1. Полировка UI
2. Локализация (английский)
3. Горячие клавиши
4. Тестирование
5. Документация

---

## 20. Вопросы и риски

### 20.1. Вопросы

1. **Хранение токенов:** Использовать ли дополнительное шифрование поверх Hive?
   - **Рекомендация:** Да, использовать `hive` с `encryptionCipher`

2. **Поддержка других форматов:** Нужно ли поддерживать PDF, DOCX?
   - **Решение:** На первом этапе нет, в будущем можно добавить

3. **Ограничения размера файлов:** Какой максимальный размер файла для редактирования?
   - **Рекомендация:** 10 MB для текстовых файлов, предупреждение при больших файлах

4. **Многопоточность для Swagger UI:** Нужно ли запускать shelf-сервер в отдельном изоляте?
   - **Решение:** Да, для избежания блокировки UI

### 20.2. Риски

1. **Совместимость WebView на Windows:** Могут быть проблемы с рендерингом Swagger UI
   - **Митигация:** Тестировать на ранних этапах, подготовить fallback (показ JSON/YAML вместо UI)

2. **Производительность SSE:** Длительные стримы могут вызвать задержки
   - **Митигация:** Оптимизация парсинга, использование изолятов

3. **Разные версии API провайдеров:** Изменения в API могут сломать интеграцию
   - **Митигация:** Версионирование, обработка ошибок, документация версий

4. **Безопасность токенов:** Утечка токенов через логи или ошибки
   - **Митигация:** Строгий контроль логирования, использование environment variables для разработки

---

## 21. Заключение

Данная спецификация описывает полное техническое задание на разработку Flutter-приложения **NovaSpec** для macOS и Windows. Приложение включает в себя:

- Онбординг и управление проектами
- Редактор документации с поддержкой Markdown, HTML, YAML, JSON, аудио
- AI-ассистент с поддержкой 8 провайдеров и SSE-стриминга
- Интеграцию с Confluence
- Музикацию документов через gen-api.ru и Suno
- Систему шаблонов с AI-ревью
- Двуязычную локализацию
- Современный, адаптивный UI в стиле референса на TypeScript

Все требования детализированы, архитектура описана, зависимости перечислены. Спецификация готова к согласованию и последующей реализации.

---

**Дата создания:** 2025-01-XX
**Версия:** 1.0
**Автор:** Claude (AI-ассистент)
