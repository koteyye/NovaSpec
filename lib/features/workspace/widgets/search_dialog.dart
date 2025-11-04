import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/di_container.dart';
import '../../../core/services/clipboard_service.dart';

import '../providers/tab_provider.dart';
import '../models/file_explorer_node.dart';
import '../../../core/services/workspace_file_service.dart';

import '../../../shared/widgets/modern_button.dart';
import '../../../core/services/toast_service.dart';


class SearchDialog extends StatefulWidget {
  final String? initialPath;
  final Function(String)? onFileSelected;

  const SearchDialog({
    super.key,
    this.initialPath,
    this.onFileSelected,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<FileExplorerNode> _searchResults = [];
  bool _isSearching = false;
  bool _searchInContent = false;
  String _selectedPattern = 'name'; // name, extension, content
  String _lastQuery = '';

  // Паттерны поиска
  final List<SearchPattern> _patterns = [
    const SearchPattern(
      value: 'name',
      title: 'По имени',
      description: 'Искать по имени файла',
      icon: Icons.title,
    ),
    const SearchPattern(
      value: 'extension',
      title: 'По расширению',
      description: 'Искать по типу файла',
      icon: Icons.extension,
    ),
    const SearchPattern(
      value: 'content',
      title: 'По содержимому',
      description: 'Искать по содержимому файла',
      icon: Icons.description,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && query != _lastQuery) {
        _lastQuery = query;
        if (query.isNotEmpty) {
          _performSearch(query);
        } else {
          setState(() {
            _searchResults.clear();
          });
        }
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final clipboardService = getIt<ClipboardService>();
      final workspaceFileService = WorkspaceFileService(
        clipboardService: clipboardService,
      );

      List<FileExplorerNode> results = [];

      if (_selectedPattern == 'name' || _selectedPattern == 'extension') {
        // Поиск по имени или расширению
        results = await workspaceFileService.search(
          widget.initialPath ?? '',
          query,
        );
      } else if (_selectedPattern == 'content') {
        // Поиск по содержимому (упрощенная реализация)
        results = await _searchByContent(workspaceFileService, query);
      }

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        error(description: 'Ошибка поиска: $e');
      }
    }
  }

  Future<List<FileExplorerNode>> _searchByContent(
    WorkspaceFileService fileService,
    String query,
  ) async {
    // Упрощенная реализация поиска по содержимому
    // В реальном приложении здесь был бы индексированный поиск
    final results = <FileExplorerNode>[];
    
    try {
      // Получаем все файлы в директории
      final allFiles = await fileService.search(widget.initialPath ?? '', '');
      
      // Проверяем содержимое каждого текстового файла
      for (final file in allFiles) {
        if (file.isFolder) continue;
        
        // Проверяем, что это текстовый файл
        if (!fileService.isBinaryFile(file.name)) {
          try {
            final content = await fileService.readFile(file.path);
            if (content.toLowerCase().contains(query.toLowerCase())) {
              results.add(file);
            }
          } catch (e) {
            // Пропускаем файлы, которые не удалось прочитать
            continue;
          }
        }
      }
    } catch (e) {
      throw Exception('Ошибка поиска по содержимому: $e');
    }
    
    return results;
  }

  void _openFile(FileExplorerNode file) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.openTab(file.path, title: file.name);
    
    Navigator.of(context).pop();
    widget.onFileSelected?.call(file.path);
  }

  void _showFileInExplorer(FileExplorerNode file) {
    // TODO: Implement showing file in explorer
    Navigator.of(context).pop();
    success(description: 'Файл "${file.name}" найден');
  }

  @override
  Widget build(BuildContext context) {

    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Поиск файлов',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Поля поиска
            Row(
              children: [
                // Поле ввода
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Поиск',
                      hintText: 'Введите текст для поиска...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    autofocus: true,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Тип поиска
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPattern,
                    decoration: const InputDecoration(
                      labelText: 'Тип поиска',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.filter_list),
                    ),
                    items: _patterns.map((pattern) {
                      return DropdownMenuItem(
                        value: pattern.value,
                        child: Row(
                          children: [
                            Icon(pattern.icon, size: 16),
                            const SizedBox(width: 8),
                            Text(pattern.title),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPattern = value;
                        });
                        // Повторный поиск с новым паттерном
                        if (_searchController.text.trim().isNotEmpty) {
                          _performSearch(_searchController.text.trim());
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Опции поиска
            if (_selectedPattern == 'content') ...[
              Row(
                children: [
                  Checkbox(
                    value: _searchInContent,
                    onChanged: (value) {
                      setState(() {
                        _searchInContent = value ?? false;
                      });
                    },
                  ),
                  const Text('Искать в подкаталогах'),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Результаты поиска
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isSearching
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Поиск...'),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.trim().isEmpty
                                      ? 'Введите текст для поиска'
                                      : 'Ничего не найдено',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final file = _searchResults[index];
                              return _buildSearchResultItem(context, file);
                            },
                          ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Кнопки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_searchResults.length} результат(ов)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Row(
                  children: [
                    ModernButton(
                      text: 'Отмена',
                      type: ButtonType.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    ModernButton(
                      text: 'Найти',
                      type: ButtonType.primary,
                      onPressed: _searchController.text.trim().isEmpty
                          ? null
                          : () => _performSearch(_searchController.text.trim()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(BuildContext context, FileExplorerNode file) {
    return ListTile(
      leading: Icon(
        file.isFolder ? Icons.folder : Icons.insert_drive_file,
        color: file.isFolder 
            ? Colors.amber[600] 
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        file.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        file.path,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            onPressed: () => _openFile(file),
            tooltip: 'Открыть файл',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open, size: 20),
            onPressed: () => _showFileInExplorer(file),
            tooltip: 'Показать в проводнике',
          ),
        ],
      ),
      onTap: () => _openFile(file),
    );
  }
}

class SearchPattern {
  final String value;
  final String title;
  final String description;
  final IconData icon;

  const SearchPattern({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Вспомогательный метод для показа диалога
class SearchDialogHelper {
  static Future<String?> showSearchDialog(
    BuildContext context, {
    String? initialPath,
    Function(String)? onFileSelected,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => SearchDialog(
        initialPath: initialPath,
        onFileSelected: onFileSelected,
      ),
    );
  }
}
