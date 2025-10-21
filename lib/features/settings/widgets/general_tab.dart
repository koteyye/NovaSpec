import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/styled_dropdown.dart';
import 'package:file_picker/file_picker.dart';

class GeneralTab extends StatefulWidget {
  const GeneralTab({super.key});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  final _formKey = GlobalKey<FormState>();
  final _projectLocationController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }
  
  @override
  void dispose() {
    _projectLocationController.dispose();
    super.dispose();
  }
  
  void _loadCurrentSettings() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _projectLocationController.text = settings.defaultProjectLocation;
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
                // Application Settings
                _buildSection(
                  title: 'Приложение',
                  child: Column(
                    children: [
                      // Language
                      StyledDropdown<String>(
                        value: settings.language,
                        items: const [
                          DropdownMenuItem(value: 'ru', child: Text('Русский')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (language) {
                          if (language != null) {
                            settings.setLanguage(language);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Theme
                      StyledDropdown<String>(
                        value: settings.theme,
                        items: const [
                          DropdownMenuItem(value: 'system', child: Text('Системная')),
                          DropdownMenuItem(value: 'light', child: Text('Светлая')),
                          DropdownMenuItem(value: 'dark', child: Text('Темная')),
                        ],
                        onChanged: (theme) {
                          if (theme != null) {
                            settings.setTheme(theme);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Auto-save interval
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Автосохранение: ${_formatInterval(settings.autoSaveInterval)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: settings.autoSaveInterval.toDouble(),
                              min: 60,
                              max: 1800,
                              divisions: 29,
                              onChanged: (value) => settings.setAutoSaveInterval(value.round()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Default project location
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _projectLocationController,
                              decoration: const InputDecoration(
                                labelText: 'Расположение проектов по умолчанию',
                                hintText: 'Выберите папку для проектов',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.folder),
                              ),
                              readOnly: true,
                              onTap: () => _selectProjectLocation(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Выберите расположение для проектов';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ModernButton(
                            text: 'Обзор',
                            onPressed: () => _selectProjectLocation(context),
                            type: ButtonType.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Editor Settings
                _buildSection(
                  title: 'Редактор',
                  child: Column(
                    children: [
                      // Font size
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Размер шрифта: ${settings.fontSize.toInt()}px',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: settings.fontSize,
                              min: 8.0,
                              max: 24.0,
                              divisions: 16,
                              onChanged: (value) => settings.setFontSize(value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Tab size
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Размер табуляции: ${settings.tabSize} пробелов',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: settings.tabSize.toDouble(),
                              min: 1,
                              max: 8,
                              divisions: 7,
                              onChanged: (value) => settings.setTabSize(value.round()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Word wrap
                      SwitchListTile(
                        title: const Text('Перенос слов'),
                        subtitle: const Text('Автоматически переносить длинные строки'),
                        value: settings.wordWrap,
                        onChanged: (value) => settings.setWordWrap(value),
                        activeColor: const Color(0xFFB91C1C),
                      ),
                      const SizedBox(height: 8),
                      
                      // Auto completion
                      SwitchListTile(
                        title: const Text('Автодополнение'),
                        subtitle: const Text('Показывать подсказки при вводе'),
                        value: settings.autoCompletion,
                        onChanged: (value) => settings.setAutoCompletion(value),
                        activeColor: const Color(0xFFB91C1C),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Storage Information
                _buildSection(
                  title: 'Хранилище',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.security, color: Color(0xFFB91C1C)),
                        title: const Text('Безопасное хранилище'),
                        subtitle: const Text('API ключи и токены хранятся в зашифрованном виде'),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      ListTile(
                        leading: const Icon(Icons.storage, color: Color(0xFFB91C1C)),
                        title: const Text('Общие настройки'),
                        subtitle: const Text('Хранятся в локальных настройках приложения'),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      ModernButton(
                        text: 'Очистить кэш',
                        onPressed: () => _clearCache(context),
                        type: ButtonType.tertiary,
                        fullWidth: true,
                        icon: Icons.cleaning_services,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // About Section
                _buildSection(
                  title: 'О приложении',
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info, color: Color(0xFFB91C1C)),
                        title: const Text('NovaSpec'),
                        subtitle: const Text('Версия 1.0.0'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.description, color: Color(0xFFB91C1C)),
                        title: const Text('Описание'),
                        subtitle: const Text('Приложение для создания технических заданий с ИИ-ассистентом'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.code, color: Color(0xFFB91C1C)),
                        title: const Text('Технологии'),
                        subtitle: const Text('Flutter, Dart, Provider, Material Design 3'),
                      ),
                    ],
                  ),
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
  
  String _formatInterval(int seconds) {
    if (seconds < 60) {
      return '$seconds сек';
    } else {
      final minutes = seconds ~/ 60;
      return '$minutes мин';
    }
  }
  
  Future<void> _selectProjectLocation(BuildContext context) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Выберите папку для проектов',
      );
      
      if (result != null) {
        _projectLocationController.text = result;
        Provider.of<SettingsProvider>(context, listen: false).setDefaultProjectLocation(result);
      }
    } catch (e) {
      error(description: 'Ошибка выбора папки: $e');
    }
  }
  
  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить кэш'),
        content: const Text(
          'Вы уверены, что хотите очистить кэш приложения? '
          'Это может немного замедлить работу при следующем запуске.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ModernButton(
            text: 'Очистить',
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cache clearing
              show(description: 'Очистка кэша будет реализована в следующей версии');
            },
            type: ButtonType.danger,
          ),
        ],
      ),
    );
  }
}