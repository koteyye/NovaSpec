import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/security_service.dart';
import '../screens/component_demo_screen.dart';

// Enhanced security validation for routes
class RouteValidator {
  static final SecurityService _security = SecurityService.instance;
  
  static bool isValidPath(String path) {
    final validation = _security.validateFilePath(path);
    return validation.isValid && 
           !path.startsWith('/') &&
           path.length < 1000;
  }
  
  static bool isValidUrl(String url) {
    final validation = _security.validateUrl(url);
    return validation.isValid;
  }
  
  static bool isValidContent(String content) {
    final validation = _security.validateTextInput(content, maxLength: 1000000);
    return validation.isValid && content.length < 1000000; // 1MB limit
  }
  
  static String sanitizePath(String path) {
    final validation = _security.validateFilePath(path);
    return validation.sanitizedInput;
  }
  
  static String sanitizeContent(String content) {
    final validation = _security.validateTextInput(content);
    return validation.sanitizedInput;
  }
}

// Имена маршрутов
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String workspace = '/workspace';
  static const String projectManagement = '/project-management';
  static const String settings = '/settings';
  static const String aiAssistant = '/ai-assistant';
  static const String fileExplorer = '/file-explorer';
  static const String templates = '/templates';
  static const String specPreview = '/spec-preview';
  static const String textEditor = '/text-editor';
  static const String swaggerViewer = '/swagger-viewer';
  static const String componentDemo = '/component-demo';
}

// Кэш для виджетов - оптимизация производительности
class _WidgetCache {
  static final Map<String, Widget> _cache = {};
  static const int _maxCacheSize = 10;

  static Widget? get(String key) {
    return _cache[key];
  }

  static void put(String key, Widget widget) {
    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = widget;
  }

  static void clear() {
    _cache.clear();
  }
}

// Ленивая загрузка виджетов
class LazyLoadWidget {
  static Widget create(Widget Function() builder, {String? cacheKey}) {
    if (cacheKey != null) {
      final cached = _WidgetCache.get(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    return Builder(
      builder: (context) {
        final widget = builder();
        if (cacheKey != null) {
          _WidgetCache.put(cacheKey, widget);
        }
        return widget;
      },
    );
  }
}

// Оптимизированная маршрутизация с ленивой загрузкой
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const SplashScreen(),
            cacheKey: 'splash',
          ),
          settings: settings,
        );
        
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const OnboardingScreen(),
            cacheKey: 'onboarding',
          ),
          settings: settings,
        );
        
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const HomeScreen(),
            cacheKey: 'home',
          ),
          settings: settings,
        );
        
      case AppRoutes.workspace:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const WorkspaceScreen(),
            cacheKey: 'workspace',
          ),
          settings: settings,
        );
        
      case AppRoutes.projectManagement:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const ProjectManagementScreen(),
            cacheKey: 'project_management',
          ),
          settings: settings,
        );
        

        
      case AppRoutes.aiAssistant:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const AIAssistantScreen(),
            cacheKey: 'ai_assistant',
          ),
          settings: settings,
        );
        
      case AppRoutes.fileExplorer:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const FileExplorerScreen(),
            cacheKey: 'file_explorer',
          ),
          settings: settings,
        );
        
      case AppRoutes.templates:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const TemplatesScreen(),
            cacheKey: 'templates',
          ),
          settings: settings,
        );
        
      case AppRoutes.specPreview:
        final args = settings.arguments as Map<String, dynamic>?;
        final specPath = args?['specPath'] as String? ?? '';
        final specContent = args?['specContent'] as String? ?? '';
        
        // Валидация параметров
        if (!RouteValidator.isValidPath(specPath) || 
            !RouteValidator.isValidContent(specContent)) {
          return MaterialPageRoute(
            builder: (_) => LazyLoadWidget.create(
              () => const NotFoundScreen(),
              cacheKey: 'not_found',
            ),
            settings: settings,
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => SpecPreviewScreen(
              specPath: specPath,
              specContent: specContent,
            ),
          ),
          settings: settings,
        );
        
      case AppRoutes.textEditor:
        final args = settings.arguments as Map<String, dynamic>?;
        final filePath = args?['filePath'] as String? ?? '';
        final initialContent = args?['initialContent'] as String? ?? '';
        
        // Валидация параметров
        if (!RouteValidator.isValidPath(filePath) || 
            !RouteValidator.isValidContent(initialContent)) {
          return MaterialPageRoute(
            builder: (_) => LazyLoadWidget.create(
              () => const NotFoundScreen(),
              cacheKey: 'not_found',
            ),
            settings: settings,
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => TextEditorScreen(
              filePath: filePath,
              initialContent: initialContent,
            ),
          ),
          settings: settings,
        );
        
      case AppRoutes.swaggerViewer:
        final args = settings.arguments as Map<String, dynamic>?;
        final swaggerUrl = args?['swaggerUrl'] as String? ?? '';
        final title = args?['title'] as String? ?? 'Swagger UI';
        
        // Валидация параметров
        if (!RouteValidator.isValidUrl(swaggerUrl) || 
            title.length > 100) {
          return MaterialPageRoute(
            builder: (_) => LazyLoadWidget.create(
              () => const NotFoundScreen(),
              cacheKey: 'not_found',
            ),
            settings: settings,
          );
        }
        
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => SwaggerViewerScreen(
              swaggerUrl: swaggerUrl,
              title: title,
            ),
          ),
          settings: settings,
        );
        
      case AppRoutes.componentDemo:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const ComponentDemoScreen(),
            cacheKey: 'component_demo',
          ),
          settings: settings,
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => LazyLoadWidget.create(
            () => const NotFoundScreen(),
            cacheKey: 'not_found',
          ),
          settings: settings,
        );
    }
  }

  // Очистка кэша при необходимости
  static void clearCache() {
    _WidgetCache.clear();
  }
}

