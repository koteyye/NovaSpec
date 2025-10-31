import 'package:flutter/material.dart';
import '../models/workspace_tab.dart';

class CodeEditor extends StatefulWidget {
  final WorkspaceTab tab;

  const CodeEditor({
    super.key,
    required this.tab,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isModified = false;
  int _currentLine = 1;


  @override
  void initState() {
    super.initState();
    _loadFileContent();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Line numbers
        _buildLineNumbers(context),
        
        // Vertical divider
        Container(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
        
        // Editor area
        Expanded(
          child: _buildEditorArea(context),
        ),
      ],
    );
  }

  Widget _buildLineNumbers(BuildContext context) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _getLineCount(),
        itemBuilder: (context, index) {
          final lineNumber = index + 1;
          final isCurrentLine = lineNumber == _currentLine;
          
          return Container(
            height: 20,
            padding: const EdgeInsets.only(right: 8),
            alignment: Alignment.centerRight,
            child: Text(
              '$lineNumber',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isCurrentLine 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditorArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Editor toolbar
          _buildEditorToolbar(context),
          
          // Text editor
          Expanded(
            child: _buildTextEditor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorToolbar(BuildContext context) {
    return Container(
      height: 32,
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
          // Language indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.tab.language?.toUpperCase() ?? 'TEXT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Editor actions
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo, size: 16),
                onPressed: () {
                  // TODO: Undo
                },
                tooltip: 'Отменить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 16),
                onPressed: () {
                  // TODO: Redo
                },
                tooltip: 'Повторить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              Container(
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Theme.of(context).dividerColor,
              ),
              IconButton(
                icon: const Icon(Icons.format_align_left, size: 16),
                onPressed: () {
                  // TODO: Format code
                },
                tooltip: 'Форматировать',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.find_replace, size: 16),
                onPressed: () {
                  _showFindReplaceDialog(context);
                },
                tooltip: 'Найти и заменить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextEditor(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          height: 1.4,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(8),
        ),
        onChanged: (value) {
          _updateCursorPosition();
        },
        onTap: () {
          _updateCursorPosition();
        },
      ),
    );
  }

  void _loadFileContent() {
    // TODO: Load actual file content
    // For now, use sample content based on file type
    final sampleContent = _getSampleContent(widget.tab.language ?? 'plaintext');
    _textController.text = sampleContent;
  }

  void _onTextChanged() {
    final wasModified = _isModified;
    _isModified = _textController.text.isNotEmpty;
    
    if (wasModified != _isModified) {
      // TODO: Update tab modified state
      setState(() {});
    }
  }

  void _updateCursorPosition() {
    // TODO: Implement proper cursor position tracking
    final text = _textController.text;
    final position = _textController.selection.baseOffset;
    
    if (position >= 0 && position <= text.length) {
      final beforeCursor = text.substring(0, position);
      final lines = beforeCursor.split('\n');
      _currentLine = lines.length;
      
      setState(() {});
    }
  }

  int _getLineCount() {
    if (_textController.text.isEmpty) return 1;
    return _textController.text.split('\n').length;
  }

  void _showFindReplaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Найти и заменить'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Найти',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Заменить',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement find and replace
              Navigator.pop(context);
            },
            child: const Text('Найти'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement replace all
              Navigator.pop(context);
            },
            child: const Text('Заменить все'),
          ),
        ],
      ),
    );
  }

  String _getSampleContent(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return '''import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaSpec Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NovaSpec Workspace'),
      ),
      body: const Center(
        child: Text('Hello, NovaSpec!'),
      ),
    );
  }
}''';
      case 'javascript':
        return '''// JavaScript Example
function greetUser(name) {
  console.log(`Hello, \${name}!`);
}

const users = ['Alice', 'Bob', 'Charlie'];

users.forEach(user => {
  greetUser(user);
});

// Arrow function example
const add = (a, b) => a + b;

console.log('2 + 3 =', add(2, 3));''';
      case 'typescript':
        return '''// TypeScript Example
interface User {
  id: number;
  name: string;
  email: string;
}

class UserService {
  private users: User[] = [];

  addUser(user: User): void {
    this.users.push(user);
  }

  getUserById(id: number): User | undefined {
    return this.users.find(user => user.id === id);
  }
}

const userService = new UserService();
userService.addUser({
  id: 1,
  name: 'John Doe',
  email: 'john@example.com'
});''';
      case 'python':
        return '''# Python Example
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    def greet(self):
        return f"Hello, my name is {self.name} and I'm {self.age} years old."

def main():
    people = [
        Person("Alice", 30),
        Person("Bob", 25),
        Person("Charlie", 35)
    ]
    
    for person in people:
        print(person.greet())

if __name__ == "__main__":
    main()''';
      case 'json':
        return '''{
  "name": "NovaSpec",
  "version": "1.0.0",
  "description": "AI-powered specification tool",
  "features": [
    "File management",
    "Code editing",
    "AI assistance",
    "Markdown support"
  ],
  "dependencies": {
    "flutter": "^3.0.0",
    "provider": "^6.0.0",
    "dio": "^5.0.0"
  },
  "devDependencies": {
    "flutter_test": "^3.0.0",
    "build_runner": "^2.0.0"
  }
}''';
      case 'markdown':
        return '''# NovaSpec Documentation

## Features

- **File Explorer**: Navigate your project structure
- **Code Editor**: Edit files with syntax highlighting
- **AI Assistant**: Get help with your code
- **Markdown Support**: Write documentation

## Quick Start

1. Open your project folder
2. Navigate files using the file explorer
3. Click on files to open them in tabs
4. Start editing!

## Code Example

```dart
void main() {
  print("Hello, NovaSpec!");
}
```

For more information, visit our [website](https://novaspec.example.com).''';
      default:
        return '// ${widget.tab.title}\n\n// Start editing your file here...\n// This is a placeholder editor\n// Monaco Editor integration coming soon!\n';
    }
  }
}
