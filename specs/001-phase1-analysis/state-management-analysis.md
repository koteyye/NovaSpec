# State Management Analysis: React/TypeScript → Flutter/Dart

## Обзор

Анализ паттернов управления состоянием в TypeScript проекте и их эквиваленты во Flutter. Проект использует простые паттерны с локальным состоянием и минимальным глобальным состоянием.

## 1. Текущее состояние в TypeScript проекте

### 1.1 Локальное состояние (useState)

#### AIAssistant.tsx
```typescript
const [selectedModel, setSelectedModel] = useState("GPT-5");
const [inputValue, setInputValue] = useState("");
const [isCollapsed, setIsCollapsed] = useState(false);
const [showHistory, setShowHistory] = useState(false);
const [currentMessages, setCurrentMessages] = useState<Message[]>(mockMessages);
const [showFileMenu, setShowFileMenu] = useState(false);
const [fileMenuPosition, setFileMenuPosition] = useState({ top: 0, left: 0 });
const [cursorPosition, setCursorPosition] = useState(0);
const [mode, setMode] = useState<"chat" | "template">("chat");
const [selectedTemplate, setSelectedTemplate] = useState("Базовый шаблон ТЗ");
const [showProposedChanges, setShowProposedChanges] = useState(false);
```

#### FileExplorer.tsx
```typescript
const FileTreeItem = ({ node, depth = 0 }: { node: FileNode; depth?: number }) => {
  const [expanded, setExpanded] = useState(depth === 0);
```

#### SpecPreview.tsx
```typescript
const [editMode, setEditMode] = useState(false);
```

#### TextEditor.tsx
```typescript
const [content, setContent] = useState(initialContent);
```

### 1.2 Мемоизация (useMemo, useCallback)

#### SpecPreview.tsx
```typescript
const fileContent = useMemo(() => {
  if (!activeFileObj) return "";
  
  switch (activeFileObj.path) {
    case "/api_openapi.json":
      return mockOpenAPIJson;
    case "/api_openapi.yaml":
      return mockOpenAPIYaml;
    default:
      return "";
  }
}, [activeFileObj]);

const isOpenAPI = useMemo(() => {
  if (!activeFileObj || !['json', 'yaml'].includes(activeFileObj.type)) return false;
  return isOpenAPISpec(fileContent);
}, [activeFileObj, fileContent]);
```

### 1.3 Refs (useRef)

#### AIAssistant.tsx
```typescript
const textareaRef = useRef<HTMLTextAreaElement>(null);

const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
  const value = e.target.value;
  const cursorPos = e.target.selectionStart;
  
  setInputValue(value);
  setCursorPosition(cursorPos);
  
  // Check for @ symbol
  const lastAtIndex = value.lastIndexOf("@", cursorPos - 1);
  if (lastAtIndex !== -1 && lastAtIndex === cursorPos - 1) {
    const rect = e.target.getBoundingClientRect();
    setFileMenuPosition({ top: rect.top, left: rect.left });
    setShowFileMenu(true);
  } else {
    setShowFileMenu(false);
  }
};
```

### 1.4 Пропсы для передачи состояния

#### AIAssistant.tsx
```typescript
interface AIAssistantProps {
  onOpenFile?: (path: string) => void;
}

export const AIAssistant = ({ onOpenFile }: AIAssistantProps) => {
  // Component implementation
};
```

#### SpecPreview.tsx
```typescript
interface SpecPreviewProps {
  musicActive?: boolean;
  openFiles?: { name: string; path: string; type: string }[];
  activeFile?: string;
  onFileChange?: (path: string) => void;
  onMusicify?: () => void;
}

export const SpecPreview = ({ 
  musicActive = false, 
  openFiles = [{ name: "spec_v1.md", path: "/spec_v1.md", type: "md" }],
  activeFile = "/spec_v1.md",
  onFileChange,
  onMusicify
}: SpecPreviewProps) => {
  // Component implementation
};
```

### 1.5 Мок данные (статическое состояние)

#### AIAssistant.tsx
```typescript
const mockMessages: Message[] = [
  { role: "user", content: "Добавь раздел про уведомления" },
  {
    role: "assistant",
    content: "Добавляю раздел про уведомления в техническое задание.",
  },
  { role: "user", content: "Добавь также информацию про push-уведомления" },
  {
    role: "assistant",
    content: "Раздел обновлен. Добавлено описание push-уведомлений.",
  },
];

const mockChatHistory: ChatHistory[] = [
  { id: "1", title: "Уведомления / Push / Настройки", messages: mockMessages },
  { id: "2", title: "Архитектура / Backend / API", messages: [] },
  { id: "3", title: "UI/UX / Дизайн / Компоненты", messages: [] },
];

const mockFiles: FileReference[] = [
  { name: "spec_v1.md", path: "/spec_v1.md" },
  { name: "spec_v2.html", path: "/spec_v2.html" },
  { name: "requirements.json", path: "/requirements.json" },
];
```

