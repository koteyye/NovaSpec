# Руководство по миграции NovaSpec: TypeScript → Flutter

**Дата**: 2025-10-19  
**Версия**: 1.0  
**Цель**: Комплексное руководство для миграции UI компонентов TypeScript/React на Flutter/Dart

## Обзор

NovaSpec - приложение для создания технических заданий с ИИ-ассистентом. Текущая реализация на TypeScript/React требует полной миграции на Flutter/Dart для поддержки кроссплатформенности.

### Технологический стек

**Исходный (TypeScript/React)**:
- React 18 с TypeScript
- Tailwind CSS для стилизации
- shadcn/ui компоненты
- React Context для состояния
- Monaco Editor для редактирования кода
- Swagger UI для документации API

**Целевой (Flutter/Dart)**:
- Flutter 3.x с Dart 3.x
- Material Design 3
- Provider для состояния
- monaco_editor пакет
- webview_flutter для Swagger UI

## Карта миграции компонентов

### Базовые UI компоненты

| TypeScript | Flutter | Пакет | Сложность | Пример |
|------------|---------|-------|-----------|--------|
| Button | ElevatedButton/TextButton | Material | LOW | `ElevatedButton(onPressed: () {}, child: Text('Click'))` |
| Input | TextField | Material | LOW | `TextField(decoration: InputDecoration(labelText: 'Name'))` |
| Select | DropdownButton | Material | MEDIUM | `DropdownButton(items: [], onChanged: (value) {})` |
| Checkbox | Checkbox | Material | LOW | `Checkbox(value: true, onChanged: (value) {})` |
| Radio | Radio | Material | LOW | `Radio(value: true, groupValue: true, onChanged: (value) {})` |
| Switch | Switch | Material | LOW | `Switch(value: true, onChanged: (value) {})` |
| Slider | Slider | Material | LOW | `Slider(value: 0.5, onChanged: (value) {})` |
| Progress | CircularProgressIndicator | Material | LOW | `CircularProgressIndicator()` |
| Alert | AlertDialog | Material | LOW | `AlertDialog(title: Text('Alert'))` |
| Modal | showModalBottomSheet | Material | MEDIUM | `showModalBottomSheet(context: context, builder: (_) => Container())` |
| Tooltip | Tooltip | Material | LOW | `Tooltip(message: 'Help', child: Icon(Icons.info))` |
| Badge | Badge | badges | MEDIUM | `Badge(badgeContent: Text('1'), child: Icon(Icons.notifications))` |
| Avatar | CircleAvatar | Material | LOW | `CircleAvatar(child: Text('A'))` |
| Card | Card | Material | LOW | `Card(child: ListTile(title: Text('Title')))` |
| Divider | Divider | Material | LOW | `Divider()` |
| Spacer | SizedBox | Material | LOW | `SizedBox(height: 16)` |
| Grid | GridView | Material | MEDIUM | `GridView.count(crossAxisCount: 2, children: [])` |
| List | ListView | Material | MEDIUM | `ListView(children: [])` |

### shadcn/ui компоненты

| TypeScript shadcn/ui | Flutter эквивалент | Пакет | Сложность |
|----------------------|-------------------|-------|-----------|
| Accordion | ExpansionPanelList | Material | MEDIUM |
| Alert | AlertDialog/SnackBar | Material | LOW |
| Avatar | CircleAvatar | Material | LOW |
| Badge | Badge | badges | MEDIUM |
| Button | ElevatedButton/TextButton/OutlinedButton | Material | LOW |
| Calendar | showDatePicker | Material | HIGH |
| Card | Card | Material | LOW |
| Checkbox | Checkbox | Material | LOW |
| Collapsible | ExpansionTile | Material | MEDIUM |
| Command | Custom Widget | - | HIGH |
| Context Menu | PopupMenuButton | Material | MEDIUM |
| Dialog | AlertDialog | Material | LOW |
| Dropdown Menu | DropdownButton | Material | MEDIUM |
| Form | Form | Material | MEDIUM |
| Hover Card | Card + InkWell | Material | MEDIUM |
| Input | TextField | Material | LOW |
| Label | Text | Material | LOW |
| Menubar | AppBar | Material | MEDIUM |
| Navigation Menu | BottomNavigationBar | Material | MEDIUM |
| Popover | PopupMenuButton | Material | MEDIUM |
| Progress | CircularProgressIndicator/LinearProgressIndicator | Material | LOW |
| Radio Group | RadioListTile | Material | MEDIUM |
| Scroll Area | SingleChildScrollView | Material | LOW |
| Select | DropdownButton | Material | MEDIUM |
| Separator | Divider | Material | LOW |
| Sheet | showModalBottomSheet | Material | MEDIUM |
| Skeleton | Shimmer | shimmer | MEDIUM |
| Slider | Slider | Material | LOW |
| Switch | Switch | Material | LOW |
| Table | DataTable | Material | MEDIUM |
| Tabs | TabBar | Material | MEDIUM |
| Textarea | TextField + maxLines | Material | LOW |
| Toast | SnackBar | Material | LOW |
| Toggle | Switch | Material | LOW |

