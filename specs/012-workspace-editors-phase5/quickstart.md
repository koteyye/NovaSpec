# Quickstart Guide: File Format Support Implementation

**Feature**: File Format Support and Viewers  
**Branch**: `012-workspace-editors-phase5`  
**Date**: 2025-11-01  

## 🚀 Quick Start

Этот гайд поможет быстро начать реализацию поддержки форматов файлов в NovaSpec.

## 📋 Prerequisites

1. **Switch to branch**:
   ```bash
   git checkout 012-workspace-editors-phase5
   ```

2. **Verify dependencies** in `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_markdown: ^0.6.18
     flutter_html: ^3.0.0-beta.2
     audioplayers: ^5.2.1
     webview_flutter: ^4.4.2
     yaml: ^3.1.2
     shelf: ^1.4.1
     shelf_static: ^1.1.2
   ```

3. **Run flutter pub get**:
   ```bash
   flutter pub get
   ```

## 🏗️ Implementation Order

### Phase 1: Core Models & Services (Day 1-2)

1. **Create base models**:
   ```bash
   # Create models directory
   mkdir -p lib/features/workspace/models
   
   # Create core models
   touch lib/features/workspace/models/workspace_file.dart
   touch lib/features/workspace/models/audio_player_state.dart
   touch lib/features/workspace/models/openapi_spec.dart
   ```

2. **Create services directory**:
   ```bash
   mkdir -p lib/features/workspace/services
   
   # Create core services
   touch lib/features/workspace/services/markdown_service.dart
   touch lib/features/workspace/services/audio_service.dart
   touch lib/features/workspace/services/openapi_service.dart
   touch lib/features/workspace/services/swagger_server_service.dart
   ```

3. **Implement models** following `contracts/workspace-viewers-api.md`

### Phase 2: Viewer Components (Day 3-4)

1. **Create viewers directory**:
   ```bash
   mkdir -p lib/features/workspace/viewers
   ```

2. **Create viewer components**:
   ```bash
   touch lib/features/workspace/viewers/markdown_viewer.dart
   touch lib/features/workspace/viewers/html_viewer.dart
   touch lib/features/workspace/viewers/audio_player.dart
   touch lib/features/workspace/viewers/swagger_viewer.dart
   touch lib/features/workspace/viewers/code_editor.dart
   ```

3. **Implement each viewer** using existing UI components from `lib/shared/widgets/`

### Phase 3: Integration (Day 5)

1. **Update workspace provider** to integrate new viewers
2. **Add file type detection** logic
3. **Implement viewer switching** mechanism
4. **Add error handling** with ModernToast

## 📁 File Templates

### Model Template

```dart
// lib/features/workspace/models/workspace_file.dart
import 'dart:io';

class WorkspaceFile {
  final String id;
  final String name;
  final String path;
  final String extension;
  final int size;
  final DateTime lastModified;
  final FileType type;
  final Map<String, dynamic>? metadata;

  const WorkspaceFile({
    required this.id,
    required this.name,
    required this.path,
    required this.extension,
    required this.size,
    required this.lastModified,
    required this.type,
    this.metadata,
  });

  factory WorkspaceFile.fromFile(File file) {
    // Implementation
  }

  Future<String> readContent() async {
    // Implementation
  }

  Future<void> saveContent(String content) async {
    // Implementation
  }

  bool isSupported() {
    // Check against supported extensions
  }
}
```

### Service Template

```dart
// lib/features/workspace/services/markdown_service.dart
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownService {
  Future<String> parseMarkdown(String content) async {
    // Parse and validate markdown
  }

  Future<String> loadFromFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    return await file.readAsString();
  }

  Future<void> saveToFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  bool isValidMarkdownFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['.md', '.markdown'].contains(extension);
  }
}
```

### Viewer Template

