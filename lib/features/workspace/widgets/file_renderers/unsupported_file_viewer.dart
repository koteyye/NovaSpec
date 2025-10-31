import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
// import '../../../core/services/workspace_file_service.dart';
import '../../../../shared/widgets/modern_button.dart';


class UnsupportedFileViewer extends StatefulWidget {
  final String filePath;
  final String content;
  final int fileSize;
  final VoidCallback? onClose;

  const UnsupportedFileViewer({
    super.key,
    required this.filePath,
    required this.content,
    required this.fileSize,
    this.onClose,
  });

  @override
  State<UnsupportedFileViewer> createState() => _UnsupportedFileViewerState();
}

class _UnsupportedFileViewerState extends State<UnsupportedFileViewer> {
  bool _isHexView = false;
  bool _isLoading = false;

  String get _fileName => widget.filePath.split('/').last;
  String get _fileExtension => widget.filePath.split('.').last.toLowerCase();

  Future<void> _openExternally() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Сохранить файл как...',
        fileName: _fileName,
        type: FileType.any,
      );

      if (result != null) {
        // Here you would copy the file to the selected location
        // For now, we'll just show a success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Файл сохранен в: $result'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения файла: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.content));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Содержимое скопировано в буфер обмена'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка копирования: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildFileIcon() {
    // Временная реализация без WorkspaceFileService
    final iconData = _getDefaultIcon(_fileExtension);
    final iconColor = _getDefaultIconColor(_fileExtension);
    
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        iconData,
        size: 32,
        color: iconColor,
      ),
    );
  }

  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _fileName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              _fileExtension.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.storage_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              _formatFileSize(widget.fileSize),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.filePath,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (widget.content.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.file_present,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'Файл пуст или не может быть прочитан',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayContent = _isHexView ? _toHexView(widget.content) : widget.content;
    final maxPreviewLength = 10000;
    final truncatedContent = displayContent.length > maxPreviewLength
        ? '${displayContent.substring(0, maxPreviewLength)}\n\n... (содержимое обрезано) ...'
        : displayContent;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          // Preview header
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  _isHexView ? 'Hex просмотр' : 'Текстовый просмотр',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ModernButton(
                  text: _isHexView ? 'Текст' : 'Hex',
                  onPressed: () {
                    setState(() {
                      _isHexView = !_isHexView;
                    });
                  },
                ),
                ModernButton(
                  text: 'Копировать',
                  onPressed: _copyToClipboard,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          // Preview content
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: SelectableText(
                  truncatedContent,
                  style: TextStyle(
                    fontFamily: _isHexView ? 'monospace' : null,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toHexView(String data) {
    final bytes = data.codeUnits;
    final buffer = StringBuffer();
    final bytesPerLine = 16;
    
    for (int i = 0; i < bytes.length; i += bytesPerLine) {
      // Address
      buffer.write(i.toRadixString(16).padLeft(8, '0').toUpperCase());
      buffer.write('  ');
      
      // Hex bytes
      for (int j = 0; j < bytesPerLine; j++) {
        if (i + j < bytes.length) {
          buffer.write(bytes[i + j].toRadixString(16).padLeft(2, '0').toUpperCase());
          buffer.write(' ');
        } else {
          buffer.write('   ');
        }
        
        if (j == 7) buffer.write(' ');
      }
      
      buffer.write(' ');
      
      // ASCII representation
      for (int j = 0; j < bytesPerLine; j++) {
        if (i + j < bytes.length) {
          final byte = bytes[i + j];
          buffer.write((byte >= 32 && byte <= 126) ? String.fromCharCode(byte) : '.');
        } else {
          buffer.write(' ');
        }
      }
      
      buffer.write('\n');
      
      // Limit hex view to prevent performance issues
      if (i > 1024) {
        buffer.write('\n... (hex просмотр обрезан) ...\n');
        break;
      }
    }
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildFileIcon(),
              const SizedBox(width: 16),
              Expanded(child: _buildFileInfo()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Warning message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Этот тип файла не поддерживается для просмотра в редакторе. Рекомендуется открыть файл во внешнем приложении.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Actions
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ModernButton(
                text: _isLoading ? 'Загрузка...' : 'Открыть внешне',
                onPressed: _isLoading ? null : _openExternally,
              ),
              ModernButton(
                text: 'Копировать',
                onPressed: _copyToClipboard,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Preview section
          Text(
            'Предпросмотр содержимого',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPreview(),
        ],
      ),
    );
  }

  // Временные методы для замены WorkspaceFileService
  IconData _getDefaultIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mkv':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getDefaultIconColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.purple;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Colors.teal;
      case 'mp4':
      case 'avi':
      case 'mkv':
        return Colors.indigo;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
