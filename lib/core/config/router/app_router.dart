import 'package:go_router/go_router.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:novaspec/presentation/screens/main_screen.dart';
import 'package:novaspec/presentation/screens/onboarding_screen.dart';

/// Конфигурация роутинга приложения
class AppRouter {
  final HiveDataSource _dataSource;

  AppRouter(this._dataSource);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Проверяем, есть ли текущий проект
      final config = await _dataSource.getAppConfig();
      final hasProject = config?.currentProjectPath != null &&
          config!.currentProjectPath!.isNotEmpty;

      // Если пользователь на главной странице, но нет проекта - редирект на онбординг
      if (state.matchedLocation == '/' && !hasProject) {
        return '/onboarding';
      }

      // Если пользователь на онбординге, но проект уже есть - редирект на главную
      if (state.matchedLocation == '/onboarding' && hasProject) {
        return '/';
      }

      return null; // Нет редиректа
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
}