## 2. Анализ паттернов состояния

### 2.1 Типы состояния

#### Локальное состояние компонента
- **Формы ввода:** текстовые поля, селекты
- **UI состояние:** раскрытые/свернутые элементы, активные табы
- **Временное состояние:** позиции меню, видимость попапов

#### Состояние приложения
- **Активные файлы:** открытые файлы, текущий файл
- **Настройки:** выбранная модель, тема, интеграции
- **Данные:** сообщения чата, история, файловая система

#### Состояние UI
- **Навигация:** текущая страница, история
- **Модальные окна:** открытые диалоги
- **Загрузка:** индикаторы загрузки

### 2.2 Потоки данных

#### Нисходящий поток (Props)
```typescript
// Родительский компонент
<App>
  <TopBar 
    aiProvider={aiProvider}
    atlassianActive={atlassianActive}
    musicActive={musicActive}
  />
  <FileExplorer />
  <SpecPreview 
    activeFile={activeFile}
    onFileChange={handleFileChange}
  />
  <AIAssistant onOpenFile={handleOpenFile} />
</App>
```

#### Восходящий поток (Callbacks)
```typescript
// Дочерний компонент сообщает родителю
const handleFileSelect = (file: FileReference) => {
  onOpenFile?.(file.path);
};
```

### 2.3 Обработка побочных эффектов

#### Загрузка данных
```typescript
useEffect(() => {
  // Component did mount
  loadInitialData();
  
  return () => {
    // Component will unmount
    cleanup();
  };
}, [dependency]);
```

## 3. Flutter эквиваленты

### 3.1 StatefulWidget для локального состояния

#### AIAssistant → StatefulWidget
```dart
class AIAssistant extends StatefulWidget {
  final Function(String)? onOpenFile;
  
  const AIAssistant({Key? key, this.onOpenFile}) : super(key: key);
  
  @override
  _AIAssistantState createState() => _AIAssistantState();
}

class _AIAssistantState extends State<AIAssistant> {
  String selectedModel = "GPT-5";
  String inputValue = "";
  bool isCollapsed = false;
  bool showHistory = false;
  List<Message> currentMessages = [];
  bool showFileMenu = false;
  Offset fileMenuPosition = Offset.zero;
  int cursorPosition = 0;
  ChatMode mode = ChatMode.chat;
  String selectedTemplate = "Базовый шаблон ТЗ";
  bool showProposedChanges = false;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    currentMessages = mockMessages;
    _textController.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _handleTextChange() {
    final value = _textController.text;
    final cursorPos = _textController.selection.start;
    
    setState(() {
      inputValue = value;
      cursorPosition = cursorPos;
    });
    
    // Check for @ symbol
    final lastAtIndex = value.lastIndexOf("@", cursorPos - 1);
    if (lastAtIndex != -1 && lastAtIndex == cursorPos - 1) {
      // Get cursor position
      final renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      
      setState(() {
        fileMenuPosition = position;
        showFileMenu = true;
      });
    } else {
      setState(() {
        showFileMenu = false;
      });
    }
  }
  
  void _handleFocusChange() {
    // Handle focus changes
  }
  
  void _handleFileSelect(FileReference file) {
    final beforeAt = inputValue.substring(0, inputValue.lastIndexOf("@"));
    final afterCursor = inputValue.substring(cursorPosition);
    
    setState(() {
      inputValue = "$beforeAt@${file.name} $afterCursor";
      showFileMenu = false;
    });
    
    _textController.text = inputValue;
    _textController.selection = TextSelection.collapsed(offset: inputValue.length);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 384,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
          _buildInputArea(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    // Header implementation
  }
  
  Widget _buildContent() {
    // Content implementation
  }
  
  Widget _buildInputArea() {
    return Column(
      children: [
        _buildActionButtons(),
        _buildModelSelector(),
        _buildTextInput(),
      ],
    );
  }
}
```

### 3.2 Provider для глобального состояния

