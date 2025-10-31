import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../core/providers/app_provider.dart';
import '../core/providers/settings_provider.dart';
import 'themes/app_theme.dart';
import '../app/screens/main_screen.dart';
import '../features/project/providers/project_provider.dart';
import '../shared/services/di_container.dart';
import '../shared/widgets/modern_toast.dart';

class NovaSpecApp extends StatelessWidget {
  const NovaSpecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Используем SettingsProvider из main.dart для избежания дублирования
        ChangeNotifierProvider(create: (context) => getIt<ProjectProvider>()),
      ],
      child: Consumer2<AppProvider, SettingsProvider>(
        builder: (context, appProvider, settingsProvider, child) {
          return MaterialApp(
            navigatorKey: ProjectProvider.navigatorKey,
            title: 'NovaSpec',
            debugShowCheckedModeBanner: false,
            
            // Локализация
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: settingsProvider.language == 'ru' 
                ? const Locale('ru', 'RU')
                : const Locale('en', 'US'),
            
            // Тема
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            
            // Маршруты
            // Главная страница - новый MainScreen с онбордингом и верхней панелью
            home: const Stack(
              children: [
                MainScreen(),
                // Toast container для отображения уведомлений
                Positioned(
                  bottom: 20,
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
