import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/workspace_tab.dart';
import '../models/open_file.dart';
import '../../../core/services/workspace_service.dart';

class TabProvider extends ChangeNotifier {
  final WorkspaceService _workspaceService;

  List<WorkspaceTab> _tabs = [];
  List<OpenFile> _openFiles = [];
  String? _activeTabId;
  bool _isLoading = false;
  String? _error;

  TabProvider({required WorkspaceService workspaceService})
    : _workspaceService = workspaceService;

  // Getters
  List<WorkspaceTab> get tabs => List.unmodifiable(_tabs);
  List<OpenFile> get openFiles => List.unmodifiable(_openFiles);
  String? get activeTabId => _activeTabId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WorkspaceTab? get activeTab => _tabs.isNotEmpty
      ? _tabs.firstWhere(
          (tab) => tab.id == _activeTabId,
          orElse: () => _tabs.first,
        )
      : null;

  // Initialize tabs
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _tabs = await _workspaceService.getTabs();
      _openFiles = await _workspaceService.getOpenFiles();

      // Set first tab as active if no active tab
      if (_tabs.isNotEmpty && _activeTabId == null) {
        _activeTabId = _tabs.first.id;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Open new tab
  Future<void> openTab(String filePath, {String? title}) async {
    try {
      // Check if tab already exists
      try {
        final existingTab = _tabs.firstWhere((tab) => tab.filePath == filePath);
        // Switch to existing tab
        await switchTab(existingTab.id);
        return;
      } catch (e) {
        // Tab doesn't exist, continue creating new one
      }

      // Create new tab
      final tab = WorkspaceTab(
        id: _generateTabId(),
        filePath: filePath,
        fileName: _getFileNameFromPath(filePath),
        contentType: _detectContentType(filePath),
        mode: TabMode.render,
        isModified: false,
        lastModified: DateTime.now(),
        language: _detectLanguage(filePath),
      );

      // No need to deactivate tabs - activeTabId manages this
      _tabs.add(tab);
      _activeTabId = tab.id;

      await _workspaceService.saveTab(tab);
      await _workspaceService.saveTabs(_tabs);

      // Add to open files if not already there
      if (!_openFiles.any((file) => file.path == filePath)) {
        final openFile = OpenFile(
          id: tab.id,
          path: filePath,
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

  // Close tab
  Future<void> closeTab(String tabId) async {
    try {
      final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
      if (tabIndex == -1) return;

      final tab = _tabs[tabIndex];

      // Check if file is modified
      if (tab.isModified) {
        // TODO: Show save dialog
        // For now, just close
      }

      _tabs.removeAt(tabIndex);

      // Handle active tab change
      if (_activeTabId == tabId) {
        if (_tabs.isNotEmpty) {
          // Activate adjacent tab
          final newActiveIndex = tabIndex > 0 ? tabIndex - 1 : 0;
          _activeTabId = _tabs[newActiveIndex].id;
        } else {
          _activeTabId = null;
        }
      }

      await _workspaceService.deleteTab(tabId);
      await _workspaceService.saveTabs(_tabs);

      // Remove from open files if no other tabs reference this file
      if (!_tabs.any((t) => t.filePath == tab.filePath)) {
        await _workspaceService.deleteOpenFile(tabId);
        _openFiles.removeWhere((file) => file.path == tab.filePath);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Close all tabs except current
  Future<void> closeOtherTabs(String keepTabId) async {
    try {
      final tabsToClose = _tabs.where((tab) => tab.id != keepTabId).toList();

      for (final tab in tabsToClose) {
        await closeTab(tab.id);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Close all tabs
  Future<void> closeAllTabs() async {
    try {
      final tabs = List.from(_tabs);
      for (final tab in tabs) {
        await closeTab(tab.id);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Switch to tab
  Future<void> switchTab(String tabId) async {
    try {
      final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
      if (tabIndex == -1) return;

      // Activate selected tab
      _activeTabId = tabId;

      await _workspaceService.saveTabs(_tabs);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark tab as modified
  Future<void> markTabModified(String tabId, bool isModified) async {
    try {
      final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
      if (tabIndex == -1) return;

      _tabs[tabIndex] = _tabs[tabIndex].copyWith(isModified: isModified);
      await _workspaceService.saveTabs(_tabs);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update tab title
  Future<void> updateTabTitle(String tabId, String title) async {
    try {
      final tabIndex = _tabs.indexWhere((tab) => tab.id == tabId);
      if (tabIndex == -1) return;

      _tabs[tabIndex] = _tabs[tabIndex].copyWith(fileName: title);
      await _workspaceService.saveTabs(_tabs);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get tab by file path
  WorkspaceTab? getTabByPath(String filePath) {
    try {
      return _tabs.firstWhere((tab) => tab.filePath == filePath);
    } catch (e) {
      return null;
    }
  }

  // Check if file is open
  bool isFileOpen(String filePath) {
    return _tabs.any((tab) => tab.filePath == filePath);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _generateTabId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _getFileNameFromPath(String filePath) {
    return path.basename(filePath);
  }

  FileContentType _detectContentType(String filePath) {
    final extension = path
        .extension(filePath)
        .toLowerCase()
        .replaceFirst('.', '');

    switch (extension) {
      case 'md':
      case 'markdown':
        return FileContentType.markdown;
      case 'html':
      case 'htm':
        return FileContentType.html;
      case 'mp3':
      case 'wav':
      case 'ogg':
      case 'flac':
        return FileContentType.audio;
      case 'json':
      case 'yaml':
      case 'yml':
        return FileContentType
            .swagger; // Will be checked for OpenAPI in work_area
      case 'txt':
      case 'log':
      case 'csv':
      case 'tsv':
        return FileContentType.text;
      default:
        return FileContentType
            .text; // Default to text instead of binary for editable files
    }
  }

  String _detectLanguage(String filePath) {
    final extension = path
        .extension(filePath)
        .toLowerCase()
        .replaceFirst('.', '');

    switch (extension) {
      case 'js':
      case 'jsx':
        return 'javascript';
      case 'ts':
      case 'tsx':
        return 'typescript';
      case 'py':
        return 'python';
      case 'java':
        return 'java';
      case 'cpp':
      case 'cc':
      case 'cxx':
        return 'cpp';
      case 'c':
        return 'c';
      case 'cs':
        return 'csharp';
      case 'php':
        return 'php';
      case 'rb':
        return 'ruby';
      case 'go':
        return 'go';
      case 'rs':
        return 'rust';
      case 'swift':
        return 'swift';
      case 'kt':
        return 'kotlin';
      case 'dart':
        return 'dart';
      case 'html':
      case 'htm':
        return 'html';
      case 'css':
        return 'css';
      case 'scss':
      case 'sass':
        return 'scss';
      case 'less':
        return 'less';
      case 'xml':
        return 'xml';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'json':
        return 'json';
      case 'sql':
        return 'sql';
      case 'sh':
      case 'bash':
        return 'shell';
      case 'ps1':
        return 'powershell';
      case 'md':
      case 'markdown':
        return 'markdown';
      case 'vue':
        return 'vue';
      case 'svelte':
        return 'svelte';
      default:
        return 'plaintext';
    }
  }
}
