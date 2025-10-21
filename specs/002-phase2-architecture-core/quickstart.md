# Quick Start Guide: Фаза 2 - Базовая архитектура и ядро

**Created**: 2025-10-19  
**Purpose**: Быстрый старт для разработки базовой архитектуры NovaSpec Flutter приложения

## Предварительные требования

### Инструменты разработки
- Flutter SDK 3.x
- Dart 3.x
- VS Code или Android Studio с Flutter плагинами
- Git

### Зависимости проекта
Добавить в `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management & DI
  provider: ^6.1.1
  get_it: ^7.6.4
  
  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # HTTP & Networking
  dio: ^5.3.2
  
  # File Operations
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  
  # UI Components
  flutter_svg: ^2.0.9
  
  # WebView
  webview_flutter: ^4.4.2
  
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1
  
  # Utilities
  equatable: ^2.0.5
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

## Структура проекта

### 1. Создание базовой структуры

```
lib/
├── main.dart                    # Точка входа
├── app/
│   ├── app.dart                 # Главный виджет приложения
│   ├── routes/
│   │   └── app_routes.dart      # Маршруты приложения
│   └── themes/
│       └── app_theme.dart       # Темы оформления
├── core/
│   ├── constants/
│   │   └── app_constants.dart   # Константы приложения
│   ├── providers/
│   │   ├── app_provider.dart    # Главный провайдер
│   │   ├── config_provider.dart # Провайдер конфигурации
│   │   └── navigation_provider.dart # Провайдер навигации
│   ├── services/
│   │   ├── api_service.dart     # HTTP сервис
│   │   ├── storage_service.dart # Сервис хранения
│   │   ├── config_service.dart  # Сервис конфигурации
│   │   └── file_service.dart    # Файловый сервис
│   └── utils/
│       └── helpers.dart         # Вспомогательные функции
├── shared/
│   ├── models/
│   │   ├── app_config.dart      # Модель конфигурации
│   │   ├── navigation_state.dart # Модель навигации
│   │   └── ui_state.dart        # Модель состояния UI
│   └── widgets/
│       ├── custom_button.dart   # Кастомная кнопка
│       ├── custom_text_field.dart # Кастомное поле ввода
│       └── custom_dialog.dart   # Кастомный диалог
└── l10n/
    ├── app_localizations.dart   # Локализация
    ├── app_localizations_ru.dart # Русская локализация
    ├── app_localizations_en.dart # Английская локализация
    ├── app_localizations.arb    # Файл ресурсов
    └── app_localizations_ru.arb # Русские ресурсы
