import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';
import 'package:novaspec/data/data_sources/local/hive_data_source.dart';
import 'package:novaspec/data/repositories/config_repository.dart';
import 'package:novaspec/presentation/providers/project_provider.dart';
import 'package:novaspec/presentation/widgets/spec_preview/markdown_renderer.dart';
import 'package:novaspec/presentation/widgets/spec_preview/html_renderer.dart';
import 'package:novaspec/presentation/widgets/spec_preview/text_editor.dart';
import 'package:novaspec/presentation/widgets/spec_preview/audio_player_widget.dart';
import 'package:novaspec/presentation/widgets/dialogs/musicify_dialog.dart';

/// Режимы отображения
enum ViewMode {
  preview,
  edit,
  split,
}

/// SpecPreview виджет
class SpecPreview extends ConsumerStatefulWidget {
  const SpecPreview({super.key});

  @override
  ConsumerState<SpecPreview> createState() => _SpecPreviewState();
}

class _SpecPreviewState extends ConsumerState<SpecPreview> {
  ViewMode _viewMode = ViewMode.preview;
  bool _isMusicifyEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkMusicifyEnabled();
  }

  /// Проверить, включена ли музикация
  Future<void> _checkMusicifyEnabled() async {
    final configRepository = ConfigRepository(HiveDataSource());
    final isEnabled = await configRepository.isMusicConfigured();
    if (mounted) {
      setState(() {
        _isMusicifyEnabled = isEnabled;
      });
    }
  }

  /// Определить, является ли файл HTML
  bool _isHtmlFile(String? filePath) {
    if (filePath == null) return false;
    final extension = filePath.split('.').last.toLowerCase();
    return extension == 'html' || extension == 'htm';
  }

  /// Определить, является ли файл Markdown
  bool _isMarkdownFile(String? filePath) {
    if (filePath == null) return false;
    final extension = filePath.split('.').last.toLowerCase();
    return extension == 'md' || extension == 'markdown';
  }

  /// Определить, является ли файл аудио
  bool _isAudioFile(String? filePath) {
    if (filePath == null) return false;
    final extension = filePath.split('.').last.toLowerCase();
    return extension == 'mp3' || extension == 'wav' || extension == 'ogg' || extension == 'm4a';
  }

  /// Проверить, можно ли музицировать текущий файл
  bool _canMusicifyCurrentFile(String? filePath) {
    return _isMusicifyEnabled &&
           (_isMarkdownFile(filePath) || _isHtmlFile(filePath));
  }

  /// Открыть диалог музикации
  Future<void> _showMusicifyDialog(BuildContext context, String fileName) async {
    final result = await MusicifyDialog.show(
      context,
      fileName: fileName,
    );

    if (result == true) {
      if (!mounted) return;
      
      // TODO: Запустить процесс музикации
      // Это будет реализовано позже в соответствующих задачах
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Музикация запущена (функционал будет добавлен позже)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectState = ref.watch(projectProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () async {
          await ref.read(projectProvider.notifier).saveCurrentFile();
        },
      },
      child: Focus(
        autofocus: true,
        child: Container(
          color: isDark ? NsColorsDark.editor : NsColorsLight.editor,
          child: Column(
            children: [
              // Tab bar (если есть открытые файлы)
              if (projectState.openedFiles.isNotEmpty)
                _buildTabBar(context, isDark, projectState),

              // Toolbar
              _buildToolbar(context, isDark, projectState),

              // Content area
              Expanded(
                child: projectState.activeFile == null
                    ? _buildEmptyState(context, isDark)
                    : _buildContent(context, isDark, projectState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, bool isDark, ProjectState projectState) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NsSpacing.md,
        vertical: NsSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.panel : NsColorsLight.panel,
        border: Border(
          bottom: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: Row(
        children: [
          // File name (активный файл)
          if (projectState.activeFile != null) ...[
            Icon(
              Icons.description_outlined,
              size: 16,
              color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
            ),
            const SizedBox(width: NsSpacing.sm),
            Expanded(
              child: Text(
                projectState.activeFile!.fileName,
                style: NsTextStyles.bodyMedium(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (projectState.activeFile!.hasUnsavedChanges) ...[
              const SizedBox(width: NsSpacing.xs),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            const SizedBox(width: NsSpacing.md),
          ],

          // View mode buttons
          _buildViewModeButton(
            context,
            isDark,
            Icons.visibility_outlined,
            ViewMode.preview,
            'Preview',
          ),
          const SizedBox(width: NsSpacing.xs),
          _buildViewModeButton(
            context,
            isDark,
            Icons.edit_outlined,
            ViewMode.edit,
            'Edit',
          ),
          const SizedBox(width: NsSpacing.xs),
          _buildViewModeButton(
            context,
            isDark,
            Icons.vertical_split_outlined,
            ViewMode.split,
            'Split',
          ),

          // Musicify button (показывается только для .md и .html файлов)
          if (_canMusicifyCurrentFile(projectState.activeFile?.path)) ...[
            const SizedBox(width: NsSpacing.md),
            Container(
              width: 1,
              height: 24,
              color: isDark ? NsColorsDark.border : NsColorsLight.border,
            ),
            const SizedBox(width: NsSpacing.md),
            Tooltip(
              message: 'Музицировать документ',
              child: InkWell(
                onTap: () {
                  if (projectState.activeFile != null) {
                    _showMusicifyDialog(
                      context,
                      projectState.activeFile!.fileName,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NsSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.music_note_outlined,
                        size: 18,
                        color: isDark
                            ? NsColorsDark.mutedForeground
                            : NsColorsLight.mutedForeground,
                      ),
                      const SizedBox(width: NsSpacing.xs),
                      Text(
                        'Музицировать',
                        style: NsTextStyles.bodySmall(context).copyWith(
                          color: isDark
                              ? NsColorsDark.mutedForeground
                              : NsColorsLight.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewModeButton(
    BuildContext context,
    bool isDark,
    IconData icon,
    ViewMode mode,
    String tooltip,
  ) {
    final isActive = _viewMode == mode;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _viewMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? NsColorsDark.primary : NsColorsLight.primary).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? (isDark ? NsColorsDark.primary : NsColorsLight.primary)
                : (isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark, ProjectState projectState) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.panel : NsColorsLight.panel,
        border: Border(
          bottom: BorderSide(
            color: isDark ? NsColorsDark.border : NsColorsLight.border,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: projectState.openedFiles.length,
        itemBuilder: (context, index) {
          return _buildTab(
            context,
            isDark,
            projectState.openedFiles[index],
            index,
            projectState.activeTabIndex == index,
          );
        },
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    bool isDark,
    OpenedFile file,
    int index,
    bool isActive,
  ) {
    return InkWell(
      onTap: () {
        ref.read(projectProvider.notifier).switchTab(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: NsSpacing.md,
          vertical: NsSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? NsColorsDark.editor : NsColorsLight.editor)
              : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: isDark ? NsColorsDark.border : NsColorsLight.border,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File name
            Text(
              file.fileName,
              style: NsTextStyles.bodySmall(context).copyWith(
                color: isActive
                    ? (isDark ? NsColorsDark.foreground : NsColorsLight.foreground)
                    : (isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Unsaved changes indicator
            if (file.hasUnsavedChanges) ...[
              const SizedBox(width: NsSpacing.xs),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],

            // Close button
            const SizedBox(width: NsSpacing.xs),
            InkWell(
              onTap: () {
                ref.read(projectProvider.notifier).closeTab(index);
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
          ),
          const SizedBox(height: NsSpacing.md),
          Text(
            'No file opened',
            style: NsTextStyles.h3(context).copyWith(
              color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
            ),
          ),
          const SizedBox(height: NsSpacing.sm),
          Text(
            'Select a file from the explorer to preview',
            style: NsTextStyles.bodyMedium(context).copyWith(
              color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, ProjectState projectState) {
    switch (_viewMode) {
      case ViewMode.preview:
        return _buildPreviewMode(context, isDark, projectState);
      case ViewMode.edit:
        return _buildEditMode(context, isDark, projectState);
      case ViewMode.split:
        return _buildSplitMode(context, isDark, projectState);
    }
  }

  Widget _buildPreviewMode(BuildContext context, bool isDark, ProjectState projectState) {
    final filePath = projectState.activeFile?.path;
    final isHtml = _isHtmlFile(filePath);
    final isAudio = _isAudioFile(filePath);

    // Для аудио файлов показываем плеер
    if (isAudio && filePath != null) {
      return AudioPlayerWidget(filePath: filePath);
    }

    // Для HTML и Markdown - соответствующие рендереры
    return Container(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: SingleChildScrollView(
        child: isHtml
            ? HtmlRenderer(
                data: projectState.activeFile?.content ?? '',
              )
            : MarkdownRenderer(
                data: projectState.activeFile?.content ?? '',
              ),
      ),
    );
  }

  Widget _buildEditMode(BuildContext context, bool isDark, ProjectState projectState) {
    return Padding(
      padding: const EdgeInsets.all(NsSpacing.md),
      child: TextEditor(
        content: projectState.activeFile?.content ?? '',
        filePath: projectState.activeFile?.path,
        onChanged: (value) {
          ref.read(projectProvider.notifier).updateContent(value);
        },
      ),
    );
  }

  Widget _buildSplitMode(BuildContext context, bool isDark, ProjectState projectState) {
    return Row(
      children: [
        // Editor
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(NsSpacing.md),
            child: TextEditor(
              content: projectState.activeFile?.content ?? '',
              filePath: projectState.activeFile?.path,
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateContent(value);
              },
            ),
          ),
        ),

        // Divider
        Container(
          width: 1,
          color: isDark ? NsColorsDark.border : NsColorsLight.border,
        ),

        // Preview
        Expanded(
          child: _isAudioFile(projectState.activeFile?.path) && projectState.activeFile?.path != null
              ? AudioPlayerWidget(filePath: projectState.activeFile!.path)
              : Container(
                  padding: const EdgeInsets.all(NsSpacing.xl),
                  child: SingleChildScrollView(
                    child: _isHtmlFile(projectState.activeFile?.path)
                        ? HtmlRenderer(
                            data: projectState.activeFile?.content ?? '',
                          )
                        : MarkdownRenderer(
                            data: projectState.activeFile?.content ?? '',
                          ),
                  ),
                ),
        ),
      ],
    );
  }
}