### Сложные компоненты NovaSpec

| TypeScript | Flutter подход | Сложность | Оценка времени | Ключевые зависимости |
|------------|----------------|-----------|---------------|-------------------|
| AIAssistant | Custom Widget + Monaco Editor | HIGH | 40-60 часов | monaco_editor, provider |
| FileExplorer | Custom Widget + TreeView | MEDIUM | 24-36 часов | file_picker, provider |
| TextEditor | Monaco Editor | HIGH | 32-48 часов | monaco_editor |
| TopBar | AppBar + Custom Actions | MEDIUM | 16-24 часов | Material |
| SpecPreview | Custom Widget + Markdown | MEDIUM | 24-36 часов | flutter_markdown |
| StatusBar | BottomAppBar | LOW | 8-12 часов | Material |

## Архитектурные паттерны

### MVVM в Flutter

```dart
// Model
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// ViewModel
class UserViewModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await ApiService.getUser(userId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// View
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserViewModel(),
      child: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return CircularProgressIndicator();
          }
          
          return Column(
            children: [
              Text(viewModel.user?.name ?? 'No user'),
              ElevatedButton(
                onPressed: () => viewModel.loadUser('123'),
                child: Text('Load User'),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### Управление состоянием

**React Context → Flutter Provider**:

```typescript
// React Context
const ThemeContext = createContext({
  theme: 'light',
  toggleTheme: () => {},
});

function App() {
  const [theme, setTheme] = useState('light');
  
  return (
    <ThemeContext.Provider value={{ theme, toggleTheme: () => setTheme(theme === 'light' ? 'dark' : 'light') }}>
      {/* Components */}
    </ThemeContext.Provider>
  );
}
```

```dart
// Flutter Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}
```

## Стили и темы

### Tailwind CSS → Material Design 3

**Tailwind классы → Material свойства**:

```typescript
// Tailwind CSS
<div className="bg-purple-600 text-white p-4 rounded-lg shadow-lg">
  <h1 className="text-xl font-bold">NovaSpec</h1>
