// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'NovaSpec';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get ok => 'ОК';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get create => 'Создать';

  @override
  String get close => 'Закрыть';

  @override
  String get projects => 'Проекты';

  @override
  String get settings => 'Настройки';

  @override
  String get workspace => 'Рабочее пространство';

  @override
  String get aiAssistant => 'AI Ассистент';

  @override
  String get fileExplorer => 'Файловый менеджер';

  @override
  String get templates => 'Шаблоны';

  @override
  String get newProject => 'Новый проект';

  @override
  String get openProject => 'Открыть проект';

  @override
  String get recentProjects => 'Недавние проекты';

  @override
  String get projectName => 'Название проекта';

  @override
  String get projectDescription => 'Описание проекта';

  @override
  String get projectManagement => 'Управление проектами';

  @override
  String get theme => 'Тема';

  @override
  String get darkTheme => 'Темная тема';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get systemTheme => 'Системная тема';

  @override
  String get about => 'О программе';

  @override
  String get sendMessage => 'Отправить сообщение';

  @override
  String get typeMessage => 'Введите ваше сообщение...';

  @override
  String get aiThinking => 'AI думает...';

  @override
  String get files => 'Файлы';

  @override
  String get folders => 'Папки';

  @override
  String get createFile => 'Создать файл';

  @override
  String get createFolder => 'Создать папку';

  @override
  String get rename => 'Переименовать';

  @override
  String get copy => 'Копировать';

  @override
  String get cut => 'Вырезать';

  @override
  String get newName => 'Новое имя';

  @override
  String get folderName => 'Имя папки';

  @override
  String get file => 'файл';

  @override
  String get folder => 'папку';

  @override
  String confirmDelete(Object name, Object type) {
    return 'Вы уверены, что хотите удалить $type \"$name\"?';
  }

  @override
  String get createNewFile => 'Создать новый файл';

  @override
  String get fileName => 'Имя файла';

  @override
  String get enterFileName => 'Введите имя файла';

  @override
  String get fileType => 'Тип файла';

  @override
  String get template => 'Шаблон';

  @override
  String get creating => 'Создание...';

  @override
  String get enterFileNameError => 'Введите имя файла';

  @override
  String get musication => 'Музикация';

  @override
  String get musication_button_tooltip => 'Создать музыку на основе текста';

  @override
  String get musication_select_genre => 'Выберите жанр';

  @override
  String get musication_generating_lyrics => 'Генерация текста песни';

  @override
  String get musication_generating_audio => 'Генерация аудио';

  @override
  String get musication_saving_audio => 'Сохранение аудио';

  @override
  String get musication_completed => 'Музикация завершена';

  @override
  String get musication_failed => 'Ошибка музикации';

  @override
  String get musication_cancel => 'Отмена';

  @override
  String get musication_cancel_confirmation => 'Отменить музикацию?';

  @override
  String get musication_balance => 'Баланс';

  @override
  String get musication_insufficient_balance =>
      'Недостаточно средств на балансе';

  @override
  String get musication_api_key_not_set => 'API ключ gen-api.ru не настроен';

  @override
  String get musication_invalid_api_key => 'Неверный API ключ gen-api.ru';

  @override
  String get musication_generation_timeout => 'Таймаут генерации музыки';

  @override
  String get musication_select_directory =>
      'Выберите директорию для сохранения музыки';

  @override
  String get musication_files_saved => 'Файлы успешно сохранены';

  @override
  String get musication_error => 'Ошибка музикации';

  @override
  String get musication_retry => 'Повторить';

  @override
  String get musication_close => 'Закрыть';

  @override
  String get genre_pop => 'Поп';

  @override
  String get genre_russian_rap => 'Русский рэп';

  @override
  String get genre_rock => 'Рок';

  @override
  String get genre_jazz => 'Джаз';

  @override
  String get genre_classic => 'Классика';

  @override
  String get genre_electronic => 'Электронная музыка';

  @override
  String get genre_hiphop => 'Хип-хоп';

  @override
  String get genre_rnb => 'R&B';

  @override
  String get invalidFileNameError => 'Имя содержит недопустимые символы';

  @override
  String fileCreated(Object fileName) {
    return 'Файл \"$fileName\" создан';
  }

  @override
  String createFileError(Object error) {
    return 'Ошибка создания файла: $error';
  }

  @override
  String get switchToEnglish => 'Переключить на английский';

  @override
  String get switchToRussian => 'Переключить на русский';

  @override
  String get svgIconsTest => 'Тест SVG иконок';

  @override
  String get homeScreen => 'Главный экран';

  @override
  String get workspaceScreen => 'Рабочее пространство';

  @override
  String get projectManagementScreen => 'Управление проектами';

  @override
  String get settingsScreen => 'Настройки';

  @override
  String get aiAssistantScreen => 'AI Ассистент';

  @override
  String get fileExplorerScreen => 'Файловый менеджер';

  @override
  String get templatesScreen => 'Шаблоны';

  @override
  String get specPreview => 'Предпросмотр спецификации';

  @override
  String get specContent => 'Содержимое спецификации';

  @override
  String get textEditor => 'Текстовый редактор';

  @override
  String get initialContent => 'Начальное содержимое';

  @override
  String get swaggerUrl => 'Swagger URL';

  @override
  String get pageNotFound => 'Страница не найдена';

  @override
  String get noOpenProject => 'Нет открытого проекта';

  @override
  String get workspaceComingSoon => 'Рабочее пространство скоро будет доступно';

  @override
  String get workspaceNextVersion =>
      'Рабочее пространство будет доступно в следующей версии';

  @override
  String get appTitle => 'NovaSpec - Фаза 2 завершена';

  @override
  String get languageTest => 'Тест языка (ru)';

  @override
  String get autoSave => 'Автосохранение';

  @override
  String get notifications => 'Уведомления';

  @override
  String get autoSaveDescription => 'Автоматически сохранять изменения';

  @override
  String get notificationsDescription => 'Показывать уведомления приложения';

  @override
  String get resetSettings => 'Сбросить настройки';

  @override
  String get resetSettingsConfirm =>
      'Вы уверены, что хотите сбросить все настройки к значениям по умолчанию?';

  @override
  String get reset => 'Сбросить';

  @override
  String get language => 'Язык';

  @override
  String get save => 'Сохранить';

  @override
  String get errorLoadingSettings => 'Ошибка загрузки настроек';

  @override
  String get errorSavingSettings => 'Ошибка сохранения настроек';

  @override
  String get errorResettingSettings => 'Ошибка сброса настроек';

  @override
  String get settingsSaved => 'Настройки сохранены успешно';

  @override
  String get settingsReset => 'Настройки сброшены к значениям по умолчанию';

  @override
  String get back => 'Назад';

  @override
  String get componentDemo => 'Component Demo';

  @override
  String get buttons => 'Buttons';

  @override
  String get textFields => 'Text Fields';

  @override
  String get dialogs => 'Dialogs';

  @override
  String get toastNotifications => 'Toast Notifications';

  @override
  String get otherComponents => 'Other Components';

  @override
  String get primaryButtons => 'Primary Buttons';

  @override
  String get secondaryButtons => 'Secondary Buttons';

  @override
  String get tertiaryButtons => 'Tertiary Buttons';

  @override
  String get statusButtons => 'Status Buttons';

  @override
  String get toggleButtons => 'Toggle Buttons';

  @override
  String get iconButtons => 'Icon Buttons';

  @override
  String get tertiaryWithIcons => 'Tertiary with Icons';

  @override
  String get normalTextField => 'Normal Text Field';

  @override
  String get enterText => 'Enter text...';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get description => 'Description';

  @override
  String get enterDescription => 'Enter description...';

  @override
  String get searchComponents => 'Search components...';

  @override
  String get disabledField => 'Disabled Field';

  @override
  String get fieldDisabled => 'This field is disabled';

  @override
  String get valueCannotBeChanged => 'Value cannot be changed';

  @override
  String get confirmDialog => 'Confirm Dialog';

  @override
  String get inputDialog => 'Input Dialog';

  @override
  String get choiceDialog => 'Choice Dialog';

  @override
  String get loadingDialog => 'Loading Dialog';

  @override
  String get testingToastNotifications => 'Testing toast notifications:';

  @override
  String get defaultToast => 'Default Toast';

  @override
  String get successToast => 'Success Toast';

  @override
  String get warningToast => 'Warning Toast';

  @override
  String get errorToast => 'Error Toast';

  @override
  String get svgIcons => 'SVG Icons:';

  @override
  String get indicators => 'Indicators:';

  @override
  String get active => 'Active';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get parameters => 'Параметры';

  @override
  String get aiProviders => 'AI Провайдеры';

  @override
  String get openAi => 'OpenAI';

  @override
  String get claude => 'Claude';

  @override
  String get gemini => 'Gemini';

  @override
  String get deepseek => 'DeepSeek';

  @override
  String get ollama => 'Ollama';

  @override
  String get lmStudio => 'LM Studio';

  @override
  String get zAi => 'Z.AI';

  @override
  String get baseUrl => 'Базовый URL';

  @override
  String get apiKey => 'API Ключ';

  @override
  String get enterBaseUrl => 'Введите базовый URL...';

  @override
  String get enterApiKey => 'Введите API ключ...';

  @override
  String get confluenceIntegration => 'Интеграция с Confluence';

  @override
  String get confluenceUrl => 'URL Confluence';

  @override
  String get confluenceUsername => 'Имя пользователя Confluence';

  @override
  String get confluenceToken => 'Токен Confluence';

  @override
  String get enterConfluenceUrl => 'Введите URL Confluence...';

  @override
  String get enterConfluenceUsername =>
      'Введите имя пользователя Confluence...';

  @override
  String get enterConfluenceToken => 'Введите токен Confluence...';

  @override
  String get musicIntegration => 'Музыкальная интеграция';

  @override
  String get musicProvider => 'Музыкальный провайдер';

  @override
  String get spotify => 'Spotify';

  @override
  String get youtubeMusic => 'YouTube Music';

  @override
  String get musicGenre => 'Музыкальный жанр';

  @override
  String get classical => 'Классическая';

  @override
  String get jazz => 'Джаз';

  @override
  String get electronic => 'Электронная';

  @override
  String get rock => 'Рок';

  @override
  String get pop => 'Поп';

  @override
  String get hipHop => 'Хип-хоп';

  @override
  String get ambient => 'Эмбиент';

  @override
  String get loFi => 'Lo-Fi';

  @override
  String get zAiAccessType => 'Тип доступа Z.AI';

  @override
  String get free => 'Бесплатный';

  @override
  String get premium => 'Премиум';

  @override
  String get testConnection => 'Проверить соединение';

  @override
  String get testing => 'Проверка...';

  @override
  String get connectionSuccessful => 'Соединение успешно!';

  @override
  String get connectionFailed => 'Соединение не удалось!';

  @override
  String get invalidUrl => 'Неверный формат URL';

  @override
  String get invalidApiKey => 'Неверный формат API ключа';

  @override
  String get tokenRequired => 'Требуется API токен';

  @override
  String get urlRequired => 'Требуется базовый URL';

  @override
  String get usernameRequired => 'Требуется имя пользователя';

  @override
  String get confluenceUrlRequired => 'Требуется URL Confluence';

  @override
  String get confluenceTokenRequired => 'Требуется токен Confluence';

  @override
  String projectCreatedSuccessfully(Object projectName) {
    return 'Проект \"$projectName\" успешно создан';
  }

  @override
  String failedToCreateProject(Object error) {
    return 'Не удалось создать проект: $error';
  }

  @override
  String get noProjectToSave => 'Нет проекта для сохранения';

  @override
  String get projectSavedSuccessfully => 'Проект успешно сохранен';

  @override
  String failedToSaveProject(Object error) {
    return 'Не удалось сохранить проект: $error';
  }

  @override
  String projectSavedAsSuccessfully(Object projectName) {
    return 'Проект успешно сохранен как \"$projectName\"';
  }

  @override
  String failedToSaveProjectAs(Object error) {
    return 'Не удалось сохранить проект как: $error';
  }

  @override
  String get projectFileInaccessible => 'Файл проекта стал недоступен';

  @override
  String get projectFileAccessible => 'Файл проекта снова доступен';

  @override
  String get projectFolderInaccessible => 'Папка проекта стала недоступна';

  @override
  String get projectFolderAccessible => 'Папка проекта снова доступна';

  @override
  String folderProjectOpenedSuccessfully(Object projectName) {
    return 'Папочный проект \"$projectName\" успешно открыт';
  }

  @override
  String failedToOpenFolderProject(Object error) {
    return 'Не удалось открыть папочный проект: $error';
  }

  @override
  String get projectStatusAccessible => 'Доступен';

  @override
  String get projectStatusInaccessible => 'Недоступен';

  @override
  String get projectStatusError => 'Ошибка';

  @override
  String get projectStatusSynced => 'Синхронизирован';

  @override
  String get projectStatusConflict => 'Конфликт';

  @override
  String get projectStatusPending => 'Ожидание';

  @override
  String get projectStatusOffline => 'Офлайн';

  @override
  String get expandFileExplorerPanel => 'Развернуть панель файлов';

  @override
  String get collapseFileExplorerPanel => 'Свернуть панель файлов';

  @override
  String get refresh => 'Обновить';

  @override
  String fileCreationErrorPermissionDenied(Object directory) {
    return 'Отказано в доступе: Невозможно создать файлы в директории \"$directory\"';
  }

  @override
  String fileAlreadyExists(Object fileName) {
    return 'Файл \"$fileName\" уже существует';
  }

  @override
  String invalidFileName(Object fileName) {
    return 'Недопустимое имя файла: \"$fileName\"';
  }

  @override
  String permissionDenied(Object directory) {
    return 'Отказано в доступе к директории \"$directory\"';
  }

  @override
  String directoryNotFound(Object directory) {
    return 'Директория не найдена: \"$directory\"';
  }

  @override
  String get diskFull => 'Диск заполнен, невозможно создать файл';

  @override
  String get unknownError => 'Произошла неизвестная ошибка';

  @override
  String fileCreationError(Object error) {
    return 'Ошибка создания файла: $error';
  }
}
