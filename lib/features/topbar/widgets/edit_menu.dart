import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/menu_dropdown.dart';

class EditMenu extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onCut;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onSelectAll;
  final VoidCallback? onFind;
  final VoidCallback? onReplace;

  const EditMenu({
    super.key,
    this.onUndo,
    this.onRedo,
    this.onCut,
    this.onCopy,
    this.onPaste,
    this.onSelectAll,
    this.onFind,
    this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return MenuDropdown<String>(
      value: 'edit',
      label: 'Редактирование',
      items: _getMenuItems(localizations),
      onSelected: _handleMenuAction,
      width: 140,
    );
  }

  List<MenuItem<String>> _getMenuItems(AppLocalizations localizations) {
    return [
      MenuItem(
        value: 'undo',
        label: 'Отменить',
        icon: Icons.undo_outlined,
        shortcut: 'Ctrl+Z',
        enabled: onUndo != null,
      ),
      MenuItem(
        value: 'redo',
        label: 'Повторить',
        icon: Icons.redo_outlined,
        shortcut: 'Ctrl+Y',
        enabled: onRedo != null,
      ),
      const MenuItem(
        value: 'separator1',
        label: '---',
      ),
      MenuItem(
        value: 'cut',
        label: 'Вырезать',
        icon: Icons.content_cut_outlined,
        shortcut: 'Ctrl+X',
        enabled: onCut != null,
      ),
      MenuItem(
        value: 'copy',
        label: 'Копировать',
        icon: Icons.content_copy_outlined,
        shortcut: 'Ctrl+C',
        enabled: onCopy != null,
      ),
      MenuItem(
        value: 'paste',
        label: 'Вставить',
        icon: Icons.content_paste_outlined,
        shortcut: 'Ctrl+V',
        enabled: onPaste != null,
      ),
      MenuItem(
        value: 'selectAll',
        label: 'Выделить все',
        icon: Icons.select_all_outlined,
        shortcut: 'Ctrl+A',
        enabled: onSelectAll != null,
      ),
      const MenuItem(
        value: 'separator2',
        label: '---',
      ),
      MenuItem(
        value: 'find',
        label: 'Найти',
        icon: Icons.search_outlined,
        shortcut: 'Ctrl+F',
        enabled: onFind != null,
      ),
      MenuItem(
        value: 'replace',
        label: 'Заменить',
        icon: Icons.find_replace_outlined,
        shortcut: 'Ctrl+H',
        enabled: onReplace != null,
      ),
    ];
  }

  void _handleMenuAction(String? action) {
    if (action == null || action == '---') return;
    
    switch (action) {
      case 'undo':
        onUndo?.call();
        break;
      case 'redo':
        onRedo?.call();
        break;
      case 'cut':
        onCut?.call();
        break;
      case 'copy':
        onCopy?.call();
        break;
      case 'paste':
        onPaste?.call();
        break;
      case 'selectAll':
        onSelectAll?.call();
        break;
      case 'find':
        onFind?.call();
        break;
      case 'replace':
        onReplace?.call();
        break;
    }
  }
}

// Edit menu action handler for easier integration
class EditMenuActionHandler {
  final BuildContext context;
  final VoidCallback? onUndoCallback;
  final VoidCallback? onRedoCallback;
  final VoidCallback? onCutCallback;
  final VoidCallback? onCopyCallback;
  final VoidCallback? onPasteCallback;
  final VoidCallback? onSelectAllCallback;
  final VoidCallback? onFindCallback;
  final VoidCallback? onReplaceCallback;

  EditMenuActionHandler({
    required this.context,
    this.onUndoCallback,
    this.onRedoCallback,
    this.onCutCallback,
    this.onCopyCallback,
    this.onPasteCallback,
    this.onSelectAllCallback,
    this.onFindCallback,
    this.onReplaceCallback,
  });

  void handleUndo() {
    onUndoCallback?.call();
  }

  void handleRedo() {
    onRedoCallback?.call();
  }

  void handleCut() {
    onCutCallback?.call();
  }

  void handleCopy() {
    onCopyCallback?.call();
  }

  void handlePaste() {
    onPasteCallback?.call();
  }

  void handleSelectAll() {
    onSelectAllCallback?.call();
  }

  void handleFind() {
    if (onFindCallback != null) {
      onFindCallback!();
    } else {
      _showNotImplementedDialog('Поиск');
    }
  }

  void handleReplace() {
    if (onReplaceCallback != null) {
      onReplaceCallback!();
    } else {
      _showNotImplementedDialog('Замена');
    }
  }

  void _showNotImplementedDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature - В разработке'),
        content: Text('Функция "$feature" будет доступна в следующей версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }
}

// Clipboard operations helper
class ClipboardOperations {
  static Future<void> cut(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<String?> paste() async {
    final clipboardData = await Clipboard.getData('text/plain');
    return clipboardData?.text;
  }
}

// Text selection helper
class TextSelectionHelper {
  static void selectAll(TextEditingController controller) {
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }

  static String getSelectedText(TextEditingController controller) {
    final selection = controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      return controller.text.substring(selection.start, selection.end);
    }
    return '';
  }

  static void replaceSelectedText(TextEditingController controller, String newText) {
    final selection = controller.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final text = controller.text;
      controller.text = text.replaceRange(selection.start, selection.end, newText);
      controller.selection = TextSelection.collapsed(offset: selection.start + newText.length);
    }
  }
}

// Find and replace functionality (placeholder for future implementation)
class FindReplaceController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController replaceController = TextEditingController();
  bool caseSensitive = false;
  bool wholeWord = false;
  int currentIndex = -1;
  List<int> matches = [];

  void findNext(String text) {
    // TODO: Implement find next functionality
  }

  void findPrevious(String text) {
    // TODO: Implement find previous functionality
  }

  void replaceAll(String text, String replacement) {
    // TODO: Implement replace all functionality
  }

  void replaceCurrent(String text, String replacement) {
    // TODO: Implement replace current functionality
  }

  void clear() {
    searchController.clear();
    replaceController.clear();
    currentIndex = -1;
    matches.clear();
  }
}