</div>
```

```dart
// Flutter Material 3
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primary,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  child: Text(
    'NovaSpec',
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Цветовая схема MTS Granat

```dart
class AppTheme {
  static const Color primaryColor = Color(0xFF6B46C1); // MTS Granat фиолетовый
  static const Color secondaryColor = Color(0xFF10B981); // MTS зеленый
  static const Color accentColor = Color(0xFFF59E0B); // MTS желтый
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      // ... другие настройки
    );
  }
}
```

## Примеры миграции ключевых компонентов

### 1. Кнопка (Button)

**TypeScript/React**:
```typescript
import { Button } from "@/components/ui/button";

function SaveButton() {
  return (
    <Button onClick={handleSave} className="bg-purple-600 hover:bg-purple-700">
      Save Document
    </Button>
  );
}
```

**Flutter/Dart**:
```dart
class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const SaveButton({Key? key, required this.onPressed}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text('Save Document'),
    );
  }
}
```

### 2. Поле ввода (Input)

**TypeScript/React**:
```typescript
import { Input } from "@/components/ui/input";

function NameInput() {
  const [name, setName] = useState('');
  
  return (
    <Input
      value={name}
      onChange={(e) => setName(e.target.value)}
      placeholder="Enter your name"
      className="border-gray-300 focus:border-purple-500"
    />
  );
}
```

**Flutter/Dart**:
```dart
class NameInput extends StatefulWidget {
  @override
  _NameInputState createState() => _NameInputState();
}

class _NameInputState extends State<NameInput> {
  String _name = '';
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      value: _name,
      onChanged: (value) => setState(() => _name = value),
      decoration: InputDecoration(
        labelText: 'Enter your name',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
```

### 3. Диалог (Dialog)

**TypeScript/React**:
```typescript
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

function ConfirmDialog({ open, onConfirm, onCancel }) {
  return (
    <Dialog open={open}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Confirm Action</DialogTitle>
        </DialogHeader>
        <p>Are you sure you want to delete this item?</p>
        <div className="flex justify-end space-x-2">
          <Button variant="outline" onClick={onCancel}>Cancel</Button>
          <Button onClick={onConfirm}>Delete</Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
```

**Flutter/Dart**:
```dart
class ConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  
  const ConfirmDialog({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Action'),
      content: Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text('Delete'),
        ),
      ],
    );
  }
}

// Использование
void showConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => ConfirmDialog(
      onConfirm: () {
        Navigator.of(context).pop();
        // Выполнить удаление
      },
      onCancel: () => Navigator.of(context).pop(),
    ),
  );
}
```

## Интеграция Monaco Editor

**TypeScript/React**:
```typescript
import { Editor } from "@monaco-editor/react";

function CodeEditor() {
  return (
    <Editor
      height="400px"
      defaultLanguage="typescript"
      defaultValue="// Your code here"
      theme="vs-dark"
    />
  );
}
```

**Flutter/Dart**:
```dart
import 'package:monaco_editor/monaco_editor.dart';

class CodeEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: MonacoEditor(
        language: 'typescript',
        theme: 'vs-dark',
        code: '// Your code here',
        onChanged: (value) {
          // Handle code changes
        },
      ),
    );
  }
}
```

## Интеграция WebView для Swagger UI

**TypeScript/React**:
```typescript
import SwaggerUI from "swagger-ui-react";

function ApiDocumentation() {
  return (
    <SwaggerUI url="/api/openapi.json" />
  );
}
```

**Flutter/Dart**:
```dart
import 'package:webview_flutter/webview_flutter.dart';

class ApiDocumentation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'http://localhost:8080/api/swagger-ui.html',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
```

## Лучшие практики

### 1. Структура проекта

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes/
│   │   └── app_routes.dart
│   └── themes/
│       └── app_theme.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── storage_service.dart
│   │   └── file_service.dart
│   └── utils/
│       └── helpers.dart
├── features/
│   ├── ai_assistant/
│   │   ├── views/
│   │   ├── viewmodels/
│   │   └── models/
│   ├── file_explorer/
│   │   ├── views/
│   │   ├── viewmodels/
│   │   └── models/
│   └── ...
├── shared/
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_widget.dart
│   └── models/
│       ├── component_model.dart
│       └── migration_model.dart
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_ru.dart
    └── app_localizations_en.dart
```

### 2. Обработка ошибок

```dart
class ApiService {
  static Future<T> handleRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Unknown error');
    } catch (e) {
      throw UnknownException('Unexpected error: $e');
    }
  }
}
```

### 3. Локализация

```dart
class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('ru'),
    Locale('en'),
  ];
  
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  
  // Использование
  String get appName => _localizedValues[locale.languageCode]!['appName']!;
}
```

### 4. Тестирование

```dart
// Widget тесты
void main() {
  testWidgets('SaveButton renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SaveButton(onPressed: () {}),
        ),
      ),
    );
    
    expect(find.text('Save Document'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}

// Unit тесты
void main() {
  group('UserViewModel', () {
    test('loadUser updates user state', () async {
      final viewModel = UserViewModel();
      
      await viewModel.loadUser('123');
      
      expect(viewModel.user, isNotNull);
      expect(viewModel.isLoading, false);
    });
  });
}
```

## Распространенные проблемы и решения

### 1. Проблема: Производительность при больших списках

**Решение**: Использовать `ListView.builder` вместо `Column` с `SingleChildScrollView`

```dart
// Плохо
Column(
  children: items.map((item) => ListTile(title: Text(item))).toList(),
)

// Хорошо
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ListTile(title: Text(items[index])),
)
```

### 2. Проблема: Утечки памяти

**Решение**: Правильно использовать `dispose()` и `ChangeNotifier`

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final StreamSubscription _subscription;
  
  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

### 3. Проблема: Навигация между экранами

**Решение**: Использовать именованные маршруты

```dart
// Определение маршрутов
class AppRoutes {
  static const String home = '/home';
  static const String settings = '/settings';
}

// Генерация маршрутов
static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => HomeScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => SettingsScreen());
    default:
      return MaterialPageRoute(builder: (_) => NotFoundScreen());
  }
}
```

## План миграции

### Фаза 1: Подготовка (1-2 недели)
- [ ] Настройка Flutter проекта
- [ ] Создание базовой архитектуры
- [ ] Интеграция зависимостей
- [ ] Настройка CI/CD

### Фаза 2: Базовые компоненты (2-3 недели)
- [ ] Миграция shadcn/ui компонентов
- [ ] Создание shared виджетов
- [ ] Настройка тем и стилей
- [ ] Локализация

### Фаза 3: Сложные компоненты (4-6 недель)
- [ ] AIAssistant с Monaco Editor
- [ ] FileExplorer с навигацией
- [ ] TextEditor с синтаксисом
- [ ] SpecPreview с Markdown

### Фаза 4: Интеграция (2-3 недели)
- [ ] API интеграция
- [ ] State management
- [ ] Тестирование
- [ ] Оптимизация

### Фаза 5: Завершение (1-2 недели)
- [ ] Финальное тестирование
- [ ] Документация
- [ ] Релиз

## Ресурсы

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)
- [Monaco Editor Flutter](https://pub.dev/packages/monaco_editor)
- [WebView Flutter](https://pub.dev/packages/webview_flutter)

---

**Итоговая оценка миграции**: 496-708 часов (2-3 Flutter разработчика, 3-4 месяца)