#### AppState с Provider
```dart
// Модели состояния
class AppState extends ChangeNotifier {
  // AI Assistant состояние
  String _selectedModel = "GPT-5";
  List<ChatHistory> _chatHistory = [];
  List<FileReference> _recentFiles = [];
  
  // File Explorer состояние
  List<FileNode> _fileTree = [];
  String? _selectedFile;
  
  // Spec Preview состояние
  List<OpenFile> _openFiles = [];
  String? _activeFile;
  bool _editMode = false;
  
  // Settings состояние
  bool _musicActive = false;
  bool _atlassianActive = false;
  String _musicGenre = "Pop";
  double _musicBalance = 0.0;
  
  // Getters
  String get selectedModel => _selectedModel;
  List<ChatHistory> get chatHistory => _chatHistory;
  List<FileReference> get recentFiles => _recentFiles;
  List<FileNode> get fileTree => _fileTree;
  String? get selectedFile => _selectedFile;
  List<OpenFile> get openFiles => _openFiles;
  String? get activeFile => _activeFile;
  bool get editMode => _editMode;
  bool get musicActive => _musicActive;
  bool get atlassianActive => _atlassianActive;
  String get musicGenre => _musicGenre;
  double get musicBalance => _musicBalance;
  
  // AI Assistant методы
  void setSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }
  
  void addChatMessage(String role, String content) {
    // Добавление сообщения в текущий чат
    notifyListeners();
  }
  
  void createNewChat(String title) {
    _chatHistory.add(ChatHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      messages: [],
    ));
    notifyListeners();
  }
  
  // File Explorer методы
  void setFileTree(List<FileNode> tree) {
    _fileTree = tree;
    notifyListeners();
  }
  
  void selectFile(String? filePath) {
    _selectedFile = filePath;
    notifyListeners();
  }
  
  // Spec Preview методы
  void openFile(String name, String path, String type) {
    final openFile = OpenFile(name: name, path: path, type: type);
    _openFiles.add(openFile);
    _activeFile = path;
    notifyListeners();
  }
  
  void closeFile(String path) {
    _openFiles.removeWhere((file) => file.path == path);
    if (_activeFile == path) {
      _activeFile = _openFiles.isNotEmpty ? _openFiles.last.path : null;
    }
    notifyListeners();
  }
  
  void setActiveFile(String? path) {
    _activeFile = path;
    notifyListeners();
  }
  
  void toggleEditMode() {
    _editMode = !_editMode;
    notifyListeners();
  }
  
  // Settings методы
  void toggleMusic() {
    _musicActive = !_musicActive;
    notifyListeners();
  }
  
  void toggleAtlassian() {
    _atlassianActive = !_atlassianActive;
    notifyListeners();
  }
  
  void setMusicGenre(String genre) {
    _musicGenre = genre;
    notifyListeners();
  }
  
  void setMusicBalance(double balance) {
    _musicBalance = balance;
    notifyListeners();
  }
}

// Модели данных
class Message {
  final String role;
  final String content;
  
  Message({required this.role, required this.content});
}

class ChatHistory {
  final String id;
  final String title;
  final List<Message> messages;
  
  ChatHistory({
    required this.id,
    required this.title,
    required this.messages,
  });
}

class FileReference {
  final String name;
  final String path;
  
  FileReference({required this.name, required this.path});
}

class OpenFile {
  final String name;
  final String path;
  final String type;
  
  OpenFile({
    required this.name,
    required this.path,
    required this.type,
  });
}

enum ChatMode { chat, template }
```

### 3.3 Использование Provider в приложении

#### Main.dart с Provider
```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        // Другие провайдеры
      ],
      child: NovaSpecApp(),
    ),
  );
}

class NovaSpecApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'NovaSpec',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MainScreen(),
          routes: {
            '/settings': (context) => SettingsScreen(),
            '/templates': (context) => TemplatesScreen(),
          },
        );
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: Row(
            children: [
              FileExplorer(),
              Expanded(
                child: SpecPreview(
                  activeFile: appState.activeFile,
                  openFiles: appState.openFiles,
                  onFileChange: (path) => appState.setActiveFile(path),
                ),
              ),
              AIAssistant(
                onOpenFile: (path) {
                  // Открыть файл в SpecPreview
                  appState.openFile(
                    path.split('/').last,
                    path,
                    path.split('.').last,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 3.4 Оптимизация с Selector

#### Selector для избирательных обновлений
```dart
class AIAssistantHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, String>(
      selector: (context, appState) => appState.selectedModel,
      builder: (context, selectedModel, child) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Text('Model: $selectedModel'),
        );
      },
    );
  }
}

