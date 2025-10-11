import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/data/models/chat_history.dart';
import 'package:novaspec/data/models/chat_message.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:uuid/uuid.dart';

/// Провайдер для работы с AI-ассистентом
final aiAssistantProvider =
    StateNotifierProvider<AIAssistantNotifier, AIAssistantState>((ref) {
  return AIAssistantNotifier();
});

/// Режимы работы AI-ассистента
enum AIMode {
  chat, // Обычный диалог
  review, // Ревью кода/документов
  generate, // Генерация по шаблону
}

/// Состояние AI-ассистента
class AIAssistantState {
  final ChatHistory? currentChat;
  final List<ChatHistory> chatHistories;
  final AIMode mode;
  final bool isLoading;
  final bool isStreaming;
  final String? error;
  final String? selectedModel;

  const AIAssistantState({
    this.currentChat,
    this.chatHistories = const [],
    this.mode = AIMode.chat,
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
    this.selectedModel,
  });

  AIAssistantState copyWith({
    ChatHistory? currentChat,
    List<ChatHistory>? chatHistories,
    AIMode? mode,
    bool? isLoading,
    bool? isStreaming,
    String? error,
    String? selectedModel,
    bool clearError = false,
    bool clearCurrentChat = false,
  }) {
    return AIAssistantState(
      currentChat: clearCurrentChat ? null : (currentChat ?? this.currentChat),
      chatHistories: chatHistories ?? this.chatHistories,
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : (error ?? this.error),
      selectedModel: selectedModel ?? this.selectedModel,
    );
  }
}

/// Notifier для управления AI-ассистентом
class AIAssistantNotifier extends StateNotifier<AIAssistantState> {
  AIAssistantNotifier() : super(const AIAssistantState()) {
    _loadChatHistories();
    _loadSelectedModel();
  }

  final _repository = ConfigRepository(HiveDataSource());
  final _uuid = const Uuid();

