import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/styled_dropdown.dart';

class AIProvidersTab extends StatefulWidget {
  const AIProvidersTab({super.key});

  @override
  State<AIProvidersTab> createState() => _AIProvidersTabState();
}

class _AIProvidersTabState extends State<AIProvidersTab> {
  final _formKey = GlobalKey<FormState>();
  final _openaiKeyController = TextEditingController();
  final _anthropicKeyController = TextEditingController();
  final _groqKeyController = TextEditingController();
  final _openaiUrlController = TextEditingController();
  final _anthropicUrlController = TextEditingController();
  final _groqUrlController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }
  
  @override
  void dispose() {
    _openaiKeyController.dispose();
    _anthropicKeyController.dispose();
    _groqKeyController.dispose();
    _openaiUrlController.dispose();
    _anthropicUrlController.dispose();
    _groqUrlController.dispose();
    super.dispose();
  }
  
  void _loadCurrentSettings() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    _openaiKeyController.text = settings.openaiApiKey;
    _anthropicKeyController.text = settings.anthropicApiKey;
    _groqKeyController.text = settings.groqApiKey;
    _openaiUrlController.text = settings.openaiBaseUrl;
    _anthropicUrlController.text = settings.anthropicBaseUrl;
    _groqUrlController.text = settings.groqBaseUrl;
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
                // Provider Selection
                _buildSection(
                  title: 'Выбор AI провайдера',
                  child: StyledDropdown<AIProvider>(
                    value: settings.selectedAIProvider,
                    items: AIProvider.values.map((provider) {
                      return DropdownMenuItem(
                        value: provider,
                        child: Text(_getProviderName(provider)),
                      );
                    }).toList(),
                    onChanged: (provider) {
                      if (provider != null) {
                        settings.setSelectedAIProvider(provider);
                      }
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // OpenAI Configuration
                _buildProviderSection(
                  title: 'OpenAI',
                  icon: Icons.smart_toy,
                  isActive: settings.selectedAIProvider == AIProvider.openai,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _openaiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'sk-...',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) => settings.setOpenaiApiKey(value),
                        validator: (value) {
                          if (settings.selectedAIProvider == AIProvider.openai && 
                              (value == null || value.isEmpty)) {
                            return 'API ключ обязателен для OpenAI';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _openaiUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Base URL',
                          hintText: 'https://api.openai.com/v1',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => settings.setOpenaiBaseUrl(value),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Anthropic Configuration
                _buildProviderSection(
                  title: 'Anthropic Claude',
                  icon: Icons.psychology,
                  isActive: settings.selectedAIProvider == AIProvider.anthropic,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _anthropicKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'sk-ant-...',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) => settings.setAnthropicApiKey(value),
                        validator: (value) {
                          if (settings.selectedAIProvider == AIProvider.anthropic && 
                              (value == null || value.isEmpty)) {
                            return 'API ключ обязателен для Anthropic';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _anthropicUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Base URL',
                          hintText: 'https://api.anthropic.com',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => settings.setAnthropicBaseUrl(value),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Groq Configuration
                _buildProviderSection(
                  title: 'Groq',
                  icon: Icons.flash_on,
                  isActive: settings.selectedAIProvider == AIProvider.groq,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _groqKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'gsk_...',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) => settings.setGroqApiKey(value),
                        validator: (value) {
                          if (settings.selectedAIProvider == AIProvider.groq && 
                              (value == null || value.isEmpty)) {
                            return 'API ключ обязателен для Groq';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _groqUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Base URL',
                          hintText: 'https://api.groq.com/openai/v1',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => settings.setGroqBaseUrl(value),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Common Settings
                _buildSection(
                  title: 'Общие параметры',
                  child: Column(
                    children: [
                      // Temperature
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Temperature: ${settings.temperature.toStringAsFixed(1)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: settings.temperature,
                              min: 0.0,
                              max: 2.0,
                              divisions: 20,
                              onChanged: (value) => settings.setTemperature(value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Max Tokens
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Max Tokens: ${settings.maxTokens}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: settings.maxTokens.toDouble(),
                              min: 256,
                              max: 8192,
                              divisions: 31,
                              onChanged: (value) => settings.setMaxTokens(value.round()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Timeout
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Timeout: ${settings.timeoutSeconds}s',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: settings.timeoutSeconds.toDouble(),
                              min: 5,
                              max: 120,
                              divisions: 23,
                              onChanged: (value) => settings.setTimeoutSeconds(value.round()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Test Connection Button
                ModernButton(
                  text: 'Проверить соединение',
                  onPressed: () => _testConnection(context),
                  type: ButtonType.secondary,
                  fullWidth: true,
                  icon: Icons.network_check,
                ),
              ],
            ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB91C1C),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
  
  Widget _buildProviderSection({
    required String title,
    required IconData icon,
    required bool isActive,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive 
              ? const Color(0xFFB91C1C).withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(12),
        color: isActive 
            ? const Color(0xFFB91C1C).withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? const Color(0xFFB91C1C) : null,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFFB91C1C) : null,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB91C1C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Активен',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
  
  String _getProviderName(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.anthropic:
        return 'Anthropic Claude';
      case AIProvider.groq:
        return 'Groq';
    }
  }
  
  void _testConnection(BuildContext context) {
    // TODO: Implement connection testing
    warning(description: 'Проверка соединения будет реализована в следующей версии');
  }
}