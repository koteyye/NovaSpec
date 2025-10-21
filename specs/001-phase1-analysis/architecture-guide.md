# Архитектурное руководство NovaSpec Flutter

**Дата**: 2025-10-19  
**Версия**: 1.0  
**Цель**: Детальное описание архитектуры Flutter приложения NovaSpec

## Обзор архитектуры

NovaSpec использует **MVVM (Model-View-ViewModel)** архитектурный паттерн с **Provider** для управления состоянием. Архитектура спроектирована для масштабируемости, тестируемости и поддержания кода.

### Ключевые принципы

1. **Разделение ответственности** - Каждый слой имеет четкую зону ответственности
2. **Dependency Injection** - Использование Provider для внедрения зависимостей
3. **Unidirectional Data Flow** - Однонаправленный поток данных
4. **Feature-based структура** - Организация кода по функциональным возможностям
5. **Testability** - Все компоненты спроектированы для легкого тестирования

## Структура проекта

```
lib/
├── main.dart                    # Точка входа
├── app/                         # App-level компоненты
│   ├── app.dart                 # Главный виджет приложения
│   ├── routes/                  # Навигация
│   │   └── app_routes.dart      # Определение маршрутов
│   └── themes/                  # Темы оформления
│       └── app_theme.dart       # Material Design 3 темы
├── core/                        # Базовая инфраструктура
│   ├── constants/               # Константы приложения
│   │   └── app_constants.dart   # Цвета, размеры, строки
│   ├── services/                # Глобальные сервисы
│   │   ├── api_service.dart     # HTTP клиент (dio)
│   │   ├── storage_service.dart # Локальное хранение
│   │   └── file_service.dart    # Файловые операции
│   └── utils/                   # Утилиты
│       └── helpers.dart         # Вспомогательные функции
├── features/                    # Функциональные модули
│   ├── onboarding/              # Онбординг
│   │   ├── views/               # UI экраны
│   │   │   └── onboarding_screen.dart
│   │   ├── viewmodels/          # ViewModel
│   │   │   └── onboarding_viewmodel.dart
│   │   └── models/              # Data модели
│   │       └── onboarding_model.dart
│   ├── project_management/      # Управление проектами
│   │   ├── views/
│   │   │   ├── project_list_screen.dart
│   │   │   └── project_detail_screen.dart
│   │   ├── viewmodels/
│   │   │   ├── project_list_viewmodel.dart
│   │   │   └── project_detail_viewmodel.dart
│   │   └── models/
│   │       ├── project_model.dart
│   │       └── task_model.dart
│   ├── ai_assistant/            # AI ассистент
│   │   ├── views/
│   │   │   └── ai_assistant_screen.dart
│   │   ├── viewmodels/
│   │   │   └── ai_assistant_viewmodel.dart
│   │   └── models/
│   │       ├── chat_message_model.dart
│   │       └── ai_response_model.dart
│   ├── file_explorer/           # Файловый менеджер
│   │   ├── views/
│   │   │   └── file_explorer_screen.dart
│   │   ├── viewmodels/
│   │   │   └── file_explorer_viewmodel.dart
│   │   └── models/
│   │       └── file_node_model.dart
│   ├── workspace/               # Рабочее пространство
│   │   ├── views/
│   │   │   └── workspace_screen.dart
│   │   ├── viewmodels/
│   │   │   └── workspace_viewmodel.dart
│   │   └── models/
│   │       └── workspace_model.dart
│   ├── settings/                # Настройки
│   │   ├── views/
│   │   │   └── settings_screen.dart
│   │   ├── viewmodels/
│   │   │   └── settings_viewmodel.dart
│   │   └── models/
│   │       └── settings_model.dart
│   └── templates/               # Шаблоны
│       ├── views/
│       │   └── templates_screen.dart
│       ├── viewmodels/
│       │   └── templates_viewmodel.dart
│       └── models/
│           └── template_model.dart
├── shared/                      # Shared компоненты
│   ├── widgets/                 # Переиспользуемые виджеты
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_widget.dart
│   │   └── error_widget.dart
│   └── models/                  # Shared модели
│       ├── component_model.dart
│       └── migration_model.dart
└── l10n/                        # Локализация
    ├── app_localizations.dart
    ├── app_localizations_ru.dart
    └── app_localizations_en.dart
```

## MVVM Паттерн

