import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/styled_dropdown.dart';
import '../../../shared/widgets/validation_status_widget.dart';

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
                         decoration: InputDecoration(
                           labelText: 'URL сервера Confluence',
                           hintText: 'https://your-company.atlassian.net/wiki',
                           border: const OutlineInputBorder(),
                           suffixIcon: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               ValidationStatusWidget(
                                 connectionStatus: settings.connectionStatuses['confluence'],
                               ),
                               const SizedBox(width: 8),
                               IconButton(
                                 icon: const Icon(Icons.autorenew),
                                 onPressed: () => _detectConfluenceType(context),
                               ),
                             ],
                           ),
                         ),
                         keyboardType: TextInputType.url,
                         onChanged: (value) {
                           settings.setConfluenceUrl(value);
                           // Автоопределение типа при изменении URL
                           if (value.isNotEmpty) {
                             _detectConfluenceType(context);
                           }
                         },
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
                         decoration: InputDecoration(
                           labelText: settings.confluenceAuthMethod == ConfluenceAuthMethod.basicAuth 
                               ? 'Пароль' 
                               : 'API Token',
                           hintText: settings.confluenceAuthMethod == ConfluenceAuthMethod.basicAuth 
                               ? 'Введите пароль'
                               : 'Введите ваш API токен',
                           border: const OutlineInputBorder(),
                           helperText: settings.confluenceAuthMethod == ConfluenceAuthMethod.basicAuth
                               ? 'Пароль для Basic Auth'
                               : 'Создайте токен в настройках аккаунта Atlassian',
                           suffixIcon: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               ValidationStatusWidget(
                                 connectionStatus: settings.connectionStatuses['confluence'],
                               ),
                               const SizedBox(width: 8),
                               IconButton(
                                 icon: const Icon(Icons.check),
                                 onPressed: () => _testConfluenceConnection(context),
                               ),
                             ],
                           ),
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
                         value: settings.musicProvider.isEmpty ? 'gen-api' : settings.musicProvider,
                         items: const [
                           DropdownMenuItem(
                             value: 'gen-api',
                             child: Text('Gen-API.ru'),
                           ),
                         ],
                         onChanged: (provider) {
                           if (provider != null) {
                             settings.setMusicProvider(provider);
                           }
                         },
                       ),
                       const SizedBox(height: 16),
                      
                       TextFormField(
                         controller: _musicKeyController,
                         decoration: InputDecoration(
                           labelText: 'API Key gen-api.ru',
                           hintText: 'Введите API ключ gen-api.ru',
                           border: const OutlineInputBorder(),
                           suffixIcon: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               ValidationStatusWidget(
                                 connectionStatus: settings.connectionStatuses['music'],
                               ),
                               const SizedBox(width: 8),
                               IconButton(
                                 icon: const Icon(Icons.check),
                                 onPressed: () => _testMusicConnection(context),
                               ),
                             ],
                           ),
                         ),
                         obscureText: true,
                         onChanged: (value) => settings.setMusicApiKey(value),
                       ),
                       const SizedBox(height: 16),
                       
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Жанр музыки',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            StyledDropdown<String>(
                              value: settings.musicGenre,
                              items: const [
                                DropdownMenuItem(value: 'pop', child: Text('Pop Music')),
                                DropdownMenuItem(value: 'Russian rap', child: Text('Russian rap')),
                                DropdownMenuItem(value: 'Rock', child: Text('Rock')),
                                DropdownMenuItem(value: 'Jazz', child: Text('Jazz')),
                                DropdownMenuItem(value: 'Classic', child: Text('Classic')),
                                DropdownMenuItem(value: 'Electronic', child: Text('Electronic')),
                                DropdownMenuItem(value: 'Hip-hop', child: Text('Hip-hop')),
                                DropdownMenuItem(value: 'R&B', child: Text('R&B')),
                              ],
                              onChanged: (String? value) {
                                if (value != null) {
                                  settings.setMusicGenre(value);
                                }
                              },
                            ),
                          ],
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
      case ConfluenceAuthMethod.basicAuth:
        return 'Basic Auth';
    }
  }
  
  void _detectConfluenceType(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final url = _confluenceUrlController.text;
    
    if (url.isNotEmpty) {
      final detectedType = settings.detectConfluenceType(url);
      settings.setConfluenceAuthMethod(detectedType);
      
      final typeName = detectedType == ConfluenceAuthMethod.apiToken ? 'Cloud' : 'Data Center';
      success(description: 'Определен тип Confluence: $typeName');
    }
  }
  
  Future<void> _testConfluenceConnection(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settings.confluenceUrl.isEmpty || settings.confluenceApiToken.isEmpty) {
      warning(description: 'Заполните URL и API токен для Confluence');
      return;
    }
    
    if (settings.confluenceAuthMethod == ConfluenceAuthMethod.basicAuth && 
        settings.confluenceUsername.isEmpty) {
      warning(description: 'Для Basic Auth требуется имя пользователя');
      return;
    }
    
    try {
      final result = await settings.validateConfluence();
      
      if (result.isValid) {
        success(description: 'Подключение к Confluence успешно: ${result.message}');
      } else {
        error(description: 'Ошибка подключения: ${result.message}');
      }
    } catch (e) {
      error(description: 'Ошибка проверки: $e');
    }
  }
  
  Future<void> _testMusicConnection(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    if (settings.musicApiKey.isEmpty) {
      warning(description: 'Введите API ключ gen-api.ru');
      return;
    }
    
    try {
      final result = await settings.validateMusicService();
      
      if (result.isValid) {
        success(description: 'Подключение к gen-api.ru успешно: ${result.message}');
      } else {
        error(description: 'Ошибка подключения: ${result.message}');
      }
    } catch (e) {
      error(description: 'Ошибка проверки: $e');
    }
  }
}