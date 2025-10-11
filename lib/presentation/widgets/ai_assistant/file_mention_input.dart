import 'package:flutter/material.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Модель упоминания файла
class FileMention {
  final String path;
  final String displayName;

  const FileMention({
    required this.path,
    required this.displayName,
  });
}

/// Текстовое поле с поддержкой упоминания файлов через @
class FileMentionInput extends StatefulWidget {
  final TextEditingController controller;
  final List<String> availableFiles;
  final String? placeholder;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmit;
  final FocusNode? focusNode;

  const FileMentionInput({
    super.key,
    required this.controller,
    required this.availableFiles,
    this.placeholder,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmit,
    this.focusNode,
  });

  @override
  State<FileMentionInput> createState() => _FileMentionInputState();
}

class _FileMentionInputState extends State<FileMentionInput> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredFiles = [];
  int _selectedIndex = 0;
  int _mentionStartPos = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cursorPos = widget.controller.selection.baseOffset;

    // Поиск символа @ перед курсором
    int atPos = -1;
    for (int i = cursorPos - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atPos = i;
        break;
      } else if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (atPos != -1) {
      // Извлекаем текст после @
      final mentionText = text.substring(atPos + 1, cursorPos);
      _mentionStartPos = atPos;

      // Фильтруем файлы
      _filteredFiles = widget.availableFiles
          .where((file) =>
              file.toLowerCase().contains(mentionText.toLowerCase()))
          .take(10)
          .toList();

      if (_filteredFiles.isNotEmpty) {
        _selectedIndex = 0;
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } else {
      _removeOverlay();
    }

    widget.onChanged?.call(text);
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 320,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: _buildAutocompleteList(),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _filteredFiles = [];
    _selectedIndex = 0;
  }

  Widget _buildAutocompleteList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: isDark ? NsColorsDark.panel : NsColorsLight.panel,
        border: Border.all(
          color: isDark ? NsColorsDark.border : NsColorsLight.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: NsSpacing.xs),
        shrinkWrap: true,
        itemCount: _filteredFiles.length,
        itemBuilder: (context, index) {
          final file = _filteredFiles[index];
          final isSelected = index == _selectedIndex;

          return InkWell(
            onTap: () => _selectFile(file),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NsSpacing.md,
                vertical: NsSpacing.sm,
              ),
              color: isSelected
                  ? (isDark ? NsColorsDark.muted : NsColorsLight.muted)
                  : Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: 16,
                    color: isDark
                        ? NsColorsDark.mutedForeground
                        : NsColorsLight.mutedForeground,
                  ),
                  const SizedBox(width: NsSpacing.sm),
                  Expanded(
                    child: Text(
                      file,
                      style: NsTextStyles.bodySmall(context).copyWith(
                        fontFamily: 'monospace',
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectFile(String file) {
    if (_mentionStartPos == -1) return;

    final text = widget.controller.text;
    final cursorPos = widget.controller.selection.baseOffset;

    // Заменяем @mention на полное имя файла
    final newText = '${text.substring(0, _mentionStartPos)}@$file ${text.substring(cursorPos)}';

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: _mentionStartPos + file.length + 2,
      ),
    );

    _removeOverlay();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (_overlayEntry == null) return;

    // Обрабатываем только нажатия клавиш
    final key = event.logicalKey;

    if (key.keyLabel == 'Arrow Down') {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % _filteredFiles.length;
      });
    } else if (key.keyLabel == 'Arrow Up') {
      setState(() {
        _selectedIndex =
            (_selectedIndex - 1 + _filteredFiles.length) %
                _filteredFiles.length;
      });
    } else if (key.keyLabel == 'Enter') {
      if (_filteredFiles.isNotEmpty) {
        _selectFile(_filteredFiles[_selectedIndex]);
      }
    } else if (key.keyLabel == 'Escape') {
      _removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyEvent,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLines: widget.maxLines,
          style: NsTextStyles.bodyMedium(context),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: NsTextStyles.bodyMedium(context).copyWith(
              color: isDark
                  ? NsColorsDark.mutedForeground
                  : NsColorsLight.mutedForeground,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.border : NsColorsLight.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.border : NsColorsLight.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: NsSpacing.md,
              vertical: NsSpacing.sm,
            ),
            suffixIcon: widget.maxLines == 1
                ? IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: widget.onSubmit,
                  )
                : null,
          ),
          onSubmitted: widget.maxLines == 1 ? (_) => widget.onSubmit?.call() : null,
        ),
      ),
    );
  }
}