### Model (Модель)

**Ответственность**: Данные и бизнес-логика

```dart
// features/project_management/models/project_model.dart
class Project {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Task> tasks;
  final ProjectStatus status;
  
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.tasks,
    required this.status,
  });
  
  // Factory конструктор для JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tasks: (json['tasks'] as List)
          .map((task) => Task.fromJson(task as Map<String, dynamic>))
          .toList(),
      status: ProjectStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
      ),
    );
  }
  
  // Метод для сериализации
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'status': status.toString(),
    };
  }
  
  // Бизнес-логика
  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Task>? tasks,
    ProjectStatus? status,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
    );
  }
}

enum ProjectStatus {
  draft,
  active,
  completed,
  archived,
}
```

### ViewModel (Модель представления)

**Ответственность**: Состояние UI и логика представления

```dart
// features/project_management/viewmodels/project_list_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

class ProjectListViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;
  
  ProjectListViewModel({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;
  
  // State
  List<Project> _projects = [];
  List<Project> get projects => _projects;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  // Фильтры
  ProjectStatus? _statusFilter;
  ProjectStatus? get statusFilter => _statusFilter;
  
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  // Getters
  List<Project> get filteredProjects {
    var filtered = _projects;
    
    if (_statusFilter != null) {
      filtered = filtered.where((p) => p.status == _statusFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
  
  // Methods
  Future<void> loadProjects() async {
    _setLoading(true);
    _error = null;
    
    try {
      final projects = await _apiService.getProjects();
      _projects = projects;
      
      // Кэширование
      await _storageService.cacheProjects(projects);
      
    } catch (e) {
      _error = e.toString();
      
      // Попытка загрузить из кэша
      try {
        final cachedProjects = await _storageService.getCachedProjects();
        _projects = cachedProjects;
      } catch (_) {
        // Игнорируем ошибки кэша
      }
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> refreshProjects() async {
    await loadProjects();
  }
  
  Future<void> deleteProject(String projectId) async {
    try {
      await _apiService.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### View (Представление)

**Ответственность**: UI и взаимодействие с пользователем

```dart
// features/project_management/views/project_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/project_list_viewmodel.dart';
import '../models/project_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<ProjectListViewModel>().refreshProjects();
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<ProjectListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return LoadingWidget();
          }
          
          if (viewModel.error != null) {
            return ErrorWidget(
              message: viewModel.error!,
              onRetry: () => viewModel.loadProjects(),
            );
          }
          
          if (viewModel.filteredProjects.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return Column(
            children: [
              _buildSearchBar(context, viewModel),
              _buildFilterChips(context, viewModel),
              Expanded(
                child: _buildProjectList(context, viewModel),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateProject(context),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
  
  Widget _buildSearchBar(BuildContext context, ProjectListViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search projects...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: viewModel.setSearchQuery,
      ),
    );
  }
  
  Widget _buildFilterChips(BuildContext context, ProjectListViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: Text('All'),
            selected: viewModel.statusFilter == null,
            onSelected: (selected) => viewModel.setStatusFilter(null),
          ),
          ...ProjectStatus.values.map(
            (status) => FilterChip(
              label: Text(status.toString().split('.').last),
              selected: viewModel.statusFilter == status,
              onSelected: (selected) => 
                viewModel.setStatusFilter(selected ? status : null),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProjectList(BuildContext context, ProjectListViewModel viewModel) {
    return ListView.builder(
      itemCount: viewModel.filteredProjects.length,
      itemBuilder: (context, index) {
        final project = viewModel.filteredProjects[index];
        return ProjectCard(
          project: project,
          onTap: () => _navigateToProjectDetail(context, project.id),
          onDelete: () => _showDeleteConfirmation(context, project),
        );
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(height: 16),
          Text(
            'No projects found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Create your first project to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24),
          CustomButton(
            text: 'Create Project',
            onPressed: () => _navigateToCreateProject(context),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Projects'),
        content: Consumer<ProjectListViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Status:'),
                RadioListTile<ProjectStatus?>(
                  title: Text('All'),
                  value: null,
                  groupValue: viewModel.statusFilter,
                  onChanged: (value) {
                    viewModel.setStatusFilter(value);
                    Navigator.of(context).pop();
                  },
                ),
                ...ProjectStatus.values.map(
                  (status) => RadioListTile<ProjectStatus?>(
                    title: Text(status.toString().split('.').last),
                    value: status,
                    groupValue: viewModel.statusFilter,
                    onChanged: (value) {
                      viewModel.setStatusFilter(value);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  void _navigateToCreateProject(BuildContext context) {
    Navigator.of(context).pushNamed('/project/create');
  }
  
  void _navigateToProjectDetail(BuildContext context, String projectId) {
    Navigator.of(context).pushNamed('/project/detail', arguments: projectId);
  }
  
  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProjectListViewModel>().deleteProject(project.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  
  const ProjectCard({
    Key? key,
    required this.project,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(project.name),
        subtitle: Text(project.description),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                // Navigate to edit
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
```

## Dependency Injection с Provider

### Настройка Provider

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/file_service.dart';
import 'features/project_management/viewmodels/project_list_viewmodel.dart';
import 'features/ai_assistant/viewmodels/ai_assistant_viewmodel.dart';
import 'features/settings/viewmodels/settings_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация сервисов
  await StorageService.init();
  final apiService = ApiService();
  final storageService = StorageService();
  final fileService = FileService();
  
  runApp(
    MultiProvider(
      providers: [
        // Глобальные сервисы
        Provider<ApiService>(create: (_) => apiService),
        Provider<StorageService>(create: (_) => storageService),
        Provider<FileService>(create: (_) => fileService),
        
        // ViewModels
        ChangeNotifierProvider<ProjectListViewModel>(
          create: (context) => ProjectListViewModel(
            apiService: context.read<ApiService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider<AIAssistantViewModel>(
          create: (context) => AIAssistantViewModel(
            apiService: context.read<ApiService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider<SettingsViewModel>(
          create: (context) => SettingsViewModel(
            storageService: context.read<StorageService>(),
          ),
        ),
      ],
      child: NovaSpecApp(),
    ),
  );
}
```

### Использование Provider в View

```dart
// Доступ к ViewModel
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Чтение данных
    final viewModel = context.watch<ProjectListViewModel>();
    final projects = viewModel.projects;
    
    // Вызов методов
    return ElevatedButton(
      onPressed: () => context.read<ProjectListViewModel>().loadProjects(),
      child: Text('Load Projects'),
    );
  }
}

// Consumer для оптимизации
class OptimizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectListViewModel>(
      builder: (context, viewModel, child) {
        // Перестраивается только при изменении ProjectListViewModel
        return Column(
          children: [
            Text('Projects: ${viewModel.projects.length}'),
            if (viewModel.isLoading)
              CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}

// Selector для выборочных обновлений
class SelectiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ProjectListViewModel, int>(
      selector: (context, viewModel) => viewModel.projects.length,
      builder: (context, projectCount, child) {
        // Перестраивается только при изменении количества проектов
        return Text('Total projects: $projectCount');
      },
    );
  }
}
```

## Управление состоянием

### State Management паттерны

#### 1. Локальное состояние (StatefulWidget)

```dart
class LocalStateWidget extends StatefulWidget {
  @override
  _LocalStateWidgetState createState() => _LocalStateWidgetState();
}

class _LocalStateWidgetState extends State<LocalStateWidget> {
  bool _isExpanded = false;
  String _inputText = '';
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _inputText = value),
        ),
        ExpansionTile(
          title: Text('Expand'),
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          children: [
            Text(_inputText),
          ],
        ),
      ],
    );
  }
}
```

#### 2. Глобальное состояние (Provider)

```dart
// Глобальный провайдер темы
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }
}

// Использование в MaterialApp
MaterialApp(
  themeMode: context.watch<ThemeProvider>().themeMode,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
)
```

#### 3. Состояние сессии (StorageService)

```dart
class StorageService {
  static const String _userKey = 'user';
  static const String _settingsKey = 'settings';
  
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }
  
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
```

## Навигация

### Именованные маршруты

```dart
// app/routes/app_routes.dart
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String projectList = '/project/list';
  static const String projectDetail = '/project/detail';
  static const String projectCreate = '/project/create';
  static const String projectEdit = '/project/edit';
  static const String aiAssistant = '/ai-assistant';
  static const String settings = '/settings';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
          settings: settings,
        );
        
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(),
          settings: settings,
        );
        
      case AppRoutes.projectList:
        return MaterialPageRoute(
          builder: (_) => ProjectListScreen(),
          settings: settings,
        );
        
      case AppRoutes.projectDetail:
        final projectId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: projectId),
          settings: settings,
        );
        
      case AppRoutes.projectCreate:
        return MaterialPageRoute(
          builder: (_) => ProjectCreateScreen(),
          settings: settings,
        );
        
      case AppRoutes.aiAssistant:
        return MaterialPageRoute(
          builder: (_) => AIAssistantScreen(),
          settings: settings,
        );
        
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(),
          settings: settings,
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundScreen(),
          settings: settings,
        );
    }
  }
}
```

### Навигация с аргументами

```dart
// Навигация с аргументами
Navigator.of(context).pushNamed(
  AppRoutes.projectDetail,
  arguments: projectId,
);

// Получение аргументов
class ProjectDetailScreen extends StatelessWidget {
  final String projectId;
  
  const ProjectDetailScreen({
    Key? key,
    @required this.projectId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project $projectId'),
      ),
      body: Consumer<ProjectDetailViewModel>(
        builder: (context, viewModel, child) {
          return FutureBuilder<Project>(
            future: viewModel.loadProject(projectId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              
              final project = snapshot.data!;
              return ProjectDetailView(project: project);
            },
          );
        },
      ),
    );
  }
}
```

## Обработка ошибок

### Кастомные исключения

```dart
// core/exceptions/app_exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) : super(message, code: code);
}

class ApiException extends AppException {
  final int? statusCode;
  
  const ApiException(String message, {this.statusCode, String? code}) 
      : super(message, code: code);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException(String message, {this.fieldErrors, String? code}) 
      : super(message, code: code);
}

class StorageException extends AppException {
  const StorageException(String message, {String? code}) : super(message, code: code);
}
```

### Глобальный обработчик ошибок

```dart
// core/services/error_handler.dart
import 'package:flutter/material.dart';
import '../exceptions/app_exceptions.dart';

class ErrorHandler {
  static void handleError(BuildContext context, AppException exception) {
    String message = exception.message;
    String action = 'OK';
    
    switch (exception.runtimeType) {
      case NetworkException:
        message = 'Network error. Please check your internet connection.';
        action = 'Retry';
        break;
      case ApiException:
        if (exception.statusCode == 401) {
          message = 'Authentication failed. Please login again.';
          action = 'Login';
        } else if (exception.statusCode! >= 500) {
          message = 'Server error. Please try again later.';
        }
        break;
      case ValidationException:
        final validationException = exception as ValidationException;
        if (validationException.fieldErrors != null) {
          message = validationException.fieldErrors!.values.first;
        }
        break;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(action),
          ),
        ],
      ),
    );
  }
  
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
```

## Тестирование

### Unit тесты для ViewModel

```dart
// test/features/project_management/viewmodels/project_list_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:novaspec/features/project_management/viewmodels/project_list_viewmodel.dart';
import 'package:novaspec/core/services/api_service.dart';
import 'package:novaspec/core/services/storage_service.dart';

class MockApiService extends Mock implements ApiService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  group('ProjectListViewModel', () {
    late ProjectListViewModel viewModel;
    late MockApiService mockApiService;
    late MockStorageService mockStorageService;
    
    setUp(() {
      mockApiService = MockApiService();
      mockStorageService = MockStorageService();
      viewModel = ProjectListViewModel(
        apiService: mockApiService,
        storageService: mockStorageService,
      );
    });
    
    test('initial state is correct', () {
      expect(viewModel.projects, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
    });
    
    test('loadProjects updates state correctly', () async {
      final projects = [
        Project(id: '1', name: 'Test Project', description: 'Test'),
      ];
      
      when(mockApiService.getProjects()).thenAnswer((_) async => projects);
      when(mockStorageService.cacheProjects(any)).thenAnswer((_) async {});
      
      await viewModel.loadProjects();
      
      expect(viewModel.projects, equals(projects));
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      
      verify(mockApiService.getProjects()).called(1);
      verify(mockStorageService.cacheProjects(projects)).called(1);
    });
    
    test('loadProjects handles error correctly', () async {
      when(mockApiService.getProjects()).thenThrow(Exception('Network error'));
      when(mockStorageService.getCachedProjects()).thenAnswer((_) async => []);
      
      await viewModel.loadProjects();
      
      expect(viewModel.projects, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNotNull);
      
      verify(mockApiService.getProjects()).called(1);
      verify(mockStorageService.getCachedProjects()).called(1);
    });
    
    test('filtering works correctly', () {
      final projects = [
        Project(id: '1', name: 'Project 1', description: 'Description 1', status: ProjectStatus.active),
        Project(id: '2', name: 'Project 2', description: 'Description 2', status: ProjectStatus.draft),
      ];
      
      // Simulate loaded projects
      viewModel._projects = projects;
      
      // Test status filter
      viewModel.setStatusFilter(ProjectStatus.active);
      expect(viewModel.filteredProjects, hasLength(1));
      expect(viewModel.filteredProjects.first.name, 'Project 1');
      
      // Test search filter
      viewModel.setSearchQuery('Project 2');
      expect(viewModel.filteredProjects, hasLength(1));
      expect(viewModel.filteredProjects.first.name, 'Project 2');
    });
  });
}
```

### Widget тесты

```dart
// test/features/project_management/views/project_list_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:novaspec/features/project_management/views/project_list_screen.dart';
import 'package:novaspec/features/project_management/viewmodels/project_list_viewmodel.dart';

class MockProjectListViewModel extends ChangeNotifier implements ProjectListViewModel {
  @override
  List<Project> projects = [];
  
  @override
  bool isLoading = false;
  
  @override
  String? error;
  
  @override
  List<Project> get filteredProjects => projects;
  
  @override
  Future<void> loadProjects() async {
    // Mock implementation
  }
  
  // Mock other methods...
}

void main() {
  group('ProjectListScreen', () {
    testWidgets('displays loading state correctly', (WidgetTester tester) async {
      final mockViewModel = MockProjectListViewModel();
      mockViewModel.isLoading = true;
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ProjectListViewModel>(
          create: (_) => mockViewModel,
          child: MaterialApp(home: ProjectListScreen()),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('displays project list correctly', (WidgetTester tester) async {
      final mockViewModel = MockProjectListViewModel();
      mockViewModel.projects = [
        Project(id: '1', name: 'Test Project', description: 'Test Description'),
      ];
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ProjectListViewModel>(
          create: (_) => mockViewModel,
          child: MaterialApp(home: ProjectListScreen()),
        ),
      );
      
      expect(find.text('Test Project'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });
    
    testWidgets('displays empty state when no projects', (WidgetTester tester) async {
      final mockViewModel = MockProjectListViewModel();
      mockViewModel.projects = [];
      
      await tester.pumpWidget(
        ChangeNotifierProvider<ProjectListViewModel>(
          create: (_) => mockViewModel,
          child: MaterialApp(home: ProjectListScreen()),
        ),
      );
      
      expect(find.text('No projects found'), findsOneWidget);
      expect(find.text('Create your first project to get started'), findsOneWidget);
    });
  });
}
```

## Производительность

### Оптимизации

#### 1. ListView.builder

```dart
// Плохо - создает все элементы сразу
Column(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// Хорошо - создает элементы по мере необходимости
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

#### 2. Const конструкторы

```dart
// Плохо
Container(
  color: Colors.blue,
  child: Text('Hello'),
)

// Хорошо
Container(
  color: Colors.blue,
  child: const Text('Hello'),
)
```

#### 3. Image caching

```dart
// Кэширование изображений
Image.network(
  imageUrl,
  cacheWidth: 300,
  cacheHeight: 300,
)
```

#### 4. Selector для оптимизации Provider

```dart
// Плохо - перестраивается при любых изменениях
Consumer<MyViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.items.length.toString());
  },
)

// Хорошо - перестраивается только при изменении items.length
Selector<MyViewModel, int>(
  selector: (context, viewModel) => viewModel.items.length,
  builder: (context, itemCount, child) {
    return Text(itemCount.toString());
  },
)
```

## Заключение

Эта архитектура обеспечивает:

- **Масштабируемость**: Легко добавлять новые фичи
- **Тестируемость**: Каждый слой может тестироваться независимо
- **Поддержание**: Четкое разделение ответственности
- **Производительность**: Оптимизированные паттерны для Flutter
- **Переиспользование**: Shared компоненты и сервисы

Архитектура следует лучшим практикам Flutter и обеспечивает прочную основу для развития NovaSpec приложения.