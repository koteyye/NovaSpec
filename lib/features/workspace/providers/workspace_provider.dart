import 'package:flutter/foundation.dart';
import '../models/workspace_panel.dart';
import '../models/workspace_tab.dart';
import '../models/open_file.dart';
import '../models/file_operation.dart';
import '../../../core/services/workspace_service.dart';
import '../../../core/services/workspace_file_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../../shared/services/di_container.dart';

class WorkspaceProvider extends ChangeNotifier {
  final WorkspaceService _workspaceService;
  final WorkspaceFileService _fileService;

  List<WorkspacePanel> _panels = [];
  List<WorkspaceTab> _tabs = [];
  List<OpenFile> _openFiles = [];
  final List<FileOperation> _operations = [];
  bool _isLoading = false;
  String? _error;

  WorkspaceProvider({
    required WorkspaceService workspaceService,
    required WorkspaceFileService fileService,
  }) : _workspaceService = workspaceService,
       _fileService = fileService;

  // Getters
  List<WorkspacePanel> get panels => List.unmodifiable(_panels);
  List<WorkspaceTab> get tabs => List.unmodifiable(_tabs);
  List<OpenFile> get openFiles => List.unmodifiable(_openFiles);
  List<FileOperation> get operations => List.unmodifiable(_operations);
  bool get isLoading => _isLoading;
  String? get error => _error;
  ClipboardService get clipboardService => getIt<ClipboardService>();

  // Initialize workspace
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _workspaceService.initialize();
      _panels = await _workspaceService.getPanels();
      _tabs = await _workspaceService.getTabs();
      _openFiles = await _workspaceService.getOpenFiles();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Panel management
  Future<void> addPanel(WorkspacePanel panel) async {
    try {
      await _workspaceService.savePanel(panel);
      _panels.add(panel);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePanel(WorkspacePanel panel) async {
    try {
      await _workspaceService.savePanel(panel);
      final index = _panels.indexWhere((p) => p.id == panel.id);
      if (index != -1) {
        _panels[index] = panel;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removePanel(String panelId) async {
    try {
      final panel = _panels.firstWhere((p) => p.id == panelId);
      await _workspaceService.deletePanel(panel.type);
      _panels.removeWhere((p) => p.id == panelId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> togglePanelVisibility(String panelId) async {
    final index = _panels.indexWhere((p) => p.id == panelId);
    if (index != -1) {
      final updatedPanel = _panels[index].copyWith(
        isVisible: !_panels[index].isVisible,
      );
      await updatePanel(updatedPanel);
    }
  }

  Future<void> resizePanel(String panelId, double size) async {
    final index = _panels.indexWhere((p) => p.id == panelId);
    if (index != -1) {
      final updatedPanel = _panels[index].copyWith(width: size);
      await updatePanel(updatedPanel);
    }
  }

  // Tab management
  Future<void> openTab(WorkspaceTab tab) async {
    try {
      await _workspaceService.saveTab(tab);
      _tabs.add(tab);
      
      // Add to open files if not already there
      if (!_openFiles.any((f) => f.path == tab.path)) {
        final openFile = OpenFile(
          id: tab.id,
          path: tab.filePath,
          name: tab.fileName,
          contentType: tab.contentType,
          content: '',
          size: 0,
          lastModified: DateTime.now(),
          isTextFile: tab.contentType != FileContentType.binary,
          metadata: {},
        );
        await _workspaceService.saveOpenFile(openFile);
        _openFiles.add(openFile);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> closeTab(String tabId) async {
    try {
      await _workspaceService.deleteTab(tabId);
      _tabs.removeWhere((t) => t.id == tabId);
      
      // Remove from open files if no other tabs reference this file
      final tab = _tabs.firstWhere((t) => t.id == tabId);
      if (!_tabs.any((t) => t.filePath == tab.filePath && t.id != tabId)) {
        await _workspaceService.deleteOpenFile(tabId);
        _openFiles.removeWhere((f) => f.path == tab.filePath);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> switchTab(String tabId) async {
    final index = _tabs.indexWhere((t) => t.id == tabId);
    if (index != -1) {
      // No need to update all tabs - activeTab is managed by TabProvider
      
      await _workspaceService.saveTabs(_tabs);
      notifyListeners();
    }
  }

  // File operations
  Future<void> performFileOperation(FileOperation operation) async {
    _operations.add(operation);
    notifyListeners();

    try {
      // Update operation to in progress
      final updatedOp = operation.copyWith(status: FileOperationStatus.inProgress);
      final index = _operations.indexWhere((op) => op.id == operation.id);
      if (index != -1) {
        _operations[index] = updatedOp;
        notifyListeners();
      }

      // Perform the actual file operation
      await _fileService.performOperation(operation);

      // Mark as completed
      final completedOp = updatedOp.copyWith(
        status: FileOperationStatus.completed,
        completedAt: DateTime.now(),
        progress: 1.0,
      );
      final completedIndex = _operations.indexWhere((op) => op.id == operation.id);
      if (completedIndex != -1) {
        _operations[completedIndex] = completedOp;
        notifyListeners();
      }
    } catch (e) {
      // Mark as failed
      final failedOp = operation.copyWith(
        status: FileOperationStatus.failed,
        completedAt: DateTime.now(),
        errorMessage: e.toString(),
      );
      final failedIndex = _operations.indexWhere((op) => op.id == operation.id);
      if (failedIndex != -1) {
        _operations[failedIndex] = failedOp;
        notifyListeners();
      }
    }
  }

  void clearCompletedOperations() {
    _operations.removeWhere((op) => op.status == FileOperationStatus.completed);
    notifyListeners();
  }

  // Refresh current directory (for file explorer updates)
  Future<void> refreshCurrentDirectory() async {
    try {
      // This will notify file explorer provider to refresh
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

}
