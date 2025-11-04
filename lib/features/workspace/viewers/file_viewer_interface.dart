import 'package:flutter/widgets.dart';
import '../models/workspace_file.dart';

abstract class FileViewer {
  String get supportedExtension;
  WorkspaceFile? get currentFile;
  
  Future<void> loadFile(String filePath);
  Widget build(BuildContext context);
  void dispose();
  
  bool get canEdit;
  Future<void> saveContent(String content);
  
  // State management
  bool get isLoading;
  String? get errorMessage;
  
  // Lifecycle
  void onFileChanged(String content);
  void onViewModeChanged();
}