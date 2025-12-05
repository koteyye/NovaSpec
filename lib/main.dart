import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'shared/services/di_container.dart';
import 'core/providers/app_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/config_service.dart';
import 'core/services/secure_storage_service.dart';
import 'features/musication/providers/musication_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация window_manager для desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    // Настройки окна
    final WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'NovaSpec',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // local_notifier инициализируется автоматически

  // Инициализация dependency injection
  await setupDI();

  runApp(const NovaSpecAppWrapper());
}

class NovaSpecAppWrapper extends StatefulWidget {
  const NovaSpecAppWrapper({super.key});

  @override
  State<NovaSpecAppWrapper> createState() => _NovaSpecAppWrapperState();
}

class _NovaSpecAppWrapperState extends State<NovaSpecAppWrapper> {
  final AppProvider _appProvider = getIt<AppProvider>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _appProvider.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // В случае ошибки инициализации, все равно показываем приложение
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing NovaSpec...'),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appProvider),
        ChangeNotifierProvider(create: (_) => getIt<SettingsProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<MusicationProvider>()),
        Provider<ConfigService>(create: (_) => getIt<ConfigService>()),
        Provider<SecureStorageService>(
          create: (_) => getIt<SecureStorageService>(),
        ),
      ],
      child: const NovaSpecApp(),
    );
  }
}
