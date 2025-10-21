import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/widgets/modern_button.dart';
import '../widgets/ai_providers_tab.dart';
import '../widgets/integrations_tab.dart';
import '../widgets/general_tab.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize settings provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false).initialize();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    ModernButton(
                      text: 'Сбросить',
                      onPressed: () => _showResetDialog(context),
                      type: ButtonType.tertiary,
                    ),
                    const SizedBox(width: 8),
                    ModernButton(
                      text: 'Сохранить',
                      onPressed: settings.isLoading ? null : () => _saveSettings(context),
                      type: ButtonType.primary,
                      isLoading: settings.isLoading,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.psychology),
              text: 'AI Провайдеры',
            ),
            Tab(
              icon: Icon(Icons.integration_instructions),
              text: 'Интеграции',
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: 'Общие',
            ),
          ],
          labelColor: const Color(0xFFB91C1C),
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: const Color(0xFFB91C1C),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (settings.errorMessage != null) {
            return _buildErrorView(settings);
          }
          
          if (settings.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: const [
              AIProvidersTab(),
              IntegrationsTab(),
              GeneralTab(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildErrorView(SettingsProvider settings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки настроек',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              settings.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ModernButton(
              text: 'Повторить',
              onPressed: () {
                settings.clearError();
                settings.initialize();
              },
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveSettings(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.saveSettings();
    
    if (settings.errorMessage == null) {
      success(description: 'Настройки успешно сохранены');
    } else {
      error(description: 'Ошибка сохранения: ${settings.errorMessage}');
    }
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить настройки'),
        content: const Text(
          'Вы уверены, что хотите сбросить все настройки к значениям по умолчанию? '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ModernButton(
            text: 'Сбросить',
            onPressed: () {
              Navigator.of(context).pop();
              _resetSettings(context);
            },
            type: ButtonType.danger,
          ),
        ],
      ),
    );
  }
  
  void _resetSettings(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    // Reset to defaults
    settings.setSelectedAIProvider(AIProvider.openai);
    settings.setOpenaiApiKey('');
    settings.setAnthropicApiKey('');
    settings.setGroqApiKey('');
    settings.setOpenaiBaseUrl('https://api.openai.com/v1');
    settings.setAnthropicBaseUrl('https://api.anthropic.com');
    settings.setGroqBaseUrl('https://api.groq.com/openai/v1');
    settings.setTemperature(0.7);
    settings.setMaxTokens(2048);
    settings.setTimeoutSeconds(30);
    
    settings.setConfluenceUrl('');
    settings.setConfluenceAuthMethod(ConfluenceAuthMethod.apiToken);
    settings.setConfluenceUsername('');
    settings.setConfluenceApiToken('');
    settings.setDefaultSpace('');
    
    settings.setMusicProvider('');
    settings.setMusicApiKey('');
    settings.setAudioFormat('mp3');
    settings.setAudioQuality('standard');
    
    settings.setLanguage('ru');
    settings.setTheme('system');
    settings.setAutoSaveInterval(300);
    settings.setDefaultProjectLocation('');
    
    settings.setFontSize(14.0);
    settings.setTabSize(2);
    settings.setWordWrap(true);
    settings.setAutoCompletion(true);
    
    await settings.saveSettings();
    
    warning(description: 'Настройки сброшены к значениям по умолчанию');
  }
}