```dart
// lib/features/workspace/viewers/markdown_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/markdown_service.dart';
import '../../../shared/widgets/modern_toast.dart';

class MarkdownViewer extends StatefulWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const MarkdownViewer({
    Key? key,
    required this.filePath,
    this.onContentChanged,
  }) : super(key: key);

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  final MarkdownService _markdownService = MarkdownService();
  String _content = '';
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    setState(() => _isLoading = true);
    try {
      final content = await _markdownService.loadFromFile(widget.filePath);
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ModernToast.showError('Ошибка загрузки файла: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isEditing) {
      return _buildEditor();
    } else {
      return _buildViewer();
    }
  }

  Widget _buildViewer() {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: Markdown(
            data: _content,
            selectable: true,
          ),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: _content),
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (value) {
              _content = value;
              widget.onContentChanged?.call(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ModernButton(
            text: _isEditing ? 'Просмотр' : 'Редактировать',
            type: ButtonType.secondary,
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
          const SizedBox(width: 8),
          if (_isEditing) ...[
            ModernButton(
              text: 'Сохранить',
              type: ButtonType.primary,
              onPressed: _saveFile,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveFile() async {
    try {
      await _markdownService.saveToFile(widget.filePath, _content);
      ModernToast.showSuccess('Файл сохранен');
      setState(() => _isEditing = false);
    } catch (e) {
      ModernToast.showError('Ошибка сохранения: ${e.toString()}');
    }
  }
}
```

## 🔧 Key Implementation Points

### 1. Use Existing UI Components

```dart
// ✅ Correct - use existing components
ModernButton(
  text: 'Play',
  type: ButtonType.primary,
  onPressed: _playAudio,
)

// ❌ Wrong - don't use standard Flutter buttons
ElevatedButton(
  onPressed: _playAudio,
  child: Text('Play'),
)
```

### 2. Error Handling with ModernToast

```dart
try {
  await _service.loadFile();
  ModernToast.showSuccess('Файл загружен');
} catch (e) {
  ModernToast.showError('Ошибка: ${e.toString()}');
}
```

### 3. Provider Integration

```dart
// Update workspace provider to handle new viewers
class WorkspaceProvider extends ChangeNotifier {
  FileViewer? _currentViewer;
  
  FileViewer? get currentViewer => _currentViewer;
  
  Future<void> openFile(String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'md':
      case 'markdown':
        _currentViewer = MarkdownViewer(filePath: filePath);
        break;
      case 'html':
        _currentViewer = HtmlViewer(filePath: filePath);
        break;
      case 'mp3':
      case 'wav':
        _currentViewer = AudioPlayer(filePath: filePath);
        break;
      // ... other cases
    }
    
    notifyListeners();
  }
}
```

## 🧪 Testing Checklist

### Manual Testing Requirements

- [ ] Markdown files load and render correctly
- [ ] Markdown editing mode works
- [ ] HTML files display properly
- [ ] Audio playback controls function
- [ ] Swagger UI loads for OpenAPI specs
- [ ] Code editor opens for code files
- [ ] Error handling shows appropriate toasts
- [ ] File switching works smoothly

### Performance Testing

- [ ] Large markdown files (>1MB) load in <500ms
- [ ] Audio files start playing in <2s
- [ ] Swagger UI loads in <3s
- [ ] Memory usage stays within limits

## 🐛 Common Issues & Solutions

### Issue: Markdown not rendering
**Solution**: Check flutter_markdown dependency and ensure content is properly encoded

### Issue: Audio not playing
**Solution**: Verify audioplayers dependency and file format support

### Issue: Swagger UI not loading
**Solution**: Verify background server starts on app launch and webview_flutter integration

### Issue: Memory leaks
**Solution**: Ensure proper disposal of controllers and services

## 📚 Additional Resources

- [Flutter Markdown Documentation](https://pub.dev/packages/flutter_markdown)
- [Flutter HTML Documentation](https://pub.dev/packages/flutter_html)
- [Audio Players Documentation](https://pub.dev/packages/audioplayers)
- [WebView Flutter Documentation](https://pub.dev/packages/webview_flutter)

## 🎯 Next Steps

1. Implement Phase 1 (Models & Services)
2. Implement Phase 2 (Viewer Components)
3. Integrate with existing workspace
4. Test all file formats
5. Update documentation

---

**Need Help?** Check the full specification in `spec.md` or contracts in `contracts/` directory.