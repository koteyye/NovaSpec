import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutService {
  final Map<ShortcutActivator, VoidCallback> _shortcuts = {};
  final Map<LogicalKeySet, Intent> _intents = {};
  final Map<Type, Action<Intent>> _actions = {};
  
  bool _isInitialized = false;

  // Initialize shortcut service
  void initialize() {
    if (_isInitialized) return;
    
    _registerDefaultShortcuts();
    _isInitialized = true;
  }

  // Register a shortcut
  void registerShortcut(LogicalKeySet keySet, Intent intent, Action<Intent> action) {
    _intents[keySet] = intent;
    _actions[intent.runtimeType] = action;
  }

  // Register a simple shortcut callback
  void registerShortcutCallback(ShortcutActivator activator, VoidCallback callback) {
    _shortcuts[activator] = callback;
  }

  // Get all registered shortcuts for UI
  Map<ShortcutActivator, VoidCallback> get shortcuts => Map.unmodifiable(_shortcuts);
  
  // Get intents for ShortcutBinding
  Map<LogicalKeySet, Intent> get intents => Map.unmodifiable(_intents);
  
  // Get actions for ActionsDispatcher
  Map<Type, Action<Intent>> get actions => Map.unmodifiable(_actions);

  // Register default shortcuts
  void _registerDefaultShortcuts() {
    // File operations
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyN, control: true),
      () => _triggerAction('newProject'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyO, control: true),
      () => _triggerAction('openProject'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyS, control: true),
      () => _triggerAction('saveProject'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true),
      () => _triggerAction('saveProjectAs'),
    );

    // Edit operations
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
      () => _triggerAction('undo'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyY, control: true),
      () => _triggerAction('redo'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyX, control: true),
      () => _triggerAction('cut'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyC, control: true),
      () => _triggerAction('copy'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyV, control: true),
      () => _triggerAction('paste'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyA, control: true),
      () => _triggerAction('selectAll'),
    );

    // View operations
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyB, control: true),
      () => _triggerAction('toggleSidebar'),
    );

    // Find operations
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyF, control: true),
      () => _triggerAction('find'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyH, control: true),
      () => _triggerAction('replace'),
    );

    // Settings operations
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.comma, control: true),
      () => _triggerAction('openSettings'),
    );

    // Window operations
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyW, control: true),
      () => _triggerAction('closeWindow'),
    );
    
    registerShortcutCallback(
      const SingleActivator(LogicalKeyboardKey.keyQ, control: true),
      () => _triggerAction('quit'),
    );
  }

  // Trigger action by name
  void _triggerAction(String actionName) {
    // This would be connected to a global action dispatcher
    // For now, we'll just print the action
    debugPrint('Shortcut triggered: $actionName');
  }

  // Create ShortcutBindings for Flutter
  ShortcutBindings createBindings() {
    return ShortcutBindings(
      shortcuts: _intents,
      actions: _actions,
    );
  }

  // Check if a key combination is already registered
  bool isShortcutRegistered(LogicalKeySet keySet) {
    return _intents.containsKey(keySet);
  }

  // Remove a shortcut
  void removeShortcut(LogicalKeySet keySet) {
    final intent = _intents.remove(keySet);
    if (intent != null) {
      _actions.remove(intent.runtimeType);
    }
  }

  // Clear all shortcuts
  void clearAllShortcuts() {
    _shortcuts.clear();
    _intents.clear();
    _actions.clear();
  }

  // Get shortcut description for UI
  String getShortcutDescription(String actionName) {
    final entry = _shortcuts.entries.firstWhere(
      (entry) => _getActionNameFromCallback(entry.value) == actionName,
      orElse: () => MapEntry(const SingleActivator(LogicalKeyboardKey.space), () {}),
    );
    
    return _formatShortcut(entry.key);
  }

  String _getActionNameFromCallback(VoidCallback callback) {
    // This is a simplified approach - in a real implementation,
    // you'd want to store action names alongside callbacks
    return '';
  }

  String _formatShortcut(ShortcutActivator activator) {
    if (activator is SingleActivator) {
      final parts = <String>[];
      if (activator.control) parts.add('Ctrl');
      if (activator.alt) parts.add('Alt');
      if (activator.shift) parts.add('Shift');
      if (activator.meta) parts.add('Meta');
      
      final key = _formatKey(activator.trigger);
      parts.add(key);
      
      return parts.join('+');
    }
    
    return activator.toString();
  }

  String _formatKey(LogicalKeyboardKey key) {
    // Map common keys to readable names
    switch (key.keyLabel) {
      case 'Space':
        return 'Пробел';
      case 'Arrow Up':
        return '↑';
      case 'Arrow Down':
        return '↓';
      case 'Arrow Left':
        return '←';
      case 'Arrow Right':
        return '→';
      default:
        return key.keyLabel;
    }
  }
}

// Helper class for Flutter ShortcutBindings
class ShortcutBindings {
  final Map<LogicalKeySet, Intent> shortcuts;
  final Map<Type, Action<Intent>> actions;

