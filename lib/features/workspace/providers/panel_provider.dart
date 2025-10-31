import 'package:flutter/foundation.dart';

class PanelProvider extends ChangeNotifier {
  bool _isFileExplorerCollapsed = false;
  bool _isAiAssistantCollapsed = false;

  bool get isFileExplorerCollapsed => _isFileExplorerCollapsed;
  bool get isAiAssistantCollapsed => _isAiAssistantCollapsed;

  void toggleFileExplorer() {
    _isFileExplorerCollapsed = !_isFileExplorerCollapsed;
    notifyListeners();
  }

  void toggleAiAssistant() {
    _isAiAssistantCollapsed = !_isAiAssistantCollapsed;
    notifyListeners();
  }

  void setFileExplorerCollapsed(bool collapsed) {
    if (_isFileExplorerCollapsed != collapsed) {
      _isFileExplorerCollapsed = collapsed;
      notifyListeners();
    }
  }

  void setAiAssistantCollapsed(bool collapsed) {
    if (_isAiAssistantCollapsed != collapsed) {
      _isAiAssistantCollapsed = collapsed;
      notifyListeners();
    }
  }
}
