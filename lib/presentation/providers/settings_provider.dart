import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/data/models/app_config.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';

/// Провайдер для работы с настройками приложения
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

/// Состояние настроек
class SettingsState {
  final AppConfig? config;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const SettingsState({
    this.config,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  SettingsState copyWith({
    AppConfig? config,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Notifier для управления настройками
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    loadSettings();
  }

  final _repository = ConfigRepository(HiveDataSource());

  /// Загрузить настройки из Hive
  Future<void> loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final config = await _repository.getConfig();

      state = state.copyWith(
        config: config,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки настроек: $e',
      );
    }
  }

  /// Сохранить настройки
  Future<bool> saveSettings(AppConfig config) async {
    try {
      state = state.copyWith(
        isSaving: true,
        clearError: true,
        clearSuccess: true,
      );

      await _repository.updateConfig(config);

      state = state.copyWith(
        config: config,
        isSaving: false,
        successMessage: 'Настройки сохранены',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Ошибка сохранения настроек: $e',
      );
      return false;
    }
  }

  /// Обновить настройки AI провайдера
  Future<bool> updateAIProvider({
    required String provider,
    String? baseUrl,
    String? token,
    String? model,
  }) async {
    try {
      state = state.copyWith(isSaving: true, clearError: true);

      await _repository.updateAIProvider(
        provider: provider,
        baseUrl: baseUrl,
        token: token,
        model: model,
      );

      // Перезагружаем настройки
      await loadSettings();

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Настройки AI провайдера обновлены',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Ошибка обновления AI провайдера: $e',
      );
      return false;
    }
  }

  /// Обновить настройки Confluence
  Future<bool> updateConfluenceSettings({
    required bool enabled,
    String? baseUrl,
    String? email,
    String? token,
    String? instanceType,
    String? space,
    String? parentPageId,
  }) async {
    try {
      state = state.copyWith(isSaving: true, clearError: true);

      await _repository.updateConfluenceSettings(
        enabled: enabled,
        baseUrl: baseUrl,
        email: email,
        token: token,
        instanceType: instanceType,
        space: space,
        parentPageId: parentPageId,
      );

      // Перезагружаем настройки
      await loadSettings();

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Настройки Confluence обновлены',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Ошибка обновления Confluence: $e',
      );
      return false;
    }
  }

  /// Обновить настройки музикации
  Future<bool> updateMusicSettings({
    required bool enabled,
    String? token,
    String? genre,
    int? balance,
  }) async {
    try {
      state = state.copyWith(isSaving: true, clearError: true);

      await _repository.updateMusicSettings(
        enabled: enabled,
        token: token,
        genre: genre,
        balance: balance,
      );

      // Перезагружаем настройки
      await loadSettings();

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Настройки музикации обновлены',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Ошибка обновления музикации: $e',
      );
      return false;
    }
  }

  /// Обновить язык приложения
  Future<bool> updateLanguage(String language) async {
    try {
      state = state.copyWith(isSaving: true, clearError: true);

      await _repository.updateLanguage(language);

      // Перезагружаем настройки
      await loadSettings();

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Язык обновлен',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Ошибка обновления языка: $e',
      );
      return false;
    }
  }

  /// Проверить, настроен ли AI провайдер
  bool get isAIConfigured {
    return state.config?.aiProvider != null &&
        state.config!.aiProvider!.isNotEmpty &&
        state.config!.aiProviderToken != null &&
        state.config!.aiProviderToken!.isNotEmpty;
  }

  /// Проверить, настроен ли Confluence
  bool get isConfluenceConfigured {
    return state.config?.confluenceEnabled == true &&
        state.config!.confluenceBaseUrl != null &&
        state.config!.confluenceBaseUrl!.isNotEmpty;
  }

  /// Проверить, настроена ли музикация
  bool get isMusicConfigured {
    return state.config?.musicEnabled == true &&
        state.config!.musicToken != null &&
        state.config!.musicToken!.isNotEmpty;
  }

  /// Очистить сообщения об ошибках и успехе
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Очистить только ошибку
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Очистить только сообщение об успехе
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }
}
