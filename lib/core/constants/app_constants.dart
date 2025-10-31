class AppConstants {
  // App Information
  static const String appName = 'NovaSpec';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'NovaSpec - Flutter/Dart версия приложения для создания технических заданий с ИИ-ассистентом';
  
  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.novaspec.com',
  );
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int apiMaxRetries = 3;
  
  // Storage Keys
  static const String configKey = 'app_configuration';
  static const String navigationKey = 'navigation_state';
  static const String userPreferencesKey = 'user_preferences';
  static const String recentProjectsKey = 'recent_projects';
  static const String workspaceKey = 'workspace_settings';
  
  // Secure Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String apiKeyKey = 'api_key';
  static const String userCredentialsKey = 'user_credentials';
  
  // Legacy Keys (for backward compatibility)
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String firstLaunchKey = 'first_launch';
  static const String apiTokenKey = 'api_token';
  
  // File Constraints
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxFileSize = maxFileSizeBytes; // Legacy compatibility
  static const int maxFileNameLength = 255;
  static const List<String> allowedFileExtensions = [
    'pdf', 'doc', 'docx', 'txt', 'md', 'json', 'yaml', 'yml',
    'jpg', 'jpeg', 'png', 'gif', 'svg', 'webp'
  ];
  static const List<String> documentExtensions = [
    'pdf', 'doc', 'docx', 'txt', 'md', 'json', 'yaml', 'yml'
  ];
  static const List<String> imageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'svg', 'webp'
  ];
  
  // Legacy File Types (for backward compatibility)
  static const List<String> supportedImageTypes = imageExtensions;
  static const List<String> supportedDocumentTypes = documentExtensions;
  static const List<String> supportedCodeTypes = ['js', 'ts', 'dart', 'py', 'java', 'cpp', 'c'];
  
  // UI Constraints
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 10.0; // 0.625rem из референса
  static const double largeBorderRadius = 12.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Legacy Animation Durations (for backward compatibility)
  static const Duration defaultAnimationDuration = mediumAnimation;
  static const Duration fastAnimationDuration = shortAnimation;
  static const Duration slowAnimationDuration = longAnimation;
  
  // Debounce Times
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration autoSaveDebounce = Duration(milliseconds: 1000);
  static const Duration navigationDebounce = Duration(milliseconds: 100);
  
  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // Maximum number of cached items
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation Rules
  static const int minProjectNameLength = 1;
  static const int maxProjectNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxCommentLength = 500;
  
  // Navigation
  static const String initialRoute = '/';
  static const String homeRoute = '/home';
  static const String projectsRoute = '/projects';
  static const String settingsRoute = '/settings';
  static const String workspaceRoute = '/workspace';
  static const String aiAssistantRoute = '/ai-assistant';
  static const String templatesRoute = '/templates';
  static const String fileExplorerRoute = '/file-explorer';
  
  // Theme Configuration
  static const String defaultTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
  
  // Color Scheme (Современная приглушенная палитра)
  static const int primaryColorValue = 0xFF8B1538; // Burgundy - мягкий гранатовый
  static const int secondaryColorValue = 0xFF6B7280; // Нейтральный серый для вторичных кнопок
  static const int accentColorValue = 0xFFB22746; // Deep red для акцентов
  static const int backgroundColorValue = 0xFFFFFFFF; // Белый фон
  static const int surfaceColorValue = 0xFFF8F9FA; // Поверхность
  static const int errorColorValue = 0xFFDC3545; // Красный для ошибок
  static const int successColorValue = 0xFF10B981; // Зеленый для успеха
  static const int warningColorValue = 0xFFF59E0B; // Оранжевый для предупреждений

  
  // Language Configuration
  static const String defaultLanguage = 'ru';
  static const String englishLanguage = 'en';
  static const String russianLanguage = 'ru';
  static const List<String> supportedLanguages = [
    englishLanguage,
    russianLanguage,
  ];
  
  // Asset Paths
  static const String logoPath = 'assets/images/novaspec-logo.svg';
  static const String atlassianIconPath = 'assets/images/atlassian-icon.svg';
  
  // Logging Configuration
  static const bool enableDebugLogging = true;
  static const bool enableInfoLogging = true;
  static const bool enableWarningLogging = true;
  static const bool enableErrorLogging = true;
  static const int maxLogFileSize = 1024 * 1024; // 1MB
  static const int maxLogFiles = 5;
  
  // Performance Monitoring
  static const bool enablePerformanceMonitoring = true;
  static const Duration performanceReportInterval = Duration(minutes: 5);
  
  // Error Reporting
  static const bool enableErrorReporting = false; // Disabled in development
  static const int maxErrorReports = 50;
  
  // Feature Flags
  static const bool enableAiAssistant = true;
  static const bool enableFileExplorer = true;
  static const bool enableTemplates = true;
  static const bool enableWorkspace = true;
  static const bool enableProjectManagement = true;
  static const bool enableSettings = true;
  static const bool enableOnboarding = true;
  
  // Development Settings
  static const bool enableDebugMenu = true;
  static const bool enableMockData = false;
  static const bool enableNetworkLogging = true;
  
  // Security Settings
  static const bool requireAuthentication = false; // For future implementation
  static const Duration sessionTimeout = Duration(hours: 8);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  
  // Backup and Sync
  static const bool enableAutoBackup = true;
  static const Duration backupInterval = Duration(hours: 6);
  static const int maxBackupFiles = 10;
  
  // Notification Settings
  static const bool enableNotifications = true;
  static const bool enableEmailNotifications = false;
  static const bool enablePushNotifications = false;
  
  // AI Assistant Settings
  static const int maxAiResponseLength = 2000;
  static const Duration aiRequestTimeout = Duration(seconds: 30);
  static const int maxAiRetries = 2;
  
  // File Explorer Settings
  static const bool showHiddenFiles = false;
  static const int maxRecentFiles = 20;
  static const bool enableFilePreview = true;
  
  // Template Settings
  static const int maxCustomTemplates = 50;
  static const bool enableTemplateSharing = false;
  
  // Workspace Settings
  static const int maxWorkspaceSize = 1024 * 1024 * 1024; // 1GB
  static const int maxCollaborators = 10;
  
  // Project Management Settings
  static const int maxProjectsPerUser = 100;
  static const int maxTasksPerProject = 1000;
  static const bool enableProjectSharing = true;
  
  // Onboarding Settings
  static const bool showOnboardingOnFirstLaunch = true;
  static const bool enableOnboardingSkip = true;
  static const int maxOnboardingSteps = 10;
  
  // Settings Categories
  static const List<String> settingsCategories = [
    'general',
    'appearance',
    'language',
    'notifications',
    'privacy',
    'storage',
    'ai_assistant',
    'advanced',
  ];
  
  // Default Values
  static const Map<String, dynamic> defaultAppConfiguration = {
    'language': defaultLanguage,
    'theme': defaultTheme,
    'autoSave': true,
    'notificationsEnabled': true,
    'lastOpenedProject': null,
  };
  
  static const Map<String, dynamic> defaultNavigationState = {
    'currentRoute': initialRoute,
    'history': [initialRoute],
    'parameters': <String, dynamic>{},
  };
  
  // Route Configuration
  static const Map<String, String> routeTitles = {
    initialRoute: 'Главная',
    homeRoute: 'Домашняя страница',
    projectsRoute: 'Проекты',
    settingsRoute: 'Настройки',
    workspaceRoute: 'Рабочее пространство',
    aiAssistantRoute: 'AI Ассистент',
    templatesRoute: 'Шаблоны',
    fileExplorerRoute: 'Проводник',
  };
  
  // Regular Expressions
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phoneRegex = r'^\+?[\d\s\-\(\)]+$';
  
  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'Ошибка сети. Проверьте подключение к интернету.',
    'file_not_found': 'Файл не найден.',
    'permission_denied': 'Доступ запрещен.',
    'invalid_input': 'Неверные входные данные.',
    'server_error': 'Ошибка сервера. Попробуйте позже.',
    'timeout_error': 'Время ожидания истекло.',
    'unknown_error': 'Произошла неизвестная ошибка.',
  };
  
  // Legacy Error Messages (for backward compatibility)
  static const String networkErrorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
  static const String serverErrorMessage = 'Ошибка сервера. Попробуйте позже.';
  static const String unknownErrorMessage = 'Произошла неизвестная ошибка.';
  
  // Success Messages
  static const Map<String, String> successMessages = {
    'file_saved': 'Файл успешно сохранен.',
    'project_created': 'Проект успешно создан.',
    'settings_saved': 'Настройки успешно сохранены.',
    'data_synced': 'Данные успешно синхронизированы.',
  };
  
  // Validation Messages
  static const Map<String, String> validationMessages = {
    'required_field': 'Это поле обязательно для заполнения.',
    'invalid_email': 'Введите корректный email адрес.',
    'min_length': 'Минимальная длина: {min} символов.',
    'max_length': 'Максимальная длина: {max} символов.',
    'invalid_format': 'Неверный формат данных.',
  };
  
  // URL и эндпоинты
  static const String githubApiUrl = 'https://api.github.com';
  static const String openAiApiUrl = 'https://api.openai.com/v1';
  
  // Legacy API Settings (for backward compatibility)
  static const int maxRetryAttempts = apiMaxRetries;
}
