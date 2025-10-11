import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/providers/project_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Виджет элемента дерева файлов
class FileTreeItem extends ConsumerStatefulWidget {
  final FileSystemEntity entity;
  final int level;

  const FileTreeItem({
    super.key,
    required this.entity,
    required this.level,
  });

  @override
  ConsumerState<FileTreeItem> createState() => _FileTreeItemState();
}

class _FileTreeItemState extends ConsumerState<FileTreeItem> {
  bool _isExpanded = false;
  List<FileSystemEntity>? _children;

  @override
  void initState() {
    super.initState();
    if (widget.entity is Directory) {
      _loadChildren();
    }
  }

  Future<void> _loadChildren() async {
    if (widget.entity is! Directory) return;

    try {
      final dir = widget.entity as Directory;
      final entities = await dir.list().toList();

      // Сортируем: сначала папки, потом файлы
      entities.sort((a, b) {
        final aIsDir = a is Directory;
        final bIsDir = b is Directory;

        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;

        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      if (mounted) {
        setState(() {
          _children = entities;
        });
      }
    } catch (e) {
      // Ignore errors (permissions, etc.)
    }
  }

  IconData _getIcon() {
    if (widget.entity is Directory) {
      return _isExpanded ? Icons.folder_open : Icons.folder;
    }

    final ext = path.extension(widget.entity.path).toLowerCase();
    switch (ext) {
      case '.md':
      case '.markdown':
        return Icons.description_outlined;
      case '.txt':
        return Icons.text_snippet_outlined;
      case '.pdf':
        return Icons.picture_as_pdf_outlined;
      case '.json':
      case '.yaml':
      case '.yml':
        return Icons.code;
      case '.mp3':
      case '.wav':
      case '.ogg':
        return Icons.music_note_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.entity is Directory) {
      return isDark ? NsColorsDark.primary : NsColorsLight.primary;
    }

    final ext = path.extension(widget.entity.path).toLowerCase();

    // Using semantic colors for different file types
    switch (ext) {
      case '.md':
      case '.markdown':
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6); // Blue
      case '.txt':
        return isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280); // Gray
      case '.pdf':
        return isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444); // Red
      case '.json':
      case '.yaml':
      case '.yml':
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B); // Yellow
      case '.mp3':
      case '.wav':
      case '.ogg':
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6); // Purple
      default:
        return isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground;
    }
  }

  void _onTap() {
    if (widget.entity is Directory) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    } else {
      // Open file
      ref.read(projectProvider.notifier).openFile(widget.entity.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = path.basename(widget.entity.path);
    final isDirectory = widget.entity is Directory;

    // Hide hidden files/folders (starting with .)
    if (fileName.startsWith('.')) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _onTap,
          child: Container(
            padding: EdgeInsets.only(
              left: NsSpacing.sm + (widget.level * 16.0),
              right: NsSpacing.sm,
              top: 6,
              bottom: 6,
            ),
            child: Row(
              children: [
                if (isDirectory) ...[
                  Icon(
                    _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                    size: 20,
                    color: isDark
                        ? NsColorsDark.mutedForeground
                        : NsColorsLight.mutedForeground,
                  ),
                ] else ...[
                  const SizedBox(width: 20),
                ],
                const SizedBox(width: 4),
                Icon(
                  _getIcon(),
                  size: 16,
                  color: _getIconColor(context),
                ),
                const SizedBox(width: NsSpacing.sm),
                Expanded(
                  child: Text(
                    fileName,
                    style: NsTextStyles.bodySmall(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isDirectory && _isExpanded && _children != null)
          ...(_children!.map((child) => FileTreeItem(
                entity: child,
                level: widget.level + 1,
              ))),
      ],
    );
  }
}
