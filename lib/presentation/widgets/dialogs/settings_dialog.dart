import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/widgets/buttons/ns_button.dart';
import 'package:novaspec/presentation/widgets/inputs/ns_text_field.dart';
import 'package:novaspec/presentation/widgets/inputs/ns_select.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';

/// Список доступных AI провайдеров
const aiProviders = [
  {'value': 'anthropic', 'label': 'Anthropic (Claude)'},
  {'value': 'openai', 'label': 'OpenAI (ChatGPT)'},
  {'value': 'groq', 'label': 'Groq'},
  {'value': 'cerebras', 'label': 'Cerebras'},
  {'value': 'openrouter', 'label': 'OpenRouter'},
  {'value': 'together', 'label': 'Together AI'},
  {'value': 'lmstudio', 'label': 'LM Studio (Local)'},
  {'value': 'ollama', 'label': 'Ollama (Local)'},
];

/// Диалог настроек приложения
class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repository = ConfigRepository(HiveDataSource());

  // AI Provider fields
  String _selectedProvider = 'anthropic';
  final _aiBaseUrlController = TextEditingController();
  final _aiTokenController = TextEditingController();
  final _aiModelController = TextEditingController();

  // Confluence fields
  bool _confluenceEnabled = false;
  final _confluenceUrlController = TextEditingController();
  final _confluenceUsernameController = TextEditingController();
  final _confluenceTokenController = TextEditingController();
  final _confluenceSpaceController = TextEditingController();
  final _confluenceParentIdController = TextEditingController();

  // Music fields (Gen-API for Suno)
  bool _musicEnabled = false;
  final _musicTokenController = TextEditingController();
  final _musicGenreController = TextEditingController();
  int _musicBalance = 50;

  // Language
  String _selectedLanguage = 'ru';

  // Validation state
  bool _isValidating = false;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aiBaseUrlController.dispose();
    _aiTokenController.dispose();
    _aiModelController.dispose();
    _confluenceUrlController.dispose();
    _confluenceUsernameController.dispose();
    _confluenceTokenController.dispose();
    _confluenceSpaceController.dispose();
    _confluenceParentIdController.dispose();
    _musicTokenController.dispose();
    _musicGenreController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final config = await _repository.getConfig();
    if (config != null && mounted) {
      setState(() {
        // AI Provider
        _selectedProvider = config.aiProvider ?? 'anthropic';
        _aiBaseUrlController.text = config.aiProviderBaseUrl ?? '';
        _aiTokenController.text = config.aiProviderToken ?? '';
        _aiModelController.text = config.aiSelectedModel ?? 'claude-3-5-sonnet-20241022';

        // Confluence
        _confluenceEnabled = config.confluenceEnabled;
        _confluenceUrlController.text = config.confluenceBaseUrl ?? '';
        _confluenceUsernameController.text = config.confluenceEmail ?? '';
        _confluenceTokenController.text = config.confluenceToken ?? '';
        _confluenceSpaceController.text = config.confluenceSpace ?? '';
        _confluenceParentIdController.text = config.confluenceParentPageId ?? '';

        // Music
        _musicEnabled = config.musicEnabled;
        _musicTokenController.text = config.musicToken ?? '';
        _musicGenreController.text = config.musicGenre;

        // Language
        _selectedLanguage = config.language;
      });
    }
  }

  /// Проверить настройки (валидация API ключей)
  Future<void> _validateSettings() async {
    setState(() {
      _isValidating = true;
    });

    // TODO: Реализовать проверку API ключей
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isValidating = false;
      _canSave = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки проверены успешно'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Определить, нужно ли показывать поле Base URL
  bool _needsBaseUrl() {
    return _selectedProvider == 'lmstudio' ||
           _selectedProvider == 'ollama' ||
           _selectedProvider == 'openrouter' ||
           _selectedProvider == 'together';
  }

  /// Определить, нужен ли API токен
  bool _needsApiToken() {
    return _selectedProvider != 'ollama'; // Ollama не требует токен
  }

  Future<void> _saveSettings() async {
    // Save AI Provider
    await _repository.updateAIProvider(
      provider: _selectedProvider,
      baseUrl: _aiBaseUrlController.text.isEmpty ? null : _aiBaseUrlController.text,
      token: _aiTokenController.text.isEmpty ? null : _aiTokenController.text,
      model: _aiModelController.text,
    );

    // Save Confluence
    await _repository.updateConfluenceSettings(
      enabled: _confluenceEnabled,
      baseUrl: _confluenceUrlController.text.isEmpty ? null : _confluenceUrlController.text,
      email: _confluenceUsernameController.text.isEmpty ? null : _confluenceUsernameController.text,
      token: _confluenceTokenController.text.isEmpty ? null : _confluenceTokenController.text,
      space: _confluenceSpaceController.text.isEmpty ? null : _confluenceSpaceController.text,
      parentPageId: _confluenceParentIdController.text.isEmpty ? null : _confluenceParentIdController.text,
    );

    // Save Music
    await _repository.updateMusicSettings(
      enabled: _musicEnabled,
      token: _musicTokenController.text.isEmpty ? null : _musicTokenController.text,
      genre: _musicGenreController.text,
      balance: _musicBalance,
    );

    // Save Language
    await _repository.updateLanguage(_selectedLanguage);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildAITab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('AI Provider Configuration', style: NsTextStyles.h3(context)),
          const SizedBox(height: NsSpacing.lg),

          // Provider Dropdown
          NsSelect(
            label: 'Provider',
            value: _selectedProvider,
            items: aiProviders,
            onChanged: (value) {
              setState(() {
                _selectedProvider = value;
                _canSave = false; // Требуется новая валидация
              });
            },
          ),
          const SizedBox(height: NsSpacing.md),

          // Base URL (показываем только для некоторых провайдеров)
          if (_needsBaseUrl()) ...[
            NsTextField(
              controller: _aiBaseUrlController,
              label: 'Base URL',
              hint: _selectedProvider == 'lmstudio'
                  ? 'http://localhost:1234/v1'
                  : _selectedProvider == 'ollama'
                  ? 'http://localhost:11434'
                  : 'https://...',
            ),
            const SizedBox(height: NsSpacing.md),
          ],

          // API Token (не показываем для Ollama)
          if (_needsApiToken()) ...[
            NsTextField(
              controller: _aiTokenController,
              label: 'API Token',
              hint: 'Enter your API token',
              obscureText: true,
            ),
            const SizedBox(height: NsSpacing.md),
          ],

          // Model
          NsTextField(
            controller: _aiModelController,
            label: 'Model',
            hint: _selectedProvider == 'anthropic'
                ? 'claude-3-5-sonnet-20241022'
                : _selectedProvider == 'openai'
                ? 'gpt-4-turbo'
                : 'model-name',
          ),
        ],
      ),
    );
  }

  Widget _buildConfluenceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Confluence Integration', style: NsTextStyles.h3(context)),
              Switch(
                value: _confluenceEnabled,
                onChanged: (value) {
                  setState(() {
                    _confluenceEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: NsSpacing.lg),
          NsTextField(
            controller: _confluenceUrlController,
            label: 'Base URL',
            hint: 'https://your-domain.atlassian.net',
            enabled: _confluenceEnabled,
          ),
          const SizedBox(height: NsSpacing.md),
          NsTextField(
            controller: _confluenceUsernameController,
            label: 'Username (Email)',
            hint: 'user@example.com',
            enabled: _confluenceEnabled,
          ),
          const SizedBox(height: NsSpacing.md),
          NsTextField(
            controller: _confluenceTokenController,
            label: 'API Token',
            hint: 'Your Confluence API token',
            obscureText: true,
            enabled: _confluenceEnabled,
          ),
          const SizedBox(height: NsSpacing.md),
          NsTextField(
            controller: _confluenceSpaceController,
            label: 'Space Key',
            hint: 'PROJ',
            enabled: _confluenceEnabled,
          ),
          const SizedBox(height: NsSpacing.md),
          NsTextField(
            controller: _confluenceParentIdController,
            label: 'Parent Page ID (optional)',
            hint: '123456',
            enabled: _confluenceEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildMusicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Background Music', style: NsTextStyles.h3(context)),
              Switch(
                value: _musicEnabled,
                onChanged: (value) {
                  setState(() {
                    _musicEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: NsSpacing.lg),
          NsTextField(
            controller: _musicTokenController,
            label: 'Music API Token',
            hint: 'Enter your music service token',
            obscureText: true,
            enabled: _musicEnabled,
          ),
          const SizedBox(height: NsSpacing.md),
          NsTextField(
            controller: _musicGenreController,
            label: 'Genre',
            hint: 'lofi, ambient, classical, etc.',
            enabled: _musicEnabled,
          ),
          const SizedBox(height: NsSpacing.md),
          Text('Balance', style: NsTextStyles.bodyMedium(context)),
          const SizedBox(height: NsSpacing.sm),
          Slider(
            value: _musicBalance.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: _musicBalance.toString(),
            onChanged: _musicEnabled
                ? (value) {
                    setState(() {
                      _musicBalance = value.toInt();
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Язык интерфейса', style: NsTextStyles.h3(context)),
          const SizedBox(height: NsSpacing.lg),

          NsSelect(
            label: 'Язык',
            value: _selectedLanguage,
            items: const [
              {'value': 'ru', 'label': 'Русский'},
              {'value': 'en', 'label': 'English'},
            ],
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value;
              });
            },
          ),
          const SizedBox(height: NsSpacing.md),

          Text(
            'Изменение языка вступит в силу после перезапуска приложения',
            style: NsTextStyles.bodySmall(context).copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? NsColorsDark.mutedForeground
                  : NsColorsLight.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? NsColorsDark.panel : NsColorsLight.panel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(NsSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? NsColorsDark.border : NsColorsLight.border,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Настройки', style: NsTextStyles.h2(context)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'AI Provider'),
                Tab(text: 'Confluence'),
                Tab(text: 'Музыка'),
                Tab(text: 'Язык'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAITab(),
                  _buildConfluenceTab(),
                  _buildMusicTab(),
                  _buildLanguageTab(),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(NsSpacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? NsColorsDark.border : NsColorsLight.border,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Кнопка Проверить (слева)
                  NsButton(
                    text: _isValidating ? 'Проверка...' : 'Проверить',
                    onPressed: _isValidating ? null : _validateSettings,
                    variant: ButtonVariant.secondary,
                  ),

                  // Кнопки справа
                  Row(
                    children: [
                      NsButton(
                        text: 'Отмена',
                        onPressed: () => Navigator.of(context).pop(),
                        variant: ButtonVariant.secondary,
                      ),
                      const SizedBox(width: NsSpacing.md),
                      NsButton(
                        text: 'Сохранить',
                        onPressed: _canSave ? _saveSettings : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
