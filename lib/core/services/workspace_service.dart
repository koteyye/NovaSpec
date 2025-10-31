import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/workspace/models/workspace_panel.dart';
import '../../features/workspace/models/workspace_tab.dart';
import '../../features/workspace/models/open_file.dart';

class WorkspaceService {
  static const String _panelsKey = 'workspace_panels';
  static const String _tabsKey = 'workspace_tabs';
  static const String _openFilesKey = 'workspace_open_files';
  
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Panel operations
  Future<List<WorkspacePanel>> getPanels() async {
    try {
      final panelsJson = _prefs.getStringList(_panelsKey) ?? [];
      return panelsJson
          .map((json) => WorkspacePanel.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return _getDefaultPanels();
    }
  }

  Future<void> savePanel(WorkspacePanel panel) async {
    try {
      final panels = await getPanels();
      final index = panels.indexWhere((p) => p.type == panel.type);
      
      if (index != -1) {
        panels[index] = panel;
      } else {
        panels.add(panel);
      }
      
      await _savePanels(panels);
    } catch (e) {
      throw Exception('Failed to save panel: $e');
    }
  }

  Future<void> savePanels(List<WorkspacePanel> panels) async {
    try {
      await _savePanels(panels);
    } catch (e) {
      throw Exception('Failed to save panels: $e');
    }
  }

  Future<void> deletePanel(PanelType panelType) async {
    try {
      final panels = await getPanels();
      panels.removeWhere((p) => p.type == panelType);
      await _savePanels(panels);
    } catch (e) {
      throw Exception('Failed to delete panel: $e');
    }
  }

  Future<void> _savePanels(List<WorkspacePanel> panels) async {
    final panelsJson = panels.map((panel) => jsonEncode(panel.toJson())).toList();
    await _prefs.setStringList(_panelsKey, panelsJson);
  }

  List<WorkspacePanel> _getDefaultPanels() {
    return [
      const WorkspacePanel(
        id: 'file-explorer',
        type: PanelType.fileExplorer,
        width: 250.0,
        isVisible: true,
        isResizable: true,
        minWidth: 200.0,
        maxWidth: 400.0,
      ),
      const WorkspacePanel(
        id: 'open-files',
        type: PanelType.openFiles,
        width: 200.0,
        isVisible: true,
        isResizable: true,
        minWidth: 150.0,
        maxWidth: 300.0,
      ),
      const WorkspacePanel(
        id: 'outline',
        type: PanelType.outline,
        width: 250.0,
        isVisible: false,
        isResizable: true,
        minWidth: 200.0,
        maxWidth: 400.0,
      ),
      const WorkspacePanel(
        id: 'terminal',
        type: PanelType.terminal,
        width: 200.0,
        isVisible: false,
        isResizable: true,
        minWidth: 150.0,
        maxWidth: 500.0,
      ),
      const WorkspacePanel(
        id: 'output',
        type: PanelType.output,
        width: 200.0,
        isVisible: false,
        isResizable: true,
        minWidth: 150.0,
        maxWidth: 500.0,
      ),
      const WorkspacePanel(
        id: 'problems',
        type: PanelType.problems,
        width: 150.0,
        isVisible: false,
        isResizable: true,
        minWidth: 100.0,
        maxWidth: 300.0,
      ),
      const WorkspacePanel(
        id: 'ai-chat',
        type: PanelType.aiChat,
        width: 300.0,
        isVisible: true,
        isResizable: true,
        minWidth: 250.0,
        maxWidth: 600.0,
      ),
    ];
  }

  // Tab operations
  Future<List<WorkspaceTab>> getTabs() async {
    try {
      final tabsJson = _prefs.getStringList(_tabsKey) ?? [];
      return tabsJson
          .map((json) => WorkspaceTab.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTab(WorkspaceTab tab) async {
    try {
      final tabs = await getTabs();
      final index = tabs.indexWhere((t) => t.id == tab.id);
      
      if (index != -1) {
        tabs[index] = tab;
      } else {
        tabs.add(tab);
      }
      
      await _saveTabs(tabs);
    } catch (e) {
      throw Exception('Failed to save tab: $e');
    }
  }

  Future<void> saveTabs(List<WorkspaceTab> tabs) async {
    try {
      await _saveTabs(tabs);
    } catch (e) {
      throw Exception('Failed to save tabs: $e');
    }
  }

  Future<void> deleteTab(String tabId) async {
    try {
      final tabs = await getTabs();
      tabs.removeWhere((t) => t.id == tabId);
      await _saveTabs(tabs);
    } catch (e) {
      throw Exception('Failed to delete tab: $e');
    }
  }

  Future<void> _saveTabs(List<WorkspaceTab> tabs) async {
    final tabsJson = tabs.map((tab) => jsonEncode(tab.toJson())).toList();
    await _prefs.setStringList(_tabsKey, tabsJson);
  }

  // Open files operations
  Future<List<OpenFile>> getOpenFiles() async {
    try {
      final filesJson = _prefs.getStringList(_openFilesKey) ?? [];
      return filesJson
          .map((json) => OpenFile.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveOpenFile(OpenFile file) async {
    try {
      final files = await getOpenFiles();
      final index = files.indexWhere((f) => f.id == file.id);
      
      if (index != -1) {
        files[index] = file;
      } else {
        files.add(file);
      }
      
      await _saveOpenFiles(files);
    } catch (e) {
      throw Exception('Failed to save open file: $e');
    }
  }

  Future<void> saveOpenFiles(List<OpenFile> files) async {
    try {
      await _saveOpenFiles(files);
    } catch (e) {
      throw Exception('Failed to save open files: $e');
    }
  }

  Future<void> deleteOpenFile(String fileId) async {
    try {
      final files = await getOpenFiles();
      files.removeWhere((f) => f.id == fileId);
      await _saveOpenFiles(files);
    } catch (e) {
      throw Exception('Failed to delete open file: $e');
    }
  }

  Future<void> _saveOpenFiles(List<OpenFile> files) async {
    final filesJson = files.map((file) => jsonEncode(file.toJson())).toList();
    await _prefs.setStringList(_openFilesKey, filesJson);
  }

  // Workspace state operations
  Future<void> resetWorkspace() async {
    try {
      await _prefs.remove(_panelsKey);
      await _prefs.remove(_tabsKey);
      await _prefs.remove(_openFilesKey);
    } catch (e) {
      throw Exception('Failed to reset workspace: $e');
    }
  }

  Future<Map<String, dynamic>> exportWorkspace() async {
    try {
      final panels = await getPanels();
      final tabs = await getTabs();
      final openFiles = await getOpenFiles();
      
      return {
        'panels': panels.map((p) => p.toJson()).toList(),
        'tabs': tabs.map((t) => t.toJson()).toList(),
        'openFiles': openFiles.map((f) => f.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export workspace: $e');
    }
  }

  Future<void> importWorkspace(Map<String, dynamic> workspaceData) async {
    try {
      if (workspaceData.containsKey('panels')) {
        final panels = (workspaceData['panels'] as List)
            .map((json) => WorkspacePanel.fromJson(json))
            .toList();
        await _savePanels(panels);
      }
      
      if (workspaceData.containsKey('tabs')) {
        final tabs = (workspaceData['tabs'] as List)
            .map((json) => WorkspaceTab.fromJson(json))
            .toList();
        await _saveTabs(tabs);
      }
      
      if (workspaceData.containsKey('openFiles')) {
        final openFiles = (workspaceData['openFiles'] as List)
            .map((json) => OpenFile.fromJson(json))
            .toList();
        await _saveOpenFiles(openFiles);
      }
    } catch (e) {
      throw Exception('Failed to import workspace: $e');
    }
  }

  // Settings operations
  Future<void> saveWorkspaceSettings(Map<String, dynamic> settings) async {
    try {
      final settingsJson = jsonEncode(settings);
      await _prefs.setString('workspace_settings', settingsJson);
    } catch (e) {
      throw Exception('Failed to save workspace settings: $e');
    }
  }

  Future<Map<String, dynamic>> getWorkspaceSettings() async {
    try {
      final settingsJson = _prefs.getString('workspace_settings');
      if (settingsJson != null) {
        return jsonDecode(settingsJson);
      }
      return _getDefaultWorkspaceSettings();
    } catch (e) {
      return _getDefaultWorkspaceSettings();
    }
  }

  Map<String, dynamic> _getDefaultWorkspaceSettings() {
    return {
      'theme': 'system',
      'fontSize': 14,
      'fontFamily': 'Consolas',
      'tabSize': 4,
      'wordWrap': true,
      'minimap': true,
      'lineNumbers': true,
      'autoSave': 'afterDelay',
      'autoSaveDelay': 1000,
    };
  }
}
