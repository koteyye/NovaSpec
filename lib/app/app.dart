import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../core/providers/app_provider.dart';
import '../core/providers/settings_provider.dart';
import '../core/services/config_service.dart';
import '../core/services/secure_storage_service.dart';
import '../core/services/storage_service.dart';
import 'themes/app_theme.dart';
import '../app/screens/main_screen.dart';
import '../features/project/providers/project_provider.dart';
import '../core/services/project_service.dart';
import '../shared/widgets/modern_toast.dart';

class NovaSpecApp extends StatelessWidget {
  const NovaSpecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => StorageServiceImpl()),
        Provider<ConfigService>(create: (context) => ConfigServiceImpl(context.read<StorageService>())),
        Provider<SecureStorageService>(create: (_) => SecureStorageServiceImpl()),
        ChangeNotifierProvider(create: (context) => AppProvider(context.read<ConfigService>(), context.read<StorageService>())),
        ChangeNotifierProvider(create: (context) => ProjectProvider(ProjectService())),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            navigatorKey: ProjectProvider.navigatorKey,
            title: 'NovaSpec',
            debugShowCheckedModeBanner: false,
            
            // Локализация
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: appProvider.currentLocale,
            
            // Тема
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            
            // Маршруты
            // Главная страница - новый MainScreen с онбордингом и верхней панелью
            home: Stack(
              children: [
                const MainScreen(),
                // Toast container для отображения уведомлений
                const Positioned(
                  top: 20,
                  right: 20,
                  child: ToastContainer(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}