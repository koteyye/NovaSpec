import 'package:flutter/foundation.dart';
import 'webview_window_state.dart';
import 'webview2_status.dart';

/// Модель состояния WebView компонента для управления через Provider
class WebViewState extends ChangeNotifier {
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  WebViewWindowState? _windowState;
  String? _currentOpenAPIFile;
  WebView2Status? _webview2Status;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  WebViewWindowState? get windowState => _windowState;
  String? get currentOpenAPIFile => _currentOpenAPIFile;
  WebView2Status? get webview2Status => _webview2Status;
  
  // Methods
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void setError(String? error) {
    _hasError = error != null;
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    if (_hasError || _errorMessage != null) {
      _hasError = false;
      _errorMessage = null;
      notifyListeners();
    }
  }
  
  void setWindowState(WebViewWindowState? state) {
    if (_windowState != state) {
      _windowState = state;
      notifyListeners();
    }
  }
  
  void setCurrentOpenAPIFile(String? filePath) {
    if (_currentOpenAPIFile != filePath) {
      _currentOpenAPIFile = filePath;
      notifyListeners();
    }
  }
  
  void setWebView2Status(WebView2Status? status) {
    if (_webview2Status != status) {
      _webview2Status = status;
      notifyListeners();
    }
  }
  
  void reset() {
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;
    _windowState = null;
    _currentOpenAPIFile = null;
    notifyListeners();
  }
}