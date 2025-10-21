import 'package:get_it/get_it.dart';
import '../services/storage_service.dart';
import '../services/config_service.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../services/secure_storage_service.dart';
import '../services/project_service.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  sl.registerLazySingleton<StorageService>(() => StorageServiceImpl());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageServiceImpl());
  sl.registerLazySingleton<ConfigService>(() => ConfigServiceImpl(sl<StorageService>()));
  sl.registerLazySingleton<ApiService>(() => ApiServiceImpl());
  sl.registerLazySingleton<FileService>(() => FileServiceImpl());
  sl.registerLazySingleton<ProjectService>(() => ProjectService());
  
  // Providers
  sl.registerLazySingleton<AppProvider>(() => AppProvider(
    sl<ConfigService>(),
    sl<StorageService>(),
  ));
  sl.registerLazySingleton<SettingsProvider>(() => SettingsProvider());
}