class FileExplorerTree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<AppState, List<FileNode>>(
      selector: (context, appState) => appState.fileTree,
      builder: (context, fileTree, child) {
        return ListView.builder(
          itemCount: fileTree.length,
          itemBuilder: (context, index) {
            return FileTreeItem(node: fileTree[index]);
          },
        );
      },
    );
  }
}
```

## 4. Сравнение паттернов

### 4.1 Локальное состояние

| React/TypeScript | Flutter/Dart | Преимущества | Недостатки |
|------------------|--------------|--------------|------------|
| `useState` | `StatefulWidget` | Простота | Более много кода |
| `useRef` | `TextEditingController`, `FocusNode` | Прямой доступ | Ручное управление |
| `useMemo` | Кэширование в полях | Оптимизация | Ручная инвалидация |
| `useCallback` | Методы класса | Стабильные ссылки | Больше памяти |

### 4.2 Глобальное состояние

| React/TypeScript | Flutter/Dart | Преимущества | Недостатки |
|------------------|--------------|--------------|------------|
| Props drilling | Provider | Избегает drilling | Больше кода |
| Context API | Provider | Автоматические обновления | Learning curve |
| useState + callbacks | ChangeNotifier | Простота | Ручные notifyListeners |

### 4.3 Обработка побочных эффектов

| React/TypeScript | Flutter/Dart | Преимущества | Недостатки |
|------------------|--------------|--------------|------------|
| `useEffect` | `initState/didUpdate/dispose` | Декларативно | Больше методов |
| Cleanup function | `dispose` | Автоматическая очистка | Ручное управление |

## 5. Рекомендации по миграции

### 5.1 Стратегия миграции состояния

#### Фаза 1: Локальное состояние
1. **StatefulWidget** для компонентов с состоянием
2. **TextEditingController** для полей ввода
3. **FocusNode** для управления фокусом

#### Фаза 2: Глобальное состояние
1. **Provider** для AppState
2. **ChangeNotifier** для управления состоянием
3. **Selector** для оптимизации

#### Фаза 3: Оптимизация
1. **Кэширование** вычислений
2. **Избирательные обновления** с Selector
3. **Разделение** состояния по доменам

### 5.2 Лучшие практики

#### Разделение состояния
```dart
// Разделить AppState на домены
class AIAssistantState extends ChangeNotifier { ... }
class FileExplorerState extends ChangeNotifier { ... }
class SpecPreviewState extends ChangeNotifier { ... }
class SettingsState extends ChangeNotifier { ... }

// Комбинированный AppState
class AppState extends ChangeNotifier {
  final AIAssistantState aiAssistant = AIAssistantState();
  final FileExplorerState fileExplorer = FileExplorerState();
  final SpecPreviewState specPreview = SpecPreviewState();
  final SettingsState settings = SettingsState();
}
```

#### Immutable модели
```dart
@immutable
class Message {
  final String role;
  final String content;
  
  const Message({required this.role, required this.content});
  
  Message copyWith({String? role, String? content}) {
    return Message(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message &&
        other.role == role &&
        other.content == content;
  }
  
  @override
  int get hashCode => role.hashCode ^ content.hashCode;
}
```

#### Обработка ошибок
```dart
class AppState extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> loadFiles() async {
    try {
      setError(null);
      // Загрузка файлов
      final files = await fileService.loadFiles();
      setFileTree(files);
    } catch (e) {
      setError('Failed to load files: $e');
    }
  }
}
```

### 5.3 Тестирование состояния

#### Unit тесты для ChangeNotifier
```dart
void main() {
  group('AppState', () {
    late AppState appState;
    
    setUp(() {
      appState = AppState();
    });
    
    test('should set selected model', () {
      appState.setSelectedModel('GPT-4');
      
      expect(appState.selectedModel, 'GPT-4');
    });
    
    test('should add chat message', () {
      appState.addChatMessage('user', 'Hello');
      
      expect(appState.currentMessages.last.role, 'user');
      expect(appState.currentMessages.last.content, 'Hello');
    });
    
    test('should notify listeners', () {
      var notified = false;
      appState.addListener(() => notified = true);
      
      appState.setSelectedModel('GPT-4');
      
      expect(notified, true);
    });
  });
}
```

## 6. Заключение

### Ключевые выводы
1. **Простота текущего состояния** - в основном локальное состояние
2. **Provider подходит** для глобального состояния
3. **StatefulWidget** для компонентов с состоянием
4. **Оптимизация через Selector** для производительности

### Приоритеты миграции
1. **Создать AppState** с ChangeNotifier
2. **Мигрировать AIAssistant** как StatefulWidget
3. **Добавить Provider** в main.dart
4. **Оптимизировать** с Selector
5. **Добавить тесты** для состояния

### Оценка трудозатрат
- **AppState**: 8-12 часов
- **StatefulWidget миграция**: 16-24 часа
- **Provider интеграция**: 4-8 часов
- **Оптимизация**: 8-12 часов
- **Тестирование**: 12-16 часов

**Итого:** 48-72 часов на миграцию состояния