```

### 2. Настройка Dependency Injection

Создать `lib/core/di/service_locator.dart`:

```dart
import 'package:get_it/get_it.dart';
import '../services/storage_service.dart';
import '../services/config_service.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<ConfigService>(() => ConfigService());
  sl.registerLazySingleton<ApiService>(() => ApiService());
  sl.registerLazySingleton<FileService>(() => FileService());
}
```

### 3. Настройка провайдеров

Создать `lib/core/providers/app_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/config_service.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final ConfigService _configService;
  final StorageService _storageService;
  
  bool _isLoading = false;
  String? _error;
  
  AppProvider(this._configService, this._storageService);
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> initializeApp() async {
    _setLoading(true);
    try {
      await _configService.loadConfiguration();
      await _storageService.initialize();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
```

### 4. Создание базовых моделей

Создать `lib/shared/models/app_config.dart`:

```dart
import 'package:equatable/equatable.dart';

class AppConfiguration extends Equatable {
  final String language;
  final String theme;
  final bool autoSave;
  final bool notificationsEnabled;
  final String? lastOpenedProject;
  
  const AppConfiguration({
    required this.language,
    required this.theme,
    required this.autoSave,
    required this.notificationsEnabled,
    this.lastOpenedProject,
  });
  
  AppConfiguration copyWith({
    String? language,
    String? theme,
    bool? autoSave,
    bool? notificationsEnabled,
    String? lastOpenedProject,
  }) {
    return AppConfiguration(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      autoSave: autoSave ?? this.autoSave,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastOpenedProject: lastOpenedProject ?? this.lastOpenedProject,
    );
  }
  
  @override
  List<Object?> get props => [
    language,
    theme,
    autoSave,
    notificationsEnabled,
    lastOpenedProject,
  ];
}
```

### 5. Настройка сервисов

Создать `lib/core/services/config_service.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/app_config.dart';

class ConfigService {
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';
  static const String _autoSaveKey = 'auto_save';
  static const String _notificationsKey = 'notifications';
  static const String _lastProjectKey = 'last_project';
  
  AppConfiguration? _configuration;
  
  AppConfiguration get configuration => _configuration ?? 
      const AppConfiguration(
        language: 'ru',
        theme: 'system',
        autoSave: true,
        notificationsEnabled: true,
      );
  
  Future<void> loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    
    _configuration = AppConfiguration(
      language: prefs.getString(_languageKey) ?? 'ru',
      theme: prefs.getString(_themeKey) ?? 'system',
      autoSave: prefs.getBool(_autoSaveKey) ?? true,
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      lastOpenedProject: prefs.getString(_lastProjectKey),
    );
  }
  
  Future<void> saveConfiguration(AppConfiguration config) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_languageKey, config.language);
    await prefs.setString(_themeKey, config.theme);
    await prefs.setBool(_autoSaveKey, config.autoSave);
    await prefs.setBool(_notificationsKey, config.notificationsEnabled);
    
    if (config.lastOpenedProject != null) {
      await prefs.setString(_lastProjectKey, config.lastOpenedProject!);
    }
    
    _configuration = config;
  }
}
```

### 6. Создание базовых UI компонентов

Создать `lib/shared/widgets/custom_button.dart`:

```dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    );
  }
}
```

### 7. Настройка локализации

Создать `lib/l10n/app_localizations.dart`:

```dart
import 'package:flutter/material.dart';

class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];
  
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // Texts
  String get appName => 'NovaSpec';
  String get settings => 'Настройки';
  String get language => 'Язык';
  String get theme => 'Тема';
  String get save => 'Сохранить';
  String get cancel => 'Отмена';
  String get error => 'Ошибка';
  String get loading => 'Загрузка...';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['ru', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations();
  }
  
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
```

### 8. Настройка главного приложения

Обновить `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/di/service_locator.dart';
import 'core/providers/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await setupServiceLocator();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(
        sl<ConfigService>(),
        sl<StorageService>(),
      ),
      child: const NovaSpecApp(),
    ),
  );
}
```

### 9. Создание главного виджета

Создать `lib/app/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/providers/app_provider.dart';
import 'themes/app_theme.dart';

class NovaSpecApp extends StatelessWidget {
  const NovaSpecApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return MaterialApp(
          title: 'NovaSpec',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Center(
              child: Text('NovaSpec - Фаза 2'),
            ),
          ),
        );
      },
    );
  }
}
```

## Запуск приложения

1. Установить зависимости:
   ```bash
   flutter pub get
   ```

2. Запустить кодогенерацию (если используется):
   ```bash
   flutter packages pub run build_runner build
   ```

3. Запустить приложение:
   ```bash
   flutter run
   ```

## Проверка функциональности

### Базовая проверка
- [ ] Приложение запускается без ошибок
- [ ] Отображается базовый интерфейс
- [ ] Провайдеры инициализируются корректно
- [ ] Конфигурация загружается из хранилища

### Проверка навигации
- [ ] Переходы между экранами работают
- [ ] История навигации сохраняется
- [ ] Параметры маршрутов передаются корректно

### Проверка конфигурации
- [ ] Настройки сохраняются между запусками
- [ ] Смена языка применяется немедленно
- [ ] Тема переключается корректно

### Проверка UI компонентов
- [ ] Кнопки реагируют на нажатия
- [ ] Поля ввода работают корректно
- [ ] Диалоги открываются и закрываются

## Следующие шаги

1. Реализовать навигационную структуру согласно спецификации
2. Адаптировать цветовую схему из TypeScript референса
3. Добавить обработку ошибок согласно граничным случаям
4. Реализовать сохранение и восстановление состояния
5. Подготовить основу для следующих фаз разработки

## Полезные ресурсы

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [GetIt Package](https://pub.dev/packages/get_it)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Flutter Localization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)