// Временные заглушки для экранов (будут заменены реальными реализациями)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() async {
    // Задержка 3 секунды для демонстрации splash экрана
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG логотип
            SvgPicture.asset(
              'assets/images/novaspec-logo.svg',
              width: 120,
              height: 120,
              semanticsLabel: l10n.appName,
              placeholderBuilder: (context) => SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Название приложения
            Text(
              l10n.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Подзаголовок
            Text(
              'AI-powered specification assistant',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            // Индикатор загрузки
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Текст загрузки
            Text(
              l10n.loading,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.appName} - ${l10n.language}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('${l10n.appName}: ${l10n.appName}'),
            const SizedBox(height: 8),
            Text('${l10n.loading}: ${l10n.loading}'),
            const SizedBox(height: 8),
            Text('${l10n.projects}: ${l10n.projects}'),
            const SizedBox(height: 8),
            Text('${l10n.settings}: ${l10n.settings}'),
            const SizedBox(height: 8),
            Text('${l10n.aiAssistant}: ${l10n.aiAssistant}'),
            const SizedBox(height: 8),
            Text('${l10n.newProject}: ${l10n.newProject}'),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await appProvider.updateLanguage('en');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(l10n.switchToEnglish),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await appProvider.updateLanguage('ru');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(l10n.switchToRussian),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Тест SVG иконок
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/novaspec-logo.svg',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 16),
                SvgPicture.asset(
                  'assets/images/atlassian-icon.svg',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 16),
                Text(l10n.svgIconsTest),
              ],
            ),
            const Spacer(),
            // Кнопки перехода
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Продолжить'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.settings);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.settings),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.componentDemo);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Демонстрация UI компонентов'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добро пожаловать в ${l10n.appName}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-powered specification assistant',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Навигационные кнопки
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _NavigationCard(
                    title: l10n.projects,
                    subtitle: 'Управление проектами',
                    icon: Icons.folder,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.projectManagement);
                    },
                  ),
                  _NavigationCard(
                    title: l10n.workspace,
                    subtitle: 'Рабочее пространство',
                    icon: Icons.workspaces,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.workspace);
                    },
                  ),
                  _NavigationCard(
                    title: l10n.aiAssistant,
                    subtitle: 'AI ассистент',
                    icon: Icons.smart_toy,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.aiAssistant);
                    },
                  ),
                  _NavigationCard(
                    title: l10n.templates,
                    subtitle: 'Шаблоны',
                    icon: Icons.description,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.templates);
                    },
                  ),
                  _NavigationCard(
                    title: 'Файлы',
                    subtitle: 'Проводник',
                    icon: Icons.file_present,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.fileExplorer);
                    },
                  ),
                  _NavigationCard(
                    title: 'UI Демо',
                    subtitle: 'Компоненты',
                    icon: Icons.palette,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.componentDemo);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workspace),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.workspaceScreen,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('Здесь будет рабочее пространство'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.projectManagement),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            },
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.projectManagementScreen,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('Здесь будет управление проектами'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}



class AIAssistantScreen extends StatelessWidget {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Text(l10n.aiAssistantScreen),
      ),
    );
  }
}

class FileExplorerScreen extends StatelessWidget {
  const FileExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Text(l10n.fileExplorerScreen),
      ),
    );
  }
}

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Text(l10n.templatesScreen),
      ),
    );
  }
}

class SpecPreviewScreen extends StatelessWidget {
  final String specPath;
  final String specContent;
  
  const SpecPreviewScreen({
    super.key,
    required this.specPath,
    required this.specContent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.specPreview}: $specPath'),
      ),
      body: Center(
        child: Text('${l10n.specContent}: $specContent'),
      ),
    );
  }
}

class TextEditorScreen extends StatelessWidget {
  final String filePath;
  final String initialContent;
  
  const TextEditorScreen({
    super.key,
    required this.filePath,
    required this.initialContent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.textEditor}: $filePath'),
      ),
      body: Center(
        child: Text('${l10n.initialContent}: $initialContent'),
      ),
    );
  }
}

class SwaggerViewerScreen extends StatelessWidget {
  final String swaggerUrl;
  final String title;
  
  const SwaggerViewerScreen({
    super.key,
    required this.swaggerUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('${l10n.swaggerUrl}: $swaggerUrl'),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Text(l10n.pageNotFound),
      ),
    );
  }
}