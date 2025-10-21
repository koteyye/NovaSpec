import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/di/service_locator.dart';
import 'core/providers/app_provider.dart';
import 'core/services/config_service.dart';
import 'core/services/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация dependency injection
  await setupServiceLocator();
  
  runApp(const NovaSpecAppWrapper());
}

class NovaSpecAppWrapper extends StatefulWidget {
  const NovaSpecAppWrapper({super.key});

  @override
  State<NovaSpecAppWrapper> createState() => _NovaSpecAppWrapperState();
}

class _NovaSpecAppWrapperState extends State<NovaSpecAppWrapper> {
  final AppProvider _appProvider = sl<AppProvider>();
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
        Provider<ConfigService>(create: (_) => sl<ConfigService>()),
        Provider<SecureStorageService>(create: (_) => sl<SecureStorageService>()),
      ],
      child: const NovaSpecApp(),
    );
  }
}