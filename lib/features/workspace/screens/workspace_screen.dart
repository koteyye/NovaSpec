import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../providers/file_explorer_provider.dart';
import '../providers/tab_provider.dart';
import '../providers/panel_provider.dart';
import '../widgets/workspace_layout.dart';
import '../../../features/project/providers/project_provider.dart';

import '../../../shared/services/di_container.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final WorkspaceProvider _workspaceProvider;
  late final FileExplorerProvider _fileExplorerProvider;
  late final TabProvider _tabProvider;
  late final PanelProvider _panelProvider;
  
  String? _lastLoadedProjectPath; // Отслеживаем последний загруженный проект

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Слушаем изменения ProjectProvider
    final projectProvider = Provider.of<ProjectProvider>(context);
    final currentProject = projectProvider.currentProject;
    
    // Если проект изменился, загружаем его в file explorer
    if (currentProject != null && 
        currentProject.directory.isNotEmpty &&
        currentProject.directory != _lastLoadedProjectPath) {
      
      _lastLoadedProjectPath = currentProject.directory;
      
      // Загружаем проект в проводник файлов
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fileExplorerProvider.loadProject(currentProject.directory);
        }
      });
    }
  }

  Future<void> _initializeProviders() async {
    _workspaceProvider = getIt<WorkspaceProvider>();
    _fileExplorerProvider = getIt<FileExplorerProvider>();
    _tabProvider = getIt<TabProvider>();
    _panelProvider = getIt<PanelProvider>();

    try {
      await Future.wait([
        _workspaceProvider.initialize(),
        _fileExplorerProvider.initialize(),
        _tabProvider.initialize(),
      ]);
    } catch (e) {
      // Handle initialization error
      debugPrint('Failed to initialize workspace providers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _workspaceProvider),
        ChangeNotifierProvider.value(value: _fileExplorerProvider),
        ChangeNotifierProvider.value(value: _tabProvider),
        ChangeNotifierProvider.value(value: _panelProvider),
      ],
      child: const WorkspaceLayout(),
    );
  }
}
