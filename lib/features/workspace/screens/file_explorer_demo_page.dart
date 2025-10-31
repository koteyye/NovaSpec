import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/file_explorer_provider.dart';
import '../widgets/file_explorer_tree.dart';
import '../providers/workspace_provider.dart';
import '../providers/tab_provider.dart';
import '../../../shared/services/di_container.dart';
import '../../../core/services/file_icon_service.dart';

/// Demo page for testing file explorer functionality
class FileExplorerDemoPage extends StatefulWidget {
  const FileExplorerDemoPage({super.key});

  @override
  State<FileExplorerDemoPage> createState() => _FileExplorerDemoPageState();
}

class _FileExplorerDemoPageState extends State<FileExplorerDemoPage> {
  late FileExplorerProvider _fileExplorerProvider;
  late WorkspaceProvider _workspaceProvider;
  late TabProvider _tabProvider;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    _fileExplorerProvider = getIt<FileExplorerProvider>();
    _workspaceProvider = getIt<WorkspaceProvider>();
    _tabProvider = getIt<TabProvider>();
    
    // Initialize with current directory or a test directory
    _initializeFileExplorer();
  }

  Future<void> _initializeFileExplorer() async {
    try {
      // For demo purposes, we'll initialize with current directory
      await _fileExplorerProvider.initialize();
    } catch (e) {
      // If directory initialization fails, create mock data
      _createMockFileStructure();
    }
  }

  void _createMockFileStructure() {
    // This would create a mock file structure for testing
    // In a real implementation, this would be handled by the provider
    debugPrint('Creating mock file structure for demo');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FileExplorerProvider>.value(value: _fileExplorerProvider),
        ChangeNotifierProvider<WorkspaceProvider>.value(value: _workspaceProvider),
        ChangeNotifierProvider<TabProvider>.value(value: _tabProvider),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('File Explorer Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializeFileExplorer,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: _selectDirectory,
              tooltip: 'Select Directory',
            ),
          ],
        ),
        body: Row(
          children: [
            // File Explorer Panel
            SizedBox(
              width: 300,
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'File Explorer',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Consumer<FileExplorerProvider>(
                            builder: (context, provider, child) {
                              return provider.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                    // File Explorer Tree
                    const Divider(height: 1),
                    Expanded(
                      child: Consumer<FileExplorerProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (provider.error != null) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading files',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    provider.error!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _initializeFileExplorer,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (provider.rootNodes.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No files to display',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Select a directory to view its contents',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _selectDirectory,
                                    child: const Text('Select Directory'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return const FileExplorerTree();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content Area
            const VerticalDivider(width: 1),
            Expanded(
              child: Consumer<TabProvider>(
                builder: (context, tabProvider, child) {
                  if (tabProvider.tabs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_open_outlined,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No files open',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Select a file from the file explorer to open it',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Tab Bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: tabProvider.tabs.length,
                          itemBuilder: (context, index) {
                            final tab = tabProvider.tabs[index];
                            final isActive = tab.id == tabProvider.activeTabId;

                            return Container(
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: FileIconService.getIconWidget(tab.filePath),
                                    onPressed: () {
                                      tabProvider.switchTab(tab.id);
                                    },
                                    tooltip: tab.fileName,
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      tabProvider.switchTab(tab.id);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      alignment: Alignment.center,
                                      child: Text(
                                        tab.fileName,
                                        style: TextStyle(
                                          color: isActive
                                              ? Theme.of(context).colorScheme.onPrimaryContainer
                                              : Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      tabProvider.closeTab(tab.id);
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Content Area
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: Text(
                              'File content will be displayed here\nwhen file renderers are implemented',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDirectory() async {
    // This would open a directory picker
    // For now, just show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Directory picker not implemented yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
