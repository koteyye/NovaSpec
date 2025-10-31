import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_provider.dart';
import '../models/workspace_tab.dart';
import 'file_renderers/markdown_renderer.dart';
import 'file_renderers/code_editor.dart';
import 'file_renderers/html_renderer.dart';
import 'file_renderers/audio_player.dart';
import 'file_renderers/swagger_viewer.dart';
import 'file_renderers/image_viewer.dart';
import 'file_renderers/pdf_viewer.dart';
import 'file_renderers/video_viewer.dart';
import 'file_renderers/unsupported_file_viewer.dart';
import '../../../core/services/workspace_file_service.dart';
import '../../../core/services/clipboard_service.dart';

class WorkArea extends StatefulWidget {
  const WorkArea({super.key});

  @override
  State<WorkArea> createState() => _WorkAreaState();
}

class _WorkAreaState extends State<WorkArea> {
  final Set<String> _forceLoadedFiles = <String>{};

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, child) {
        final activeTab = tabProvider.activeTab;
        
        if (activeTab == null) {
          return _buildEmptyState(context);
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет открытых файлов',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Откройте файл для начала работы',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
          Expanded(
            child: _buildEditorContent(context, activeTab),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorToolbar(BuildContext context, WorkspaceTab activeTab) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
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
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 16),
                onPressed: () {
                  // TODO: Redo
                },
                tooltip: 'Повторить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              Container(
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Theme.of(context).dividerColor,
              ),
              IconButton(
                icon: const Icon(Icons.save, size: 16),
                onPressed: () {
                  // TODO: Save file
                },
                tooltip: 'Сохранить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.find_replace, size: 16),
                onPressed: () {
                  // TODO: Find and replace
                },
                tooltip: 'Найти и заменить',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
              Container(
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Theme.of(context).dividerColor,
              ),
              // View mode selector
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.visibility,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                padding: EdgeInsets.zero,
                onSelected: (mode) {
                  // TODO: Switch view mode
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editor',
                    child: Row(
                      children: [
                        Icon(Icons.code, size: 16),
                        SizedBox(width: 8),
                        Text('Редактор'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.preview, size: 16),
                        SizedBox(width: 8),
                        Text('Предпросмотр'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'split',
                    child: Row(
                      children: [
                        Icon(Icons.view_column, size: 16),
                        SizedBox(width: 8),
                        Text('Разделенный вид'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditorContent(BuildContext context, WorkspaceTab activeTab) {
    return FutureBuilder<String>(
      future: _getFileContent(activeTab.path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        final content = snapshot.data ?? '';
        final workspaceFileService = WorkspaceFileService(
          clipboardService: ClipboardService(),
        );
        final fileType = workspaceFileService.getFileType(activeTab.path);

        return FutureBuilder<int>(
          future: workspaceFileService.getFileSize(activeTab.path),
          builder: (context, sizeSnapshot) {
            final fileSize = sizeSnapshot.data ?? 0;
            return _buildFileRenderer(context, activeTab, content, fileType, fileSize);
          },
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка файла...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки файла',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFileRenderer(
    BuildContext context,
    WorkspaceTab activeTab,
    String content,
    String fileType,
    int fileSize,
  ) {
    // Show loading indicator for large files (>10MB)
    if (fileSize > 10 * 1024 * 1024 && !_forceLoadedFiles.contains(activeTab.id)) {
      return _buildLargeFileLoading(context, activeTab, content, fileType, fileSize);
    }

    switch (fileType) {
      // Web technologies
      case 'html':
      case 'htm':
        return HtmlRenderer(
          filePath: activeTab.path,
          content: content,
        );
        
      case 'css':
      case 'scss':
      case 'sass':
      case 'less':
        return CodeEditor(
          filePath: activeTab.path,
          content: content,
        );
        
      case 'vue':
      case 'jsx':
      case 'tsx':
        return CodeEditor(
          filePath: activeTab.path,
          content: content,
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
        return CodeEditor(
          filePath: activeTab.path,
          content: content,
        );
        
      // Data formats
      case 'json':
      case 'xml':
      case 'yaml':
      case 'yml':
      case 'toml':
      case 'ini':
      case 'csv':
      case 'tsv':
        return CodeEditor(
          filePath: activeTab.path,
          content: content,
        );
        
      // Documentation
      case 'markdown':
      case 'md':
      case 'text':
      case 'txt':
      case 'rst':
      case 'asciidoc':
        if (fileType == 'markdown' || fileType == 'md') {
          return MarkdownRenderer(
            filePath: activeTab.path,
            content: content,
          );
        }
        return CodeEditor(
          filePath: activeTab.path,
          content: content,
        );
        
      // Configuration
      case 'config':
      case 'conf':
      case 'env':
      case 'dockerfile':
      case 'gitignore':
      case 'eslint':
      case 'prettier':
      case 'babel':
        return CodeEditor(
          filePath: activeTab.path,
          content: content,
        );
        
      // Special files
      case 'makefile':
      case 'readme':
      case 'license':
      case 'changelog':
        return CodeEditor(
          filePath: activeTab.path,
          content: content,
        );
        
      // API/Swagger files
      case 'swagger':
      case 'openapi':
        return SwaggerViewer(
          filePath: activeTab.path,
          content: content,
        );
        
      // Media files
      case 'audio':
        return AudioPlayerWidget(
          filePath: activeTab.path,
          fileName: activeTab.title,
        );
        
      case 'image':
        return ImageViewer(
          filePath: activeTab.path,
          fileName: activeTab.fileName,
        );
        
      case 'video':
        return VideoViewer(
          filePath: activeTab.path,
          fileName: activeTab.fileName,
        );
        
      // Documents
      case 'document':
        // Check if it's a PDF file
        if (activeTab.fileName.toLowerCase().endsWith('.pdf')) {
          return PdfViewer(
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
        return UnsupportedFileViewer(
          filePath: activeTab.path,
          content: content,
          fileSize: fileSize,
        );
    }
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

  Future<String> _getFileContent(String filePath) async {
    try {
      final workspaceFileService = WorkspaceFileService(
        clipboardService: ClipboardService(),
      );
      return await workspaceFileService.readFile(filePath);
    } catch (e) {
      throw Exception('Не удалось прочитать файл: $e');
    }
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
          Text(
            activeTab.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Интеграция с просмотрщиком документов будет добавлена в следующей версии',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
          Text(
            'Архив',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            activeTab.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Интеграция с архиватором будет добавлена в следующей версии',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
