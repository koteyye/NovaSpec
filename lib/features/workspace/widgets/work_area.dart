import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/tab_provider.dart';
import '../models/workspace_tab.dart';
import '../viewers/markdown_viewer_simple.dart';
import '../viewers/code_editor_simple.dart';
import '../viewers/html_viewer_simple.dart';
import '../viewers/audio_player_simple.dart';
import '../viewers/swagger_viewer_simple.dart';
import 'file_renderers/image_viewer.dart';
import 'file_renderers/pdf_viewer.dart';
import 'file_renderers/video_viewer.dart';
import '../../../core/services/workspace_file_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../core/services/toast_service.dart';
import '../../musication/widgets/musication_button.dart';
import '../../project/providers/project_provider.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  State<WorkArea> createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  final Set<String> _forceLoadedFiles = <String>{};
  int _currentFileSize = 0;

  // Кэшируем сервис и результаты проверок
  late final WorkspaceFileService _workspaceFileService;
  final Map<String, String> _fileTypeCache = {};
  final Map<String, int> _fileSizeCache = {};
  String? _lastActiveTabId;

  // Режим просмотра для редактируемых файлов (markdown, html, swagger)
  final Map<String, bool> _editModeCache = {}; // true = edit, false = render

  // Отслеживание изменённого контента
  final Map<String, String> _modifiedContentCache = {};
  final Map<String, bool> _hasUnsavedChanges = {};

  @override
  void initState() {
    super.initState();
    _workspaceFileService = WorkspaceFileService(
      clipboardService: ClipboardService(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, child) {
        final activeTab = tabProvider.activeTab;

        if (activeTab == null) {
          return _buildEmptyState(context);
        }

        // Очищаем кэш при смене вкладки
        if (_lastActiveTabId != activeTab.id) {
          _fileTypeCache.clear();
          _fileSizeCache.clear();
          _lastActiveTabId = activeTab.id;
        }

        // Инициализируем режим просмотра для новой вкладки если его нет
        if (!_editModeCache.containsKey(activeTab.id)) {
          _editModeCache[activeTab.id] = false; // По умолчанию режим рендера
        }

        return _buildWorkArea(context, activeTab);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет открытых файлов',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Откройте файл для начала работы',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkArea(BuildContext context, WorkspaceTab activeTab) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Editor toolbar
          _buildEditorToolbar(context, activeTab),

          // Editor content based on file type
          Expanded(child: _buildEditorContent(context, activeTab)),
        ],
      ),
    );
  }

  Widget _buildEditorToolbar(BuildContext context, WorkspaceTab activeTab) {
    // Проверяем, поддерживает ли файл переключение режимов
    final fileType = _fileTypeCache[activeTab.path];
    final supportsToggle =
        fileType == 'html' || fileType == 'markdown' || fileType == 'swagger';
    final isEditMode = _editModeCache[activeTab.id] ?? false;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // File info
          Row(
            children: [
              const SizedBox(width: 8),
              Icon(
                _getFileIcon(activeTab.path),
                size: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                activeTab.fileName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (activeTab.isModified) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.circle,
                  size: 6,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  activeTab.language?.toUpperCase() ?? 'TEXT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _formatFileSize(_currentFileSize),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Editor actions
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo, size: 16),
                onPressed: () {
                  // TODO: Undo
                },
                tooltip: 'Отменить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 16),
                onPressed: () {
                  // TODO: Redo
                },
                tooltip: 'Повторить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              Container(
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Theme.of(context).dividerColor,
              ),
              IconButton(
                icon: Icon(
                  Icons.save,
                  size: 16,
                  color: (_hasUnsavedChanges[activeTab.id] ?? false)
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: (_hasUnsavedChanges[activeTab.id] ?? false)
                    ? () => _saveFile(activeTab)
                    : null,
                tooltip: 'Сохранить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              IconButton(
                icon: const Icon(Icons.find_replace, size: 16),
                onPressed: () {
                  // TODO: Find and replace
                },
                tooltip: 'Найти и заменить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              // Кнопка переключения режима (только для поддерживаемых файлов)
              if (supportsToggle) ...[
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: Theme.of(context).dividerColor,
                ),
                IconButton(
                  icon: Icon(isEditMode ? Icons.preview : Icons.code, size: 16),
                  onPressed: () {
                    setState(() {
                      _editModeCache[activeTab.id] = !isEditMode;
                    });
                  },
                  tooltip: isEditMode ? 'Предпросмотр' : 'Редактор',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],

              // Кнопка музикации для .md и .html файлов
              if (activeTab.path.endsWith('.md') || activeTab.path.endsWith('.html')) ...[
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: Theme.of(context).dividerColor,
                ),
                Consumer<ProjectProvider>(
                  builder: (context, projectProvider, _) {
                    return MusicationButton(
                      projectPath: projectProvider.currentProject?.directory ?? '',
                      selectedText: '', // TODO: получить выделенный текст из Monaco Editor
                      filePath: activeTab.path,
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditorContent(BuildContext context, WorkspaceTab activeTab) {
    // Используем кэшированный сервис
    final baseFileType = _workspaceFileService.getFileType(activeTab.path);

    // Проверяем кэш для типа файла
    final cacheKey = activeTab.path;
    if (_fileTypeCache.containsKey(cacheKey) &&
        _fileSizeCache.containsKey(cacheKey)) {
      // Используем кэшированные значения
      final fileType = _fileTypeCache[cacheKey]!;
      final fileSize = _fileSizeCache[cacheKey]!;

      // Проверяем режим просмотра
      final isEditMode = _editModeCache[activeTab.id] ?? false;

      return _buildFileRenderer(
        context,
        activeTab,
        '', // content не используется в simple viewers
        fileType,
        fileSize,
        isEditMode,
      );
    }

    // Если нет в кэше, загружаем один раз
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadFileMetadata(activeTab.path, baseFileType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Ошибка загрузки файла: ${snapshot.error}'),
          );
        }

        final metadata = snapshot.data!;
        final fileType = metadata['fileType'] as String;
        final fileSize = metadata['fileSize'] as int;

        // Сохраняем в кэш
        _fileTypeCache[cacheKey] = fileType;
        _fileSizeCache[cacheKey] = fileSize;

        // Обновляем toolbar с размером файла
        if (_currentFileSize != fileSize) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentFileSize = fileSize;
              });
            }
          });
        }

        // Проверяем режим просмотра
        final isEditMode = _editModeCache[activeTab.id] ?? false;

        return _buildFileRenderer(
          context,
          activeTab,
          '', // content не используется в simple viewers
          fileType,
          fileSize,
          isEditMode,
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadFileMetadata(
    String filePath,
    String baseFileType,
  ) async {
    final fileType = await _checkForOpenApi(
      filePath,
      baseFileType,
      _workspaceFileService,
    );
    final fileSize = await _workspaceFileService.getFileSize(filePath);

    return {'fileType': fileType, 'fileSize': fileSize};
  }

  Future<String> _checkForOpenApi(
    String filePath,
    String baseFileType,
    WorkspaceFileService fileService,
  ) async {
    // Проверяем только JSON и YAML файлы
    if (baseFileType != 'json' && baseFileType != 'yaml') {
      return baseFileType;
    }

    try {
      final content = await fileService.readFile(filePath);
      // Проверяем наличие поля openapi в начале файла (первые 500 символов)
      final preview = content.length > 500
          ? content.substring(0, 500)
          : content;
      if (preview.contains('openapi:') ||
          preview.contains('"openapi"') ||
          preview.contains('swagger:') ||
          preview.contains('"swagger"')) {
        return 'swagger';
      }
    } catch (e) {
      // Ignore errors in OpenAPI detection
    }

    return baseFileType;
  }

  Widget _buildFileRenderer(
    BuildContext context,
    WorkspaceTab activeTab,
    String content,
    String fileType,
    int fileSize,
    bool isEditMode,
  ) {
    // Show loading indicator for large files (>10MB)
    if (fileSize > 10 * 1024 * 1024 &&
        !_forceLoadedFiles.contains(activeTab.id)) {
      return _buildLargeFileLoading(
        context,
        activeTab,
        content,
        fileType,
        fileSize,
      );
    }

    switch (fileType) {
      // Web technologies
      case 'html':
        if (isEditMode) {
          return CodeEditorSimple(
            key: ValueKey('${activeTab.path}_edit'),
            filePath: activeTab.path,
            onContentChanged: (content) =>
                _onContentChanged(activeTab, content),
          );
        }
        return HtmlViewerSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      case 'css':
      case 'scss':
      case 'less':
      case 'vue':
      case 'jsx':
      case 'tsx':
        return CodeEditorSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      // Programming languages
      case 'dart':
      case 'javascript':
      case 'typescript':
      case 'python':
      case 'java':
      case 'cpp':
      case 'c':
      case 'csharp':
      case 'php':
      case 'ruby':
      case 'go':
      case 'rust':
      case 'swift':
      case 'kotlin':
      case 'scala':
      case 'r':
      case 'sql':
      case 'shell':
      case 'powershell':
      case 'batch':
        return CodeEditorSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      // Data formats
      case 'json':
      case 'xml':
      case 'yaml':
      case 'toml':
      case 'ini':
      case 'csv':
      case 'tsv':
        return CodeEditorSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      // Documentation
      case 'markdown':
        if (isEditMode) {
          return CodeEditorSimple(
            key: ValueKey('${activeTab.path}_edit'),
            filePath: activeTab.path,
            onContentChanged: (content) =>
                _onContentChanged(activeTab, content),
          );
        }
        return MarkdownViewerSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      case 'text':
      case 'rst':
      case 'asciidoc':
        return CodeEditorSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      // Configuration
      case 'config':
      case 'env':
      case 'dockerfile':
      case 'gitignore':
      case 'eslint':
      case 'prettier':
      case 'babel':
        return CodeEditorSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      // Special files
      case 'makefile':
      case 'readme':
      case 'license':
      case 'changelog':
        return CodeEditorSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      // API/Swagger files
      case 'swagger':
        if (isEditMode) {
          return CodeEditorSimple(
            key: ValueKey('${activeTab.path}_edit'),
            filePath: activeTab.path,
            onContentChanged: (content) =>
                _onContentChanged(activeTab, content),
          );
        }
        return SwaggerViewerSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      // Media files
      case 'audio':
        return AudioPlayerSimple(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
        );

      case 'image':
        return ImageViewer(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
          fileName: activeTab.fileName,
        );

      case 'video':
        return VideoViewer(
          key: ValueKey(activeTab.path),
          filePath: activeTab.path,
          fileName: activeTab.fileName,
        );

      // Documents
      case 'document':
        // Check if it's a PDF file
        if (activeTab.fileName.toLowerCase().endsWith('.pdf')) {
          return PdfViewer(
            key: ValueKey(activeTab.path),
            filePath: activeTab.path,
            fileName: activeTab.fileName,
          );
        }
        return _buildDocumentViewer(context, activeTab);

      // Archives
      case 'archive':
        return _buildArchiveViewer(context, activeTab);

      case 'unknown':
      default:
        debugPrint('Returning minimal unsupported file view (unknown/default)');
        debugPrint('================================');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Неподдерживаемый формат',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  activeTab.fileName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(fileSize),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  void _onContentChanged(WorkspaceTab activeTab, String content) {
    setState(() {
      _modifiedContentCache[activeTab.id] = content;
      _hasUnsavedChanges[activeTab.id] = true;
    });

    // Обновляем индикатор изменений в TabProvider
    final tabProvider = context.read<TabProvider>();
    tabProvider.markTabModified(activeTab.id, true);
  }

  Future<void> _saveFile(WorkspaceTab activeTab) async {
    final content = _modifiedContentCache[activeTab.id];
    if (content == null) return;

    try {
      final file = File(activeTab.path);
      await file.writeAsString(content);

      if (!mounted) return;

      setState(() {
        _hasUnsavedChanges[activeTab.id] = false;
      });

      // Обновляем индикатор изменений в TabProvider
      final tabProvider = context.read<TabProvider>();
      await tabProvider.markTabModified(activeTab.id, false);

      success(description: 'Файл сохранён: ${activeTab.fileName}');
    } catch (e) {
      if (!mounted) return;
      error(description: 'Ошибка сохранения: ${e.toString()}');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildLargeFileLoading(
    BuildContext context,
    WorkspaceTab activeTab,
    String content,
    String fileType,
    int fileSize,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.file_download,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Загрузка большого файла',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            activeTab.fileName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Файл загружается, пожалуйста подождите...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _closeTab(activeTab.id);
                },
                icon: const Icon(Icons.close),
                label: const Text('Закрыть'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Force load the file anyway
                  if (mounted) {
                    setState(() {
                      _forceLoadedFiles.add(activeTab.id);
                    });
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Загрузить всё равно'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _closeTab(String tabId) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    tabProvider.closeTab(tabId);
  }

  Widget _buildDocumentViewer(BuildContext context, WorkspaceTab activeTab) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Просмотр документа',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(activeTab.title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(
            'Интеграция с просмотрщиком документов будет добавлена в следующей версии',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveViewer(BuildContext context, WorkspaceTab activeTab) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('Архив', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(activeTab.title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(
            'Интеграция с архиватором будет добавлена в следующей версии',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'dart':
        return Icons.code;
      case 'js':
        return Icons.javascript;
      case 'ts':
        return Icons.code;
      case 'py':
        return Icons.psychology;
      case 'java':
        return Icons.coffee;
      case 'html':
        return Icons.web;
      case 'css':
        return Icons.palette;
      case 'json':
        return Icons.data_object;
      case 'md':
        return Icons.description;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'svg':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }
}
