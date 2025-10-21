import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/styled_dropdown.dart';

class IntegrationsTab extends StatefulWidget {
  const IntegrationsTab({super.key});

  @override
  State<IntegrationsTab> createState() => _IntegrationsTabState();
}

class _IntegrationsTabState extends State<IntegrationsTab> {
  final _formKey = GlobalKey<FormState>();
  final _confluenceUrlController = TextEditingController();
  final _confluenceUsernameController = TextEditingController();
  final _confluenceTokenController = TextEditingController();
  final _defaultSpaceController = TextEditingController();
  final _musicKeyController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }
  
  @override
  void dispose() {
    _confluenceUrlController.dispose();
    _confluenceUsernameController.dispose();
    _confluenceTokenController.dispose();
    _defaultSpaceController.dispose();
    _musicKeyController.dispose();
    super.dispose();
  }
  
  void _loadCurrentSettings() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    _confluenceUrlController.text = settings.confluenceUrl;
    _confluenceUsernameController.text = settings.confluenceUsername;
    _confluenceTokenController.text = settings.confluenceApiToken;
    _defaultSpaceController.text = settings.defaultSpace;
    _musicKeyController.text = settings.musicApiKey;
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Confluence Integration
                _buildIntegrationSection(
                  title: 'Confluence',
                  icon: Icons.article,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _confluenceUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL сервера Confluence',
                          hintText: 'https://your-company.atlassian.net/wiki',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (value) => settings.setConfluenceUrl(value),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final uri = Uri.tryParse(value);
                            if (uri == null || !uri.hasScheme) {
                              return 'Введите корректный URL';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      StyledDropdown<ConfluenceAuthMethod>(
                        value: settings.confluenceAuthMethod,
                        items: ConfluenceAuthMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(_getAuthMethodName(method)),
                          );
                        }).toList(),
                        onChanged: (method) {
                          if (method != null) {
                            settings.setConfluenceAuthMethod(method);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _confluenceUsernameController,
                        decoration: const InputDecoration(
                          labelText: 'Имя пользователя или email',
                          hintText: 'user@example.com',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => settings.setConfluenceUsername(value),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _confluenceTokenController,
                        decoration: const InputDecoration(
                          labelText: 'API Token',
                          hintText: 'Введите ваш API токен',
                          border: OutlineInputBorder(),
                          helperText: 'Создайте токен в настройках аккаунта Atlassian',
                        ),
                        obscureText: true,
                        onChanged: (value) => settings.setConfluenceApiToken(value),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _defaultSpaceController,
                        decoration: const InputDecoration(
                          labelText: 'Пространство по умолчанию',
                          hintText: 'PROJ',
                          border: OutlineInputBorder(),
                          helperText: 'Ключ пространства для создания страниц',
                        ),
                        onChanged: (value) => settings.setDefaultSpace(value),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Music Generation Integration
                _buildIntegrationSection(
                  title: 'Генерация музыки',
                  icon: Icons.music_note,
                  child: Column(
                    children: [
                      StyledDropdown<String>(
                        value: settings.musicProvider.isEmpty ? '' : settings.musicProvider,
                        items: const [
                          DropdownMenuItem(
                            value: 'suno',
                            child: Text('Suno AI'),
                          ),
                          DropdownMenuItem(
                            value: 'udio',
                            child: Text('Udio'),
                          ),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text('Другой провайдер'),
                          ),
                        ],
                        onChanged: (provider) {
                          if (provider != null) {
                            settings.setMusicProvider(provider);
                          }
                        },
                        hint: 'Выберите провайдера',
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _musicKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'Введите API ключ музыкального сервиса',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) => settings.setMusicApiKey(value),
                      ),
                      const SizedBox(height: 16),
                      
                      StyledDropdown<String>(
                        value: settings.audioFormat,
                        items: const [
                          DropdownMenuItem(value: 'mp3', child: Text('MP3')),
                          DropdownMenuItem(value: 'wav', child: Text('WAV')),
                          DropdownMenuItem(value: 'flac', child: Text('FLAC')),
                        ],
                        onChanged: (format) {
                          if (format != null) {
                            settings.setAudioFormat(format);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      StyledDropdown<String>(
                        value: settings.audioQuality,
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Низкое')),
                          DropdownMenuItem(value: 'standard', child: Text('Стандартное')),
                          DropdownMenuItem(value: 'high', child: Text('Высокое')),
                          DropdownMenuItem(value: 'premium', child: Text('Премиум')),
                        ],
                        onChanged: (quality) {
                          if (quality != null) {
                            settings.setAudioQuality(quality);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Test Connections
                Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Проверить Confluence',
                        onPressed: () => _testConfluenceConnection(context),
                        type: ButtonType.secondary,
                        icon: Icons.article,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernButton(
                        text: 'Проверить музыку',
                        onPressed: () => _testMusicConnection(context),
                        type: ButtonType.secondary,
                        icon: Icons.music_note,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildIntegrationSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFB91C1C)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
  
  String _getAuthMethodName(ConfluenceAuthMethod method) {
    switch (method) {
      case ConfluenceAuthMethod.apiToken:
        return 'API Token';
      case ConfluenceAuthMethod.oauth:
        return 'OAuth';
    }
  }
  
  void _testConfluenceConnection(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settings.confluenceUrl.isEmpty || 
        settings.confluenceUsername.isEmpty || 
        settings.confluenceApiToken.isEmpty) {
      warning(description: 'Заполните все поля для Confluence интеграции');
      return;
    }
    
    // TODO: Implement actual connection testing
    show(description: 'Проверка соединения с Confluence будет реализована в следующей версии');
  }
  
  void _testMusicConnection(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settings.musicProvider.isEmpty || settings.musicApiKey.isEmpty) {
      warning(description: 'Выберите провайдера и введите API ключ');
      return;
    }
    
    // TODO: Implement actual connection testing
    show(description: 'Проверка соединения с музыкальным сервисом будет реализована в следующей версии');
  }
}