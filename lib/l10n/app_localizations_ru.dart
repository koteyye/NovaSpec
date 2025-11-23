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
  String get musication_no_content =>
      'Выберите текст или откройте файл с содержимым';

  @override
  String get musication_tray_show => 'Показать NovaSpec';

  @override
  String get musication_tray_exit => 'Завершить работу';

  @override
  String get musication_error_no_api_key => 'API ключ gen-api.ru не настроен';

  @override
  String get musication_error_no_ai_model => 'AI модель не выбрана';

  @override
  String get musication_error_no_content =>
      'Выберите текст или откройте файл с содержимым';

  @override
  String get musication_error_invalid_api_key => 'Неверный API ключ gen-api.ru';

  @override
  String get musication_error_insufficient_funds =>
      'Недостаточно средств на балансе';

  @override
  String get musication_error_unauthorized => 'Неверный токен авторизации';

  @override
  String get musication_error_forbidden => 'Доступ запрещен';

  @override
  String get musication_error_not_found => 'Ресурс не найден';

  @override
  String get musication_error_request_not_found =>
      'Запрос с таким ID не найден';

  @override
  String get musication_error_model_not_found => 'Указанная модель не найдена';

  @override
  String get musication_error_too_many_requests =>
      'Слишком много запросов, попробуйте позже';

  @override
  String get musication_error_service_error =>
      'Ошибка сервиса, обратитесь в поддержку';

  @override
  String get musication_error_network => 'Ошибка сети';

  @override
  String get musication_error_connection_timeout => 'Таймаут подключения';

  @override
  String get musication_error_lyrics_generation_failed =>
      'Ошибка генерации текста песни';

  @override
  String get musication_error_empty_lyrics_response =>
      'Получен пустой ответ от AI модели';

  @override
  String get musication_error_music_generation_failed =>
      'Ошибка генерации музыки';

  @override
  String get musication_error_polling_timeout =>
      'Таймаут генерации музыки (10 минут)';

  @override
  String get musication_error_polling_failed =>
      'Ошибка проверки статуса генерации';

  @override
  String get musication_error_file_download_failed => 'Ошибка скачивания файла';

  @override
  String get musication_error_file_save_failed => 'Ошибка сохранения файла';

  @override
  String get musication_error_unknown => 'Неизвестная ошибка';

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
  String get componentDemo => 'Демонстрация компонентов';

  @override
  String get buttons => 'Кнопки';

  @override
  String get textFields => 'Текстовые поля';

  @override
  String get dialogs => 'Диалоги';

  @override
  String get toastNotifications => 'Toast уведомления';

  @override
  String get otherComponents => 'Другие компоненты';

  @override
  String get primaryButtons => 'Основные кнопки';

  @override
  String get secondaryButtons => 'Вторичные кнопки';

  @override
  String get tertiaryButtons => 'Третичные кнопки';

  @override
  String get statusButtons => 'Кнопки статуса';

  @override
  String get toggleButtons => 'Переключатели';

  @override
  String get iconButtons => 'Иконочные кнопки';

  @override
  String get tertiaryWithIcons => 'Третичные с иконками';

  @override
  String get normalTextField => 'Обычное текстовое поле';

  @override
  String get enterText => 'Введите текст...';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Пароль';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get description => 'Описание';

  @override
  String get enterDescription => 'Введите описание...';

  @override
  String get searchComponents => 'Поиск компонентов...';

  @override
  String get disabledField => 'Отключенное поле';

  @override
  String get fieldDisabled => 'Это поле отключено';

  @override
  String get valueCannotBeChanged => 'Значение не может быть изменено';

  @override
  String get confirmDialog => 'Диалог подтверждения';

  @override
  String get inputDialog => 'Диалог ввода';

  @override
  String get choiceDialog => 'Диалог выбора';

  @override
  String get loadingDialog => 'Диалог загрузки';

  @override
  String get testingToastNotifications => 'Тестирование toast уведомлений:';

  @override
  String get defaultToast => 'Toast по умолчанию';

  @override
  String get successToast => 'Успешный Toast';

  @override
  String get warningToast => 'Предупреждающий Toast';

  @override
  String get errorToast => 'Toast ошибки';

  @override
  String get svgIcons => 'SVG иконки:';

  @override
  String get indicators => 'Индикаторы:';

  @override
  String get active => 'Активен';

  @override
  String get inProgress => 'В процессе';

  @override
  String get completed => 'Завершено';

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
