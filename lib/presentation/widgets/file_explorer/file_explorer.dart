import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/presentation/providers/project_provider.dart';
import 'package:novaspec/presentation/widgets/file_explorer/file_tree_item.dart';
import 'package:novaspec/domain/services/file_service.dart';
import 'dart:io';

/// Провайдер для работы с деревом файлов
final fileTreeProvider = StateNotifierProvider<FileTreeNotifier, FileTreeState>((ref) {
  final projectState = ref.watch(projectProvider);

  // Создаем notifier
  final notifier = FileTreeNotifier(projectState.projectPath);

  // Подписываемся на изменения lastSavedAt для автообновления
  ref.listen(projectProvider.select((state) => state.lastSavedAt), (previous, next) {
    if (next != null) {
      notifier.refresh();
    }
  });

  return notifier;
});

/// Состояние дерева файлов
class FileTreeState {
  final List<FileSystemEntity> files;
  final bool isLoading;

  const FileTreeState({
    this.files = const [],
    this.isLoading = false,
  });

  FileTreeState copyWith({
    List<FileSystemEntity>? files,
    bool? isLoading,
  }) {
    return FileTreeState(
      files: files ?? this.files,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier для управления деревом файлов
class FileTreeNotifier extends StateNotifier<FileTreeState> {
  final String? projectPath;
  final _fileService = FileService();

  FileTreeNotifier(this.projectPath) : super(const FileTreeState()) {
    if (projectPath != null) {
      loadFiles();
    }
  }

  Future<void> loadFiles() async {
    if (projectPath == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final entities = await _fileService.scanDirectory(projectPath!);

      state = state.copyWith(
        files: entities,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadFiles();
  }
}

/// FileExplorer виджет
class FileExplorer extends ConsumerWidget {
  const FileExplorer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectState = ref.watch(projectProvider);
    final fileTreeState = ref.watch(fileTreeProvider);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.sidebar : NsColorsLight.sidebar,
        border: Border(
          right: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(NsSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? NsColorsDark.border : NsColorsLight.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                ),
                const SizedBox(width: NsSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectState.projectName ?? 'No Project',
                        style: NsTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (projectState.projectPath != null)
                        Text(
                          'Explorer',
                          style: NsTextStyles.bodySmall(context).copyWith(
                            color: isDark
                                ? NsColorsDark.mutedForeground
                                : NsColorsLight.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: () {
                    ref.read(fileTreeProvider.notifier).refresh();
                  },
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // File tree
          Expanded(
            child: projectState.projectPath == null
                ? Center(
                    child: Text(
                      'No project opened',
                      style: NsTextStyles.bodyMedium(context).copyWith(
                        color: isDark
                            ? NsColorsDark.mutedForeground
                            : NsColorsLight.mutedForeground,
                      ),
                    ),
                  )
                : fileTreeState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : fileTreeState.files.isEmpty
                        ? Center(
                            child: Text(
                              'Empty project',
                              style: NsTextStyles.bodyMedium(context).copyWith(
                                color: isDark
                                    ? NsColorsDark.mutedForeground
                                    : NsColorsLight.mutedForeground,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: NsSpacing.sm),
                            itemCount: fileTreeState.files.length,
                            itemBuilder: (context, index) {
                              return FileTreeItem(
                                entity: fileTreeState.files[index],
                                level: 0,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
