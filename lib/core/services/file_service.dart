import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../shared/models/storage_result.dart';
import '../../shared/models/app_error.dart';

abstract class FileService {
  Future<void> initialize();
  
  Future<StorageResult<String?>> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  });
  
  Future<StorageResult<List<String>>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  });
  
  Future<StorageResult<String?>> pickDirectory({
    String? dialogTitle,
  });
  
  Future<StorageResult<bool>> saveFile(String content, String filePath);
  
  Future<StorageResult<String>> readFile(String filePath);
  
  Future<StorageResult<bool>> deleteFile(String filePath);
  
  Future<StorageResult<bool>> fileExists(String filePath);
  
  Future<StorageResult<int>> getFileSize(String filePath);
  
  Future<StorageResult<DateTime>> getFileLastModified(String filePath);
}

class FileServiceImpl implements FileService {
  static const List<String> _allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'md', 'json', 'yaml', 'yml'];
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  @override
  Future<void> initialize() async {
    // File picker doesn't require explicit initialization
  }

  bool _isAllowedExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceFirst('.', '');
    return _allowedExtensions.contains(extension);
  }

  Future<bool> _isValidFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;
      final size = await file.length();
      return size <= _maxFileSizeBytes;
    } catch (e) {
      return false;
    }
  }

  bool _isSecurePath(String filePath) {
    return !filePath.contains('..') && 
           !filePath.contains('~') &&
           !filePath.startsWith('/') &&
           (!filePath.contains(':\\') || filePath.startsWith('C:\\'));
  }
  
  @override
  Future<StorageResult<String?>> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions ?? _allowedExtensions,
        dialogTitle: dialogTitle,
      );
      
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        
        if (!_isSecurePath(filePath)) {
          return StorageResult.failure(
            AppError(
              type: ErrorType.fileSystem,
              severity: ErrorSeverity.high,
              code: 'INVALID_PATH',
              message: 'Invalid file path',
              timestamp: DateTime.now(),
            ),
          );
        }
        
        if (!_isAllowedExtension(filePath)) {
          return StorageResult.failure(
            AppError(
              type: ErrorType.fileSystem,
              severity: ErrorSeverity.medium,
              code: 'INVALID_EXTENSION',
              message: 'File type not allowed',
              timestamp: DateTime.now(),
            ),
          );
        }
        
        if (!(await _isValidFileSize(filePath))) {
          return StorageResult.failure(
            AppError(
              type: ErrorType.fileSystem,
              severity: ErrorSeverity.medium,
              code: 'FILE_TOO_LARGE',
              message: 'File size exceeds limit',
              timestamp: DateTime.now(),
            ),
          );
        }
        
        return StorageResult.success(filePath);
      } else {
        return StorageResult.success(null);
      }
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.medium,
          code: 'PICK_FILE_ERROR',
          message: 'Failed to pick file',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<List<String>>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions ?? _allowedExtensions,
        dialogTitle: dialogTitle,
        allowMultiple: true,
      );
      
      if (result != null) {
        final validPaths = <String>[];
        
        for (final file in result.files) {
          if (file.path != null) {
            final filePath = file.path!;
            
            if (_isSecurePath(filePath) && 
                _isAllowedExtension(filePath) && 
                await _isValidFileSize(filePath)) {
              validPaths.add(filePath);
            }
          }
        }
        
        return StorageResult.success(validPaths);
      } else {
        return StorageResult.success(const []);
      }
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.medium,
          code: 'PICK_MULTIPLE_FILES_ERROR',
          message: 'Failed to pick multiple files',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<String?>> pickDirectory({
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle,
      );
      
      return StorageResult.success(result);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.medium,
          code: 'PICK_DIRECTORY_ERROR',
          message: 'Failed to pick directory',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> saveFile(String content, String filePath) async {
    try {
      if (filePath.isEmpty || 
          filePath.contains('..') || 
          filePath.contains('/') || 
          filePath.contains('\\') ||
          filePath.length > 255) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.high,
            code: 'INVALID_FILENAME',
            message: 'Invalid file name',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      if (!_isAllowedExtension(filePath)) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.medium,
            code: 'INVALID_EXTENSION',
            message: 'File type not allowed',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      if (content.length > _maxFileSizeBytes) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.medium,
            code: 'CONTENT_TOO_LARGE',
            message: 'Content size exceeds limit',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final sanitizedFileName = path.basename(filePath);
      final fullFilePath = path.join(directory.path, sanitizedFileName);
      final file = File(fullFilePath);
      
      await file.writeAsString(content);
      return StorageResult.success(true);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.high,
          code: 'SAVE_FILE_ERROR',
          message: 'Failed to save file: $filePath',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<String>> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.medium,
            code: 'FILE_NOT_FOUND',
            message: 'File not found: $filePath',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      final content = await file.readAsString();
      return StorageResult.success(content);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.high,
          code: 'READ_FILE_ERROR',
          message: 'Failed to read file: $filePath',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return StorageResult.success(true); // Already deleted
      }
      
      await file.delete();
      return StorageResult.success(true);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.high,
          code: 'DELETE_FILE_ERROR',
          message: 'Failed to delete file: $filePath',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<bool>> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      final exists = await file.exists();
      return StorageResult.success(exists);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.medium,
          code: 'CHECK_FILE_EXISTS_ERROR',
          message: 'Failed to check if file exists: $filePath',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<int>> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.medium,
            code: 'FILE_NOT_FOUND',
            message: 'File not found: $filePath',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      final size = await file.length();
      return StorageResult.success(size);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.medium,
          code: 'GET_FILE_SIZE_ERROR',
          message: 'Failed to get file size: $filePath',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<DateTime>> getFileLastModified(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return StorageResult.failure(
          AppError(
            type: ErrorType.fileSystem,
            severity: ErrorSeverity.medium,
            code: 'FILE_NOT_FOUND',
            message: 'File not found: $filePath',
            timestamp: DateTime.now(),
          ),
        );
      }
      
      final stat = await file.stat();
      return StorageResult.success(stat.modified);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.fileSystem,
          severity: ErrorSeverity.medium,
          code: 'GET_FILE_MODIFIED_ERROR',
          message: 'Failed to get file modification time: $filePath',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
}