  const ShortcutBindings({
    required this.shortcuts,
    required this.actions,
  });
}

// Custom intents for application actions
class NewProjectIntent extends Intent {
  const NewProjectIntent();
}

class OpenProjectIntent extends Intent {
  const OpenProjectIntent();
}

class SaveProjectIntent extends Intent {
  const SaveProjectIntent();
}

class SaveProjectAsIntent extends Intent {
  const SaveProjectAsIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class CutIntent extends Intent {
  const CutIntent();
}

class CopyIntent extends Intent {
  const CopyIntent();
}

class PasteIntent extends Intent {
  const PasteIntent();
}

class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

class FindIntent extends Intent {
  const FindIntent();
}

class ReplaceIntent extends Intent {
  const ReplaceIntent();
}

class ToggleSidebarIntent extends Intent {
  const ToggleSidebarIntent();
}

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

class QuitIntent extends Intent {
  const QuitIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

// Actions for the intents
class NewProjectAction extends Action<NewProjectIntent> {
  final VoidCallback? onNewProject;

  NewProjectAction({this.onNewProject});

  @override
  void invoke(covariant NewProjectIntent intent) {
    onNewProject?.call();
  }
}

class OpenProjectAction extends Action<OpenProjectIntent> {
  final VoidCallback? onOpenProject;

  OpenProjectAction({this.onOpenProject});

  @override
  void invoke(covariant OpenProjectIntent intent) {
    onOpenProject?.call();
  }
}

class SaveProjectAction extends Action<SaveProjectIntent> {
  final VoidCallback? onSaveProject;

  SaveProjectAction({this.onSaveProject});

  @override
  void invoke(covariant SaveProjectIntent intent) {
    onSaveProject?.call();
  }
}

class SaveProjectAsAction extends Action<SaveProjectAsIntent> {
  final VoidCallback? onSaveProjectAs;

  SaveProjectAsAction({this.onSaveProjectAs});

  @override
  void invoke(covariant SaveProjectAsIntent intent) {
    onSaveProjectAs?.call();
  }
}

class UndoAction extends Action<UndoIntent> {
  final VoidCallback? onUndo;

  UndoAction({this.onUndo});

  @override
  void invoke(covariant UndoIntent intent) {
    onUndo?.call();
  }
}

class RedoAction extends Action<RedoIntent> {
  final VoidCallback? onRedo;

  RedoAction({this.onRedo});

  @override
  void invoke(covariant RedoIntent intent) {
    onRedo?.call();
  }
}

class CutAction extends Action<CutIntent> {
  final VoidCallback? onCut;

  CutAction({this.onCut});

  @override
  void invoke(covariant CutIntent intent) {
    onCut?.call();
  }
}

class CopyAction extends Action<CopyIntent> {
  final VoidCallback? onCopy;

  CopyAction({this.onCopy});

  @override
  void invoke(covariant CopyIntent intent) {
    onCopy?.call();
  }
}

class PasteAction extends Action<PasteIntent> {
  final VoidCallback? onPaste;

  PasteAction({this.onPaste});

  @override
  void invoke(covariant PasteIntent intent) {
    onPaste?.call();
  }
}

class SelectAllAction extends Action<SelectAllIntent> {
  final VoidCallback? onSelectAll;

  SelectAllAction({this.onSelectAll});

  @override
  void invoke(covariant SelectAllIntent intent) {
    onSelectAll?.call();
  }
}

class FindAction extends Action<FindIntent> {
  final VoidCallback? onFind;

  FindAction({this.onFind});

  @override
  void invoke(covariant FindIntent intent) {
    onFind?.call();
  }
}

class ReplaceAction extends Action<ReplaceIntent> {
  final VoidCallback? onReplace;

  ReplaceAction({this.onReplace});

  @override
  void invoke(covariant ReplaceIntent intent) {
    onReplace?.call();
  }
}

class ToggleSidebarAction extends Action<ToggleSidebarIntent> {
  final VoidCallback? onToggleSidebar;

  ToggleSidebarAction({this.onToggleSidebar});

  @override
  void invoke(covariant ToggleSidebarIntent intent) {
    onToggleSidebar?.call();
  }
}

class CloseWindowAction extends Action<CloseWindowIntent> {
  final VoidCallback? onCloseWindow;

  CloseWindowAction({this.onCloseWindow});

  @override
  void invoke(covariant CloseWindowIntent intent) {
    onCloseWindow?.call();
  }
}

class QuitAction extends Action<QuitIntent> {
  final VoidCallback? onQuit;

  QuitAction({this.onQuit});

  @override
  void invoke(covariant QuitIntent intent) {
    onQuit?.call();
  }
}

class OpenSettingsAction extends Action<OpenSettingsIntent> {
  final VoidCallback? onOpenSettings;

  OpenSettingsAction({this.onOpenSettings});

  @override
  void invoke(covariant OpenSettingsIntent intent) {
    onOpenSettings?.call();
  }
}