  /// Загрузка истории чатов
  Future<void> _loadChatHistories() async {
    try {
      final config = await _repository.getConfig();
      if (config != null) {
        state = state.copyWith(chatHistories: config.chatHistories);
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка загрузки истории чатов: $e');
    }
  }

  /// Загрузка выбранной модели
  Future<void> _loadSelectedModel() async {
    try {
      final config = await _repository.getConfig();
      if (config?.aiSelectedModel != null) {
        state = state.copyWith(selectedModel: config!.aiSelectedModel);
      }
    } catch (e) {
      // Ignore error
    }
  }

  /// Создать новый чат
  Future<void> createNewChat({String? title}) async {
    try {
      // Сохранить текущий чат перед созданием нового
      if (state.currentChat != null &&
          state.currentChat!.messages.isNotEmpty) {
        await _saveCurrentChat();
      }

      final newChat = ChatHistory(
        id: _uuid.v4(),
        title: title ?? 'Новый чат',
        messages: [],
        createdAt: DateTime.now(),
      );

      state = state.copyWith(currentChat: newChat);
    } catch (e) {
      state = state.copyWith(error: 'Ошибка создания чата: $e');
    }
  }

  /// Сохранить текущий чат в историю
  Future<void> _saveCurrentChat() async {
    if (state.currentChat == null) return;

    try {
      final config = await _repository.getConfig();
      if (config != null) {
        // Проверяем, существует ли уже этот чат
        final existingIndex =
            config.chatHistories.indexWhere((c) => c.id == state.currentChat!.id);

        if (existingIndex != -1) {
          // Обновляем существующий
          config.chatHistories[existingIndex] = state.currentChat!;
        } else {
          // Добавляем новый
          config.chatHistories.add(state.currentChat!);
        }

        await _repository.updateConfig(config);
        state = state.copyWith(chatHistories: config.chatHistories);
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка сохранения чата: $e');
    }
  }

  /// Загрузить чат из истории
  Future<void> loadChat(String chatId) async {
    try {
      // Сохранить текущий чат перед загрузкой нового
      if (state.currentChat != null &&
          state.currentChat!.messages.isNotEmpty) {
        await _saveCurrentChat();
      }

      final chat = state.chatHistories.firstWhere((c) => c.id == chatId);
      state = state.copyWith(currentChat: chat);
    } catch (e) {
      state = state.copyWith(error: 'Ошибка загрузки чата: $e');
    }
  }

  /// Удалить чат из истории
  Future<void> deleteChat(String chatId) async {
    try {
      final config = await _repository.getConfig();
      if (config != null) {
        config.chatHistories.removeWhere((c) => c.id == chatId);
        await _repository.updateConfig(config);
        state = state.copyWith(chatHistories: config.chatHistories);

        // Если удаляем текущий чат, очищаем его
        if (state.currentChat?.id == chatId) {
          state = state.copyWith(clearCurrentChat: true);
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка удаления чата: $e');
    }
  }

  /// Добавить сообщение пользователя
  Future<void> addUserMessage(String content) async {
    try {
      // Создаем новый чат если его нет
      if (state.currentChat == null) {
        await createNewChat();
      }

      final message = ChatMessage(
        role: 'user',
        content: content,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...state.currentChat!.messages, message];
      final updatedChat = ChatHistory(
        id: state.currentChat!.id,
        title: state.currentChat!.title,
        messages: updatedMessages,
        createdAt: state.currentChat!.createdAt,
      );

      state = state.copyWith(currentChat: updatedChat);

      // Автосохранение после добавления сообщения
      await _saveCurrentChat();
    } catch (e) {
      state = state.copyWith(error: 'Ошибка добавления сообщения: $e');
    }
  }

  /// Добавить сообщение от AI
  Future<void> addAIMessage(String content) async {
    try {
      if (state.currentChat == null) return;

      final message = ChatMessage(
        role: 'assistant',
        content: content,
        timestamp: DateTime.now(),
      );

      final updatedMessages = [...state.currentChat!.messages, message];
      final updatedChat = ChatHistory(
        id: state.currentChat!.id,
        title: state.currentChat!.title,
        messages: updatedMessages,
        createdAt: state.currentChat!.createdAt,
      );

      state = state.copyWith(currentChat: updatedChat);

      // Автосохранение после добавления сообщения
      await _saveCurrentChat();
    } catch (e) {
      state = state.copyWith(error: 'Ошибка добавления ответа AI: $e');
    }
  }

  /// Отправить сообщение AI (заглушка, будет реализовано позже)
  Future<void> sendMessage(String content) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Добавляем сообщение пользователя
      await addUserMessage(content);

      // TODO: Здесь будет вызов AI API через AIRepository
      // Пока используем заглушку
      await Future.delayed(const Duration(seconds: 1));

      // Заглушка ответа
      await addAIMessage(
        'Это заглушка ответа AI. Реальная интеграция будет добавлена позже.',
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка отправки сообщения: $e',
      );
    }
  }

  /// Изменить режим работы
  void setMode(AIMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Выбрать модель
  Future<void> selectModel(String model) async {
    try {
      state = state.copyWith(selectedModel: model);

      // Сохраняем в конфиг
      final config = await _repository.getConfig();
      if (config != null) {
        config.aiSelectedModel = model;
        await _repository.updateConfig(config);
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка выбора модели: $e');
    }
  }

  /// Очистить ошибку
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Обновить заголовок текущего чата
  Future<void> updateChatTitle(String title) async {
    if (state.currentChat == null) return;

    try {
      final updatedChat = ChatHistory(
        id: state.currentChat!.id,
        title: title,
        messages: state.currentChat!.messages,
        createdAt: state.currentChat!.createdAt,
      );

      state = state.copyWith(currentChat: updatedChat);
      await _saveCurrentChat();
    } catch (e) {
      state = state.copyWith(error: 'Ошибка обновления заголовка: $e');
    }
  }
}
