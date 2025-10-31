import 'package:flutter/material.dart';
import '../providers/workspace_provider.dart';
import '../providers/tab_provider.dart';
import '../../../core/services/workspace_file_service.dart';
import '../../../shared/widgets/modern_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/di_container.dart';

class CreateFileDialog extends StatefulWidget {
  final String? initialPath;
  final Function(String)? onFileCreated;

  const CreateFileDialog({
    super.key,
    this.initialPath,
    this.onFileCreated,
  });

  @override
  State<CreateFileDialog> createState() => _CreateFileDialogState();
}

class _CreateFileDialogState extends State<CreateFileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'txt';
  String _selectedTemplate = 'empty';
  bool _isCreating = false;

  // Доступные типы файлов
  final List<FileTypeOption> _fileTypes = [
    const FileTypeOption(
      value: 'dart',
      title: 'Dart',
      description: 'Файл Dart класса',
      icon: Icons.code,
    ),
    const FileTypeOption(
      value: 'js',
      title: 'JavaScript',
      description: 'JavaScript файл',
      icon: Icons.javascript,
    ),
    const FileTypeOption(
      value: 'ts',
      title: 'TypeScript',
      description: 'TypeScript файл',
      icon: Icons.code,
    ),
    const FileTypeOption(
      value: 'py',
      title: 'Python',
      description: 'Python скрипт',
      icon: Icons.psychology,
    ),
    const FileTypeOption(
      value: 'html',
      title: 'HTML',
      description: 'HTML страница',
      icon: Icons.web,
    ),
    const FileTypeOption(
      value: 'css',
      title: 'CSS',
      description: 'CSS таблица стилей',
      icon: Icons.palette,
    ),
    const FileTypeOption(
      value: 'json',
      title: 'JSON',
      description: 'JSON файл данных',
      icon: Icons.data_object,
    ),
    const FileTypeOption(
      value: 'yaml',
      title: 'YAML',
      description: 'YAML конфигурация',
      icon: Icons.description,
    ),
    const FileTypeOption(
      value: 'md',
      title: 'Markdown',
      description: 'Markdown документ',
      icon: Icons.description,
    ),
    const FileTypeOption(
      value: 'txt',
      title: 'Text',
      description: 'Текстовый файл',
      icon: Icons.text_snippet,
    ),
    const FileTypeOption(
      value: 'env',
      title: 'Environment',
      description: 'Файл переменных окружения',
      icon: Icons.shield,
    ),
    const FileTypeOption(
      value: 'gitignore',
      title: '.gitignore',
      description: 'Git ignore файл',
      icon: Icons.code,
    ),
  ];

  // Шаблоны для разных типов файлов
  Map<String, List<TemplateOption>> get _templates => {
    'dart': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'class',
        title: 'Класс',
        content: '''class ClassName {
  // Constructor
  ClassName();

  // Methods
  void methodName() {
    // TODO: Implement method
  }
}''',
      ),
      const TemplateOption(
        value: 'widget',
        title: 'Flutter Widget',
        content: '''import 'package:flutter/material.dart';

class CustomWidget extends StatelessWidget {
  const CustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Custom Widget'),
    );
  }
}''',
      ),
    ],
    'js': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'function',
        title: 'Функция',
        content: '''function functionName() {
  // TODO: Implement function
}

// Export
module.exports = functionName;''',
      ),
      const TemplateOption(
        value: 'class',
        title: 'Класс ES6',
        content: '''class ClassName {
  constructor() {
    // TODO: Initialize
  }

  methodName() {
    // TODO: Implement method
  }
}

export default ClassName;''',
      ),
    ],
    'ts': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'interface',
        title: 'Interface',
        content: '''interface InterfaceName {
  property: string;
  method(): void;
}

export default InterfaceName;''',
      ),
      const TemplateOption(
        value: 'class',
        title: 'Класс',
        content: '''class ClassName implements InterfaceName {
  property: string = '';

  constructor() {
    // TODO: Initialize
  }

  method(): void {
    // TODO: Implement method
  }
}

export default ClassName;''',
      ),
    ],
    'py': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'function',
        title: 'Функция',
        content: '''def function_name():
    """TODO: Add docstring"""
    pass

if __name__ == "__main__":
    function_name()''',
      ),
      const TemplateOption(
        value: 'class',
        title: 'Класс',
        content: '''class ClassName:
    """TODO: Add docstring"""
    
    def __init__(self):
        pass
    
    def method_name(self):
        pass

if __name__ == "__main__":
    instance = ClassName()
    instance.method_name()''',
      ),
    ],
    'html': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'basic',
        title: 'Базовая HTML страница',
        content: '''<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>Hello World</h1>
</body>
</html>''',
      ),
      const TemplateOption(
        value: 'bootstrap',
        title: 'Bootstrap страница',
        content: '''<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bootstrap Page</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h1>Hello Bootstrap</h1>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>''',
      ),
    ],
    'css': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'reset',
        title: 'CSS Reset',
        content: '''/* CSS Reset */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
}''',
      ),
    ],
    'json': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'object',
        title: 'JSON объект',
        content: '''{
  "name": "Project Name",
  "version": "1.0.0",
  "description": "Project description"
}''',
      ),
      const TemplateOption(
        value: 'array',
        title: 'JSON массив',
        content: '''[
  {
    "id": 1,
    "name": "Item 1"
  },
  {
    "id": 2,
    "name": "Item 2"
  }
]''',
      ),
    ],
    'yaml': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'config',
        title: 'Конфигурация',
        content: '''# Configuration
app:
  name: "My App"
  version: "1.0.0"
  debug: true

database:
  host: "localhost"
  port: 5432
  name: "myapp"''',
      ),
    ],
    'md': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'readme',
        title: 'README',
        content: '''# Project Name

## Description

Brief description of the project.

## Installation

```bash
npm install
```

## Usage

```bash
npm start
```

## License

MIT''',
      ),
    ],
    'txt': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
    ],
    'env': [
      const TemplateOption(
        value: 'empty',
        title: 'Пустой файл',
        content: '',
      ),
      const TemplateOption(
        value: 'basic',
        title: 'Базовый .env',
        content: '''# Environment Variables
APP_NAME=MyApp
APP_VERSION=1.0.0
DEBUG=true
PORT=3000''',
      ),
    ],
    'gitignore': [
      const TemplateOption(
        value: 'basic',
        title: 'Базовый .gitignore',
        content: '''# Dependencies
node_modules/
.pubs-cache/

# Build
build/
dist/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log''',
      ),
    ],
  };

  List<TemplateOption> get _currentTemplates {
    return _templates[_selectedType] ?? [const TemplateOption(value: 'empty', title: 'Пустой файл', content: '')];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createFile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final workspaceProvider = getIt<WorkspaceProvider>();
      final tabProvider = getIt<TabProvider>();
      final workspaceFileService = getIt<WorkspaceFileService>();

      // Формируем имя файла с расширением
      String fileName = _nameController.text.trim();
      if (!fileName.contains('.')) {
        fileName += '.$_selectedType';
      }

      // Формируем полный путь
      final fullPath = widget.initialPath != null 
          ? '${widget.initialPath}/$fileName'
          : fileName;

      // Получаем содержимое шаблона
      final template = _currentTemplates.firstWhere((t) => t.value == _selectedTemplate);
      final content = template.content;

      // Создаем файл
      await workspaceFileService.writeFile(fullPath, content);

      // Обновляем файловый эксплорер
      await workspaceProvider.refreshCurrentDirectory();

      // Открываем файл в новой вкладке
      await tabProvider.openTab(fullPath);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onFileCreated?.call(fullPath);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.fileCreated(fileName)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.createFileError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Icon(
                      Icons.note_add,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.createNewFile,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Имя файла
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fileName,
                    hintText: l10n.enterFileName,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterFileNameError;
                    }
                    if (value.trim().contains(RegExp(r'[<>:"/\\|?*]'))) {
                      return l10n.invalidFileNameError;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 20),
                
                // Тип файла
                Text(
                  l10n.fileType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _fileTypes.length,
                    itemBuilder: (context, index) {
                      final fileType = _fileTypes[index];
                      final isSelected = fileType.value == _selectedType;
                      
                      return ListTile(
                        leading: Icon(
                          fileType.icon,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                        title: Text(fileType.title),
                        subtitle: Text(fileType.description),
                        selected: isSelected,
                        selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        onTap: () {
                          setState(() {
                            _selectedType = fileType.value;
                            _selectedTemplate = _currentTemplates.first.value;
                          });
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Шаблон
                if (_currentTemplates.length > 1) ...[
                  Text(
                    l10n.template,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedTemplate,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    items: _currentTemplates.map((template) {
                      return DropdownMenuItem(
                        value: template.value,
                        child: Text(template.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTemplate = value);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
                
                // Кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ModernButton(
                      text: l10n.cancel,
                      type: ButtonType.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      text: _isCreating ? l10n.creating : l10n.create,
                      type: ButtonType.primary,
                      onPressed: _isCreating ? null : _createFile,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FileTypeOption {
  final String value;
  final String title;
  final String description;
  final IconData icon;

  const FileTypeOption({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class TemplateOption {
  final String value;
  final String title;
  final String content;

  const TemplateOption({
    required this.value,
    required this.title,
    required this.content,
  });
}

// Вспомогательный метод для показа диалога
class CreateFileDialogHelper {
  static Future<String?> showCreateFileDialog(
    BuildContext context, {
    String? initialPath,
    Function(String)? onFileCreated,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => CreateFileDialog(
        initialPath: initialPath,
        onFileCreated: onFileCreated,
      ),
    );
  }
}
