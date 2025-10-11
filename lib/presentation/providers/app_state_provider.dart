import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';

/// Провайдер для управления глобальным состоянием приложения
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// Глобальное состояние приложения
class AppState {
  final ThemeMode themeMode;
  final String language;
  final bool isInitialized;
  final String? error;

  const AppState({
    this.themeMode = ThemeMode.system,
    this.language = 'ru',
    this.isInitialized = false,
    this.error,
  });

  AppState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? isInitialized,
    String? error,
    bool clearError = false,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Проверка, используется ли темная тема
  bool isDarkMode(BuildContext context) {
    switch (themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}

/// Notifier для управления глобальным состоянием
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _initialize();
  }

  final _repository = ConfigRepository(HiveDataSource());

  /// Инициализация приложения
  Future<void> _initialize() async {
    try {
      // Загружаем настройки из Hive
      final config = await _repository.getConfig();

      if (config != null) {
        state = state.copyWith(
          language: config.language,
          isInitialized: true,
        );
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } catch (e) {
      state = state.copyWith(
        isInitialized: true,
        error: 'Ошибка инициализации: $e',
      );
    }
  }

  /// Переключить тему
  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    state = state.copyWith(themeMode: newMode);
  }

  /// Установить конкретную тему
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  /// Установить светлую тему
  void setLightTheme() {
    state = state.copyWith(themeMode: ThemeMode.light);
  }

  /// Установить темную тему
  void setDarkTheme() {
    state = state.copyWith(themeMode: ThemeMode.dark);
  }

  /// Установить системную тему
  void setSystemTheme() {
    state = state.copyWith(themeMode: ThemeMode.system);
  }

  /// Изменить язык приложения
  Future<void> setLanguage(String language) async {
    try {
      // Сохраняем в конфиг
      await _repository.updateLanguage(language);

      state = state.copyWith(language: language);
    } catch (e) {
      state = state.copyWith(error: 'Ошибка смены языка: $e');
    }
  }

  /// Очистить ошибку
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Перезагрузить состояние из конфига
  Future<void> reload() async {
    await _initialize();
  }
}
