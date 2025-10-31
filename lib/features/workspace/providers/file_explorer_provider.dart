
import 'package:flutter/material.dart';
import '../models/file_explorer_node.dart';
import '../models/context_menu_action.dart';
import '../../../core/services/workspace_file_service.dart';

import '../../../core/services/file_icon_service.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  typeAsc,
  typeDesc,
  dateAsc,
  dateDesc,
  sizeAsc,
  sizeDesc,
}

class FileExplorerProvider extends ChangeNotifier {
  final WorkspaceFileService _fileService;

  final List<FileExplorerNode> _rootNodes = [];
  List<FileExplorerNode> _currentPath = [];
  List<FileExplorerNode> _selectedNodes = [];
  final List<ContextMenuAction> _contextMenuActions = [];
  bool _isLoading = false;
  String? _error;
  String _currentDirectory = '';
  SortOption _sortOption = SortOption.nameAsc;
  bool _foldersFirst = true;

  
  // Tree view state
  final Map<String, bool> _expandedNodes = {};
  final Map<String, List<FileExplorerNode>> _nodeChildren = {};
  final Map<String, bool> _loadingNodes = {};

  FileExplorerProvider({
    required WorkspaceFileService fileService,
    required FileIconService iconService,
  }) : _fileService = fileService;

  // Getters
  List<FileExplorerNode> get rootNodes => List.unmodifiable(_rootNodes);
  List<FileExplorerNode> get currentPath => List.unmodifiable(_currentPath);
  List<FileExplorerNode> get selectedNodes => List.unmodifiable(_selectedNodes);
  List<ContextMenuAction> get contextMenuActions => List.unmodifiable(_contextMenuActions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentDirectory => _currentDirectory;
  SortOption get sortOption => _sortOption;
  bool get foldersFirst => _foldersFirst;
  Map<String, bool> get expandedNodes => Map.unmodifiable(_expandedNodes);
  Map<String, List<FileExplorerNode>> get nodeChildren => Map.unmodifiable(_nodeChildren);
  Map<String, bool> get loadingNodes => Map.unmodifiable(_loadingNodes);

  // Initialize file explorer
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _fileService.initialize();
      // Не загружаем директорию при инициализации, ждем открытия проекта
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load project directory
  Future<void> loadProject(String projectPath) async {
    _setLoading(true);
    try {
      _fileService.setCurrentProject(projectPath);
      await loadDirectory('');
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load directory contents
  Future<void> loadDirectory(String path) async {
    _setLoading(true);
    try {
      _currentDirectory = path;
      _currentPath = await _fileService.getDirectoryContents(path);
      _sortCurrentPath();
      _selectedNodes.clear();
      _updateContextMenuActions();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Get directory contents for tree building
  Future<List<FileExplorerNode>> getDirectoryContents(String path) async {
    try {
      final contents = await _fileService.getDirectoryContents(path);
      return _sortNodes(contents);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Navigate to parent directory
  Future<void> navigateToParent() async {
    if (_currentDirectory.isEmpty) return;
    
    final parentPath = _fileService.getParentDirectory(_currentDirectory);
    await loadDirectory(parentPath);
  }

  // Navigate into directory
  Future<void> navigateIntoDirectory(FileExplorerNode node) async {
    if (!node.isFolder) return;
    
    final newPath = _fileService.joinPath(_currentDirectory, node.name);
    await loadDirectory(newPath);
  }

  // Refresh current directory
  Future<void> refresh() async {
    await loadDirectory(_currentDirectory);
  }

  // Selection management
  void selectNode(FileExplorerNode node, {bool multiSelect = false}) {
    if (multiSelect) {
      if (_selectedNodes.contains(node)) {
        _selectedNodes.remove(node);
      } else {
        _selectedNodes.add(node);
      }
    } else {
      _selectedNodes = [node];
    }
    _updateContextMenuActions();
    notifyListeners();
  }

  void selectAll() {
    _selectedNodes = List.from(_currentPath);
    _updateContextMenuActions();
    notifyListeners();
  }

  void clearSelection() {
    _selectedNodes.clear();
    _updateContextMenuActions();
    notifyListeners();
  }

  // File operations
  Future<void> createFolder(String name) async {
    try {
      final fullPath = _fileService.joinPath(_currentDirectory, name);
      await _fileService.createDirectory(fullPath);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createFile(String name) async {
    try {
      final fullPath = _fileService.joinPath(_currentDirectory, name);
      await _fileService.createFile(fullPath);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Create file/folder in specific directory
  Future<void> createFolderInDirectory(String parentPath, String name) async {
    try {
      final fullPath = _fileService.joinPath(parentPath, name);
      await _fileService.createDirectory(fullPath);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createFileInDirectory(String parentPath, String name) async {
    try {
      final fullPath = _fileService.joinPath(parentPath, name);
      await _fileService.createFile(fullPath);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSelected() async {
    try {
      for (final node in _selectedNodes) {
        final fullPath = _fileService.joinPath(_currentDirectory, node.name);
        await _fileService.delete(fullPath, isFolder: node.isFolder);
      }
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> renameNode(FileExplorerNode node, String newName) async {
    try {
      final oldPath = _fileService.joinPath(_currentDirectory, node.name);
      final newPath = _fileService.joinPath(_currentDirectory, newName);
      await _fileService.rename(oldPath, newPath);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> copySelected() async {
    try {
      final paths = _selectedNodes.map((node) => 
        _fileService.joinPath(_currentDirectory, node.name)
      ).toList();
      await _fileService.copyToClipboard(paths);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> cutSelected() async {
    try {
      final paths = _selectedNodes.map((node) => 
        _fileService.joinPath(_currentDirectory, node.name)
      ).toList();
      await _fileService.cutToClipboard(paths);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> paste() async {
    try {
      await _fileService.pasteFromClipboard(_currentDirectory);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Search functionality
  Future<List<FileExplorerNode>> search(String query) async {
    try {
      return await _fileService.search(_currentDirectory, query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get file type information
  String getFileType(String fileName) {
    return FileIconService.getFileType(fileName);
  }

  // Check if file is binary
  bool isBinaryFile(String fileName) {
    return _fileService.isBinaryFile(fileName);
  }

  // Get file icon based on type
  String getFileIcon(String fileName) {
    return FileIconService.getIconPath(fileName);
  }

  // Context menu
  void showContextMenu(Offset position, FileExplorerNode? node) {
    if (node != null) {
      selectNode(node);
    }
    // TODO: Show actual context menu UI
    notifyListeners();
  }

  void hideContextMenu() {
    _contextMenuActions.clear();
    notifyListeners();
  }

  void _updateContextMenuActions() {
    _contextMenuActions.clear();

    if (_selectedNodes.isEmpty) {
      // No selection - general actions
      _contextMenuActions.addAll([
        const ContextMenuAction(
          id: 'create_folder',
          title: 'Создать папку',
          icon: 'folder',
          type: ContextMenuActionType.newFolder,
          isEnabled: true,
        ),
        const ContextMenuAction(
          id: 'create_file',
          title: 'Создать файл',
          icon: 'file',
          type: ContextMenuActionType.newFile,
          isEnabled: true,
        ),
        const ContextMenuAction(
          id: 'paste',
          title: 'Вставить',
          icon: 'paste',
          type: ContextMenuActionType.copy,
          isEnabled: true,
        ),
        const ContextMenuAction(
          id: 'refresh',
          title: 'Обновить',
          icon: 'refresh',
          type: ContextMenuActionType.open,
          isEnabled: true,
        ),
      ]);
    } else {
      // Has selection - file/folder actions
      _contextMenuActions.addAll([
        const ContextMenuAction(
          id: 'open',
          title: 'Открыть',
          icon: 'open',
          type: ContextMenuActionType.open,
          isEnabled: true,
        ),
        const ContextMenuAction(
          id: 'rename',
          title: 'Переименовать',
          icon: 'edit',
          type: ContextMenuActionType.rename,
          isEnabled: true,
        ),
        const ContextMenuAction(
          id: 'copy',
          title: 'Копировать',
          icon: 'copy',
          type: ContextMenuActionType.copy,
          isEnabled: true,
        ),
        const ContextMenuAction(
          id: 'cut',
          title: 'Вырезать',
          icon: 'cut',
          type: ContextMenuActionType.copy,
          isEnabled: true,
        ),
        const ContextMenuAction(
          id: 'delete',
          title: 'Удалить',
          icon: 'delete',
          type: ContextMenuActionType.delete,
          isEnabled: true,
        ),
      ]);

      // Add specific actions based on selection
      if (_selectedNodes.length == 1 && _selectedNodes.first.isFolder) {
        _contextMenuActions.insert(
          1,
          const ContextMenuAction(
            id: 'open_in_terminal',
            title: 'Открыть в терминале',
            icon: 'terminal',
            type: ContextMenuActionType.open,
            isEnabled: true,
          ),
        );
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Sorting methods
  void setSortOption(SortOption option) {
    _sortOption = option;
    _sortCurrentPath();
    notifyListeners();
  }

  void toggleFoldersFirst() {
    _foldersFirst = !_foldersFirst;
    _sortCurrentPath();
    notifyListeners();
  }

  void _sortCurrentPath() {
    _currentPath = _sortNodes(_currentPath);
  }

  List<FileExplorerNode> _sortNodes(List<FileExplorerNode> nodes) {
    final sortedNodes = List<FileExplorerNode>.from(nodes);
    
    // Separate folders and files if foldersFirst is enabled
    final folders = sortedNodes.where((node) => node.isFolder).toList();
    final files = sortedNodes.where((node) => !node.isFolder).toList();
    
    // Sort folders
    switch (_sortOption) {
      case SortOption.nameAsc:
        folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        files.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        folders.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        files.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOption.typeAsc:
        folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        files.sort((a, b) {
          final aExt = _getFileExtension(a.name).toLowerCase();
          final bExt = _getFileExtension(b.name).toLowerCase();
          if (aExt != bExt) {
            return aExt.compareTo(bExt);
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case SortOption.typeDesc:
        folders.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        files.sort((a, b) {
          final aExt = _getFileExtension(a.name).toLowerCase();
          final bExt = _getFileExtension(b.name).toLowerCase();
          if (aExt != bExt) {
            return bExt.compareTo(aExt);
          }
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      case SortOption.dateAsc:
        folders.sort((a, b) => (a.modifiedTime ?? DateTime(0)).compareTo(b.modifiedTime ?? DateTime(0)));
        files.sort((a, b) => (a.modifiedTime ?? DateTime(0)).compareTo(b.modifiedTime ?? DateTime(0)));
        break;
      case SortOption.dateDesc:
        folders.sort((a, b) => (b.modifiedTime ?? DateTime(0)).compareTo(a.modifiedTime ?? DateTime(0)));
        files.sort((a, b) => (b.modifiedTime ?? DateTime(0)).compareTo(a.modifiedTime ?? DateTime(0)));
        break;
      case SortOption.sizeAsc:
        folders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        files.sort((a, b) => (a.size ?? 0).compareTo(b.size ?? 0));
        break;
      case SortOption.sizeDesc:
        folders.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        files.sort((a, b) => (b.size ?? 0).compareTo(a.size ?? 0));
        break;
    }
    
    // Combine folders and files based on foldersFirst setting
    if (_foldersFirst) {
      return [...folders, ...files];
    } else {
      return [...sortedNodes];
    }
  }

  String _getFileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    return lastDot != -1 ? fileName.substring(lastDot + 1) : '';
  }

  String getSortOptionTitle(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Имя (А-Я)';
      case SortOption.nameDesc:
        return 'Имя (Я-А)';
      case SortOption.typeAsc:
        return 'Тип (А-Я)';
      case SortOption.typeDesc:
        return 'Тип (Я-А)';
      case SortOption.dateAsc:
        return 'Дата (старые)';
      case SortOption.dateDesc:
        return 'Дата (новые)';
      case SortOption.sizeAsc:
        return 'Размер (возр.)';
      case SortOption.sizeDesc:
        return 'Размер (убыв.)';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Tree view state management
  
  // Toggle node expansion
  void toggleNodeExpansion(String nodePath) {
    _expandedNodes[nodePath] = !(_expandedNodes[nodePath] ?? false);
    
    // Load children if node is being expanded and children aren't loaded yet
    if (_expandedNodes[nodePath] == true && !_nodeChildren.containsKey(nodePath)) {
      _loadNodeChildren(nodePath);
    }
    
    notifyListeners();
  }
  
  // Check if node is expanded
  bool isNodeExpanded(String nodePath) {
    return _expandedNodes[nodePath] ?? false;
  }
  
  // Check if node is loading
  bool isNodeLoading(String nodePath) {
    return _loadingNodes[nodePath] ?? false;
  }
  
  // Get children for a node
  List<FileExplorerNode> getNodeChildren(String nodePath) {
    return _nodeChildren[nodePath] ?? [];
  }
  
  // Load children for a specific node
  Future<void> _loadNodeChildren(String nodePath) async {
    _loadingNodes[nodePath] = true;
    notifyListeners();
    
    try {
      final children = await getDirectoryContents(nodePath);
      _nodeChildren[nodePath] = children;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingNodes[nodePath] = false;
      notifyListeners();
    }
  }
  
  // Clear tree state (useful when changing directories)
  void clearTreeState() {
    _expandedNodes.clear();
    _nodeChildren.clear();
    _loadingNodes.clear();
    notifyListeners();
  }

  // Additional methods required by file_explorer_tree.dart
  
  // Load children for a specific node (for tree view)
  Future<List<FileExplorerNode>> loadChildren(FileExplorerNode node) async {
    try {
      final nodePath = _fileService.joinPath(_currentDirectory, node.name);
      return await getDirectoryContents(nodePath);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Copy a specific node
  Future<void> copyNode(FileExplorerNode node) async {
    try {
      final fullPath = _fileService.joinPath(_currentDirectory, node.name);
      await _fileService.copyToClipboard([fullPath]);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Cut a specific node
  Future<void> cutNode(FileExplorerNode node) async {
    try {
      final fullPath = _fileService.joinPath(_currentDirectory, node.name);
      await _fileService.cutToClipboard([fullPath]);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete a specific node
  Future<void> deleteNode(FileExplorerNode node) async {
    try {
      final fullPath = _fileService.joinPath(_currentDirectory, node.name);
      await _fileService.delete(fullPath, isFolder: node.isFolder);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

}
