import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../../shared/widgets/custom_styled_dropdown.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/services/toast_service.dart';

class SettingsDialogContent extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const SettingsDialogContent({super.key, required this.settingsProvider});

  @override
  State<SettingsDialogContent> createState() => _SettingsDialogContentState();
}

class _SettingsDialogContentState extends State<SettingsDialogContent> {
  final _baseUrlController = TextEditingController();
  final _tokenController = TextEditingController();
  final _confluenceUrlController = TextEditingController();
  final _confluenceEmailController = TextEditingController();
  final _confluenceTokenController = TextEditingController();
  final _musicTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current values
    _updateControllersFromSettings(widget.settingsProvider);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _tokenController.dispose();
    _confluenceUrlController.dispose();
    _confluenceEmailController.dispose();
    _confluenceTokenController.dispose();
    _musicTokenController.dispose();
    super.dispose();
  }

  void _updateControllersFromSettings(SettingsProvider settings) {
    try {
      _tokenController.text =
          settings.getProviderToken(settings.selectedAIProvider) ?? '';
      // Update base URL only for providers that need it
      if (settings.needsBaseUrl) {
        _baseUrlController.text = settings.getDefaultBaseUrl();
      } else {
        _baseUrlController.text = '';
      }
      _confluenceUrlController.text = settings.confluenceUrl;
      _confluenceEmailController.text = settings.confluenceEmail;
      _confluenceTokenController.text = settings.confluenceToken;
      _musicTokenController.text = settings.musicToken;
    } catch (e) {
      // Handle error silently or log through proper logging service
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: widget.settingsProvider,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Provider Section
              _buildSection(
                title: l10n.aiProviders,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.aiProviders,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomStyledDropdown<AIProvider>(
                          value: widget.settingsProvider.selectedAIProvider,
                          isExpanded: true,
                          items: AIProvider.values.map((provider) {
                            return DropdownItem(
                              value: provider,
                              label: provider.displayName,
                            );
                          }).toList(),
                      onChanged: (provider) {
                        if (provider != null) {
                          widget.settingsProvider.setSelectedAIProvider(
                            provider,
                          );
                          // Update token controller when provider changes
                          _tokenController.text =
                              widget.settingsProvider.getProviderToken(
                                provider,
                              ) ??
                              '';
                          // Update base URL controller only for providers that need it
                          if (widget.settingsProvider.needsBaseUrl) {
                            _baseUrlController.text = widget.settingsProvider
                                .getDefaultBaseUrl();
                          }
                        }
                      },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Base URL (conditional)
                    if (widget.settingsProvider.needsBaseUrl) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.baseUrl,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _baseUrlController,
                            hint: 'https://api.example.com',
                            onChanged: (value) =>
                                widget.settingsProvider.setBaseUrl(value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Z.AI Access Type (conditional)
                    if (widget.settingsProvider.isZAIProvider) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.zAiAccessType,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomStyledDropdown<ZAIAccessType>(
                            value: widget.settingsProvider.zaiAccessType,
                            isExpanded: true,
                            items: ZAIAccessType.values.map((type) {
                              return DropdownItem(
                                value: type,
                                label: type.displayName,
                              );
                            }).toList(),
                            onChanged: (type) {
                              if (type != null) {
                                widget.settingsProvider.setZaiAccessType(type);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // API Token
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.apiKey,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _tokenController,
                          hint: widget.settingsProvider
                              .getApiKeyPlaceholder(),
                          obscureText: true,
                          onChanged: (value) =>
                              widget.settingsProvider.setApiKey(value),
                          suffixIcon: widget.settingsProvider.isZAIProvider
                              ? IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () => _testAIConnection(context),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Confluence Section
              _buildSection(
                title: l10n.confluenceIntegration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enable Toggle
                    SwitchListTile(
                      title: Text(l10n.confluenceIntegration),
                      value: widget.settingsProvider.confluenceEnabled,
                      onChanged: (value) =>
                          widget.settingsProvider.setConfluenceEnabled(value),
                    ),

                    if (widget.settingsProvider.confluenceEnabled) ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.confluenceUrl,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _confluenceUrlController,
                            hint: 'https://your-domain.atlassian.net',
                            onChanged: (value) =>
                                widget.settingsProvider.setConfluenceUrl(value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _confluenceEmailController,
                            hint: 'your-email@example.com',
                            onChanged: (value) =>
                                widget.settingsProvider.setConfluenceEmail(value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.confluenceToken,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _confluenceTokenController,
                            hint: 'ATATT3xFfGF0...',
                            obscureText: true,
                            onChanged: (value) =>
                                widget.settingsProvider.setConfluenceToken(value),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Music Section
              _buildSection(
                title: l10n.musicIntegration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enable Toggle
                    SwitchListTile(
                      title: Text(l10n.musicIntegration),
                      value: widget.settingsProvider.musicEnabled,
                      onChanged: (value) =>
                          widget.settingsProvider.setMusicEnabled(value),
                    ),

                    if (widget.settingsProvider.musicEnabled) ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.apiKey,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _musicTokenController,
                            hint: 'sk-gen-api-...',
                            obscureText: true,
                            onChanged: (value) =>
                                widget.settingsProvider.setMusicToken(value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.musicGenre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomStyledDropdown<String>(
                            value:
                                widget.settingsProvider.musicGenre.toLowerCase() ==
                                    'pop'
                                ? 'pop'
                                : widget.settingsProvider.musicGenre,
                            isExpanded: true,
                            items: widget.settingsProvider
                                .getAvailableGenres(
                                  widget.settingsProvider.language,
                                )
                                .map((genreDisplayName) {
                                  final systemName =
                                      widget.settingsProvider.language == 'ru'
                                      ? SettingsProvider
                                                .genresRu[genreDisplayName] ??
                                            'pop'
                                      : SettingsProvider
                                                .genresEn[genreDisplayName] ??
                                            'pop';
                                  return DropdownItem(
                                    value: systemName, // Use system name as value
                                    label: genreDisplayName,
                                  );
                                })
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                widget.settingsProvider.setMusicGenre(value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Получите токен на https://gen-api.ru',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://gen-api.ru')),
                        child: const Text(
                          'https://gen-api.ru',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Theme Section
              _buildSection(
                title: l10n.theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.theme,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomStyledDropdown<String>(
                      value:
                          Provider.of<AppProvider>(
                            context,
                          ).appConfiguration?.theme ??
                          'system',
                      isExpanded: true,
                      items: const [
                        DropdownItem(value: 'system', label: 'Системная'),
                        DropdownItem(value: 'light', label: 'Светлая'),
                        DropdownItem(value: 'dark', label: 'Темная'),
                      ],
                      onChanged: (theme) {
                        if (theme != null) {
                          final appProvider = Provider.of<AppProvider>(
                            context,
                            listen: false,
                          );
                          appProvider.updateTheme(theme);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Language Section
              _buildSection(
                title: l10n.language,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomStyledDropdown<String>(
                      value: widget.settingsProvider.language,
                      isExpanded: true,
                      items: const [
                        DropdownItem(value: 'ru', label: 'Русский'),
                        DropdownItem(value: 'en', label: 'English'),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          widget.settingsProvider.setLanguage(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Future<void> _testAIConnection(BuildContext context) async {
    try {
      // Показываем индикатор загрузки
      DialogHelper.showLoadingDialog(
        context,
        title: 'Проверка подключения...',
      );

      final isValid = await widget.settingsProvider.validateCurrentProvider();
      
      // Закрываем диалог загрузки
      if (context.mounted) {
        DialogHelper.hideLoadingDialog(context);
      }

      if (isValid && context.mounted) {
        // Автоматически сохраняем конфигурацию при успешной валидации
        await widget.settingsProvider.saveSettings();
        
        // Показываем успех через ModernToast
        ToastService().showSuccess(
          title: 'Подключение успешно',
          description: 'Подключение к ${widget.settingsProvider.selectedAIProvider.displayName} установлено',
        );
      } else if (context.mounted) {
        // Показываем ошибку через CustomDialog
        await DialogHelper.showConfirmDialog(
          context,
          title: 'Ошибка подключения',
          content: widget.settingsProvider.errorMessage ?? 'Неизвестная ошибка',
          confirmText: 'ОК',
          onConfirm: () {},
        );
      }
    } catch (e) {
      // Закрываем диалог загрузки если открыт
      try {
        if (context.mounted) {
          DialogHelper.hideLoadingDialog(context);
        }
      } catch (_) {}
      
      // Показываем ошибку через CustomDialog
      if (context.mounted) {
        await DialogHelper.showConfirmDialog(
          context,
          title: 'Ошибка подключения',
          content: 'Ошибка: ${e.toString()}',
          confirmText: 'ОК',
          onConfirm: () {},
        );
      }
    }
  }
}
