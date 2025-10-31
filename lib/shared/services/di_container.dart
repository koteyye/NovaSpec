import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Core Services
import '../../core/providers/app_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/config_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/project_service.dart';
import '../../core/services/file_monitor_service.dart';
import '../../core/services/project_sync_service.dart';
import '../../core/services/ai_validation_service.dart';
import '../../core/services/confluence_validation_service.dart';
import '../../core/services/music_validation_service.dart';

// Project Services
import '../../features/project/providers/project_provider.dart';
import '../../features/project/services/project_sync_service_impl.dart';
import '../../features/project/services/project_service_impl.dart';
import '../../features/workspace/services/file_monitor_service_impl.dart';

// Workspace Services
import '../../features/workspace/providers/workspace_provider.dart';
import '../../features/workspace/providers/file_explorer_provider.dart';
import '../../features/workspace/providers/tab_provider.dart';
import '../../features/workspace/providers/panel_provider.dart';
import '../../core/services/workspace_service.dart';
import '../../core/services/clipboard_service.dart';
import '../../core/services/workspace_file_service.dart';
import '../../core/services/file_icon_service.dart';

// Shared Services
// import '../models/app_config.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI() async {
  // Register core services first
  getIt.registerSingleton<SecureStorageService>(SecureStorageServiceImpl());
  getIt.registerSingleton<StorageService>(StorageServiceImpl());
  getIt.registerSingleton<ConfigService>(ConfigServiceImpl(
    getIt<StorageService>(),
  ));
  
  // Register validation services
  getIt.registerSingleton<AIValidationService>(AIValidationService(Dio()));
  getIt.registerSingleton<ConfluenceValidationService>(ConfluenceValidationService(Dio()));
  getIt.registerSingleton<MusicValidationService>(MusicValidationService(Dio()));

  // Register core providers
  getIt.registerSingleton<AppProvider>(AppProvider(
    getIt<ConfigService>(),
    getIt<StorageService>(),
  ));
  getIt.registerSingleton<SettingsProvider>(SettingsProvider(
    aiValidationService: getIt<AIValidationService>(),
    confluenceValidationService: getIt<ConfluenceValidationService>(),
    musicValidationService: getIt<MusicValidationService>(),
  ));

  // Register shared services
  // getIt.registerSingleton<AppConfig>(AppConfig());
  getIt.registerSingleton<ToastService>(ToastService());

  // Register workspace services
  getIt.registerSingleton<WorkspaceService>(WorkspaceService());
  getIt.registerSingleton<ClipboardService>(ClipboardService());
  getIt.registerSingleton<FileIconService>(FileIconService());
  getIt.registerSingleton<WorkspaceFileService>(WorkspaceFileService(
    clipboardService: getIt<ClipboardService>(),
  ));

  // Register project services
  getIt.registerSingleton<FileMonitorService>(FileMonitorServiceImpl());
  getIt.registerSingleton<ProjectSyncService>(ProjectSyncServiceImpl());
  getIt.registerSingleton<ProjectService>(ProjectServiceImpl());

  // Register workspace providers
  getIt.registerSingleton<WorkspaceProvider>(WorkspaceProvider(
    workspaceService: getIt<WorkspaceService>(),
    fileService: getIt<WorkspaceFileService>(),
  ));
  getIt.registerSingleton<FileExplorerProvider>(FileExplorerProvider(
    fileService: getIt<WorkspaceFileService>(),
    iconService: getIt<FileIconService>(),
  ));
  getIt.registerSingleton<TabProvider>(TabProvider(
    workspaceService: getIt<WorkspaceService>(),
  ));

  // Register project provider after file explorer provider
  getIt.registerSingleton<ProjectProvider>(ProjectProvider(
    getIt<ProjectService>(),
    getIt<FileMonitorService>(),
  ));

  // Register panel provider
  getIt.registerSingleton<PanelProvider>(PanelProvider());
}

class ToastService {
  void showToast(String message, {ToastType type = ToastType.info}) {
    // Implementation will use ModernToast
  }
}

enum ToastType { info, success, warning, error }
