import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import '../services/config_service.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../services/secure_storage_service.dart';
import '../services/project_service.dart';
import '../services/ai_validation_service.dart';
import '../services/confluence_validation_service.dart';
import '../services/music_validation_service.dart';
import '../providers/app_provider.dart';
import '../providers/settings_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core HTTP client
  sl.registerLazySingleton<Dio>(() => Dio());
  
  // Services
  sl.registerLazySingleton<StorageService>(() => StorageServiceImpl());
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageServiceImpl());
  sl.registerLazySingleton<ConfigService>(() => ConfigServiceImpl(sl<StorageService>()));
  sl.registerLazySingleton<ApiService>(() => ApiServiceImpl());
  sl.registerLazySingleton<FileService>(() => FileServiceImpl());
  sl.registerLazySingleton<ProjectService>(() => ProjectService());
  
  // Validation Services
  sl.registerLazySingleton<AIValidationService>(() => AIValidationService(sl<Dio>()));
  sl.registerLazySingleton<ConfluenceValidationService>(() => ConfluenceValidationService(sl<Dio>()));
  sl.registerLazySingleton<MusicValidationService>(() => MusicValidationService(sl<Dio>()));
  
  // Providers
  sl.registerLazySingleton<AppProvider>(() => AppProvider(
    sl<ConfigService>(),
    sl<StorageService>(),
  ));
  sl.registerLazySingleton<SettingsProvider>(() => SettingsProvider(
    aiValidationService: sl<AIValidationService>(),
    confluenceValidationService: sl<ConfluenceValidationService>(),
    musicValidationService: sl<MusicValidationService>(),
  ));
}