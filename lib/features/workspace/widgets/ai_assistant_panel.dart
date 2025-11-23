import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/panel_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/ai_validation_service.dart';
import '../../../../shared/services/di_container.dart';

class AiAssistantPanel extends StatelessWidget {
  const AiAssistantPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PanelProvider>(
      builder: (context, panelProvider, child) {
        if (panelProvider.isAiAssistantCollapsed) {
          return Container(
            width: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 16),
                      onPressed: () => panelProvider.toggleAiAssistant(),
                      tooltip: 'Развернуть AI ассистента',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // AI Assistant content
              Expanded(
                child: _buildAiAssistantContent(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.smart_toy, size: 16),
          const SizedBox(width: 8),
          const Text(
            'AI Ассистент',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 16),
            onPressed: () => context.read<PanelProvider>().toggleAiAssistant(),
            tooltip: 'Свернуть AI ассистента',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantContent(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'AI Ассистент',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Задайте вопрос об вашем проекте',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Выбор модели
              const Text(
                'AI Модель:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              _ModelSelector(settingsProvider: settingsProvider),
            ],
          ),
        );
      },
    );
  }
}

class _ModelSelector extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const _ModelSelector({
    required this.settingsProvider,
  });

  @override
  State<_ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<_ModelSelector> {
  bool _isLoading = false;
  List<String> _models = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    // Если модель уже выбрана, загружаем модели для текущего провайдера
    if (widget.settingsProvider.selectedAiModel.isNotEmpty) {
      _loadModels();
    }
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final aiValidationService = getIt<AIValidationService>();
      final provider = widget.settingsProvider.selectedProvider;
      final apiKey = _getApiKeyForProvider(provider);
      
      if (apiKey.isEmpty) {
        setState(() {
          _error = 'API ключ не настроен';
          _isLoading = false;
        });
        return;
      }

      final baseUrl = _getBaseUrlForProvider(provider);
      final models = await aiValidationService.getModels(provider, apiKey, baseUrl: baseUrl);

      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getApiKeyForProvider(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return widget.settingsProvider.openaiToken;
      case AIProvider.anthropic:
        return widget.settingsProvider.anthropicToken;
      case AIProvider.cerebras:
        return widget.settingsProvider.cerebrasToken;
      case AIProvider.groq:
        return widget.settingsProvider.groqToken;
      case AIProvider.openrouter:
        return widget.settingsProvider.openRouterToken;
      case AIProvider.openaiCompetitive:
        return widget.settingsProvider.openaiCompetitiveToken;
      case AIProvider.lmStudio:
        return widget.settingsProvider.lmStudioToken;
      case AIProvider.ollama:
        return widget.settingsProvider.ollamaToken;
      case AIProvider.zai:
        return widget.settingsProvider.zaiToken;
    }
  }

  String? _getBaseUrlForProvider(AIProvider provider) {
    switch (provider) {
      case AIProvider.lmStudio:
        return widget.settingsProvider.lmStudioBaseUrl;
      case AIProvider.ollama:
        return widget.settingsProvider.ollamaBaseUrl;
      case AIProvider.zai:
        return widget.settingsProvider.zaiBaseUrl;
      case AIProvider.openaiCompetitive:
        return widget.settingsProvider.openaiCompetitiveBaseUrl;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedModel = widget.settingsProvider.selectedAiModel;
    final displayText = selectedModel.isEmpty ? 'Выбрать модель' : selectedModel;

    return GestureDetector(
      onTap: () async {
        if (_models.isEmpty && !_isLoading) {
          await _loadModels();
        }
        if (mounted) {
          _showModelSelector(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedModel.isEmpty 
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }

  void _showModelSelector(BuildContext context) {
    if (!mounted) return;
    
    if (_models.isEmpty && !_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала загрузите модели')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выберите AI модель'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ошибка: $_error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              _loadModels();
                            },
                            child: const Text('Повторить'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _models.length,
                      itemBuilder: (context, index) {
                        final model = _models[index];
                        final isSelected = model == widget.settingsProvider.selectedAiModel;
                        
                        return ListTile(
                          title: Text(model),
                          subtitle: model.length > 30 ? Text('${model.substring(0, 30)}...') : null,
                          trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () {
                            widget.settingsProvider.setSelectedAiModel(model);
                            Navigator.of(dialogContext).pop();
                          },
                        );
                      },
                    ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          if (_error != null)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _loadModels();
              },
              child: const Text('Обновить'),
            ),
        ],
      ),
    );
  }
}
