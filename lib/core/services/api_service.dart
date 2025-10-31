import 'dart:async';
import 'package:dio/dio.dart';
import '../../shared/models/storage_result.dart';
import '../../shared/models/app_error.dart';

abstract class ApiService {
  Future<void> initialize();
  
  Future<StorageResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
  
  Future<StorageResult<Map<String, dynamic>>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
  
  Future<StorageResult<Map<String, dynamic>>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
  
  Future<StorageResult<Map<String, dynamic>>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
  
  Future<StorageResult<String>> downloadFile(String url, String savePath);
}

class ApiServiceImpl implements ApiService {
  late Dio _dio;
  
  static const Duration _timeout = Duration(seconds: 30);
  
  @override
  Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      persistentConnection: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'NovaSpec/1.0',
      },
    ));
    
    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response
          handler.next(response);
        },
        onError: (error, handler) {
          // Log error
          handler.next(error);
        },
      ),
    );
    
    // Add response size validation interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        final maxSize = 50 * 1024 * 1024; // 50MB
        if (response.data != null && response.data.toString().length > maxSize) {
          handler.reject(DioException(
            requestOptions: response.requestOptions,
            type: DioExceptionType.receiveTimeout,
            message: 'Response too large',
          ));
        } else {
          handler.next(response);
        }
      },
    ));
  }
  
  @override
  Future<StorageResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200) {
        return StorageResult.success(response.data as Map<String, dynamic>);
      } else {
        return StorageResult.failure(
          AppError(
            type: ErrorType.network,
            severity: ErrorSeverity.medium,
            code: 'HTTP_ERROR',
            message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
            timestamp: DateTime.now(),
          ),
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'GET_REQUEST_ERROR',
          message: 'Failed to perform GET request',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<Map<String, dynamic>>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return StorageResult.success(response.data as Map<String, dynamic>);
      } else {
        return StorageResult.failure(
          AppError(
            type: ErrorType.network,
            severity: ErrorSeverity.medium,
            code: 'HTTP_ERROR',
            message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
            timestamp: DateTime.now(),
          ),
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'POST_REQUEST_ERROR',
          message: 'Failed to perform POST request',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<Map<String, dynamic>>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return StorageResult.success(response.data as Map<String, dynamic>);
      } else {
        return StorageResult.failure(
          AppError(
            type: ErrorType.network,
            severity: ErrorSeverity.medium,
            code: 'HTTP_ERROR',
            message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
            timestamp: DateTime.now(),
          ),
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'PUT_REQUEST_ERROR',
          message: 'Failed to perform PUT request',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<Map<String, dynamic>>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return StorageResult.success(response.data as Map<String, dynamic>);
      } else {
        return StorageResult.failure(
          AppError(
            type: ErrorType.network,
            severity: ErrorSeverity.medium,
            code: 'HTTP_ERROR',
            message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
            timestamp: DateTime.now(),
          ),
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'DELETE_REQUEST_ERROR',
          message: 'Failed to perform DELETE request',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  @override
  Future<StorageResult<String>> downloadFile(String url, String savePath) async {
    try {
      final response = await _dio.download(url, savePath);
      
      if (response.statusCode == 200) {
        return StorageResult.success(savePath);
      } else {
        return StorageResult.failure(
          AppError(
            type: ErrorType.network,
            severity: ErrorSeverity.medium,
            code: 'DOWNLOAD_ERROR',
            message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
            timestamp: DateTime.now(),
          ),
        );
      }
    } on DioException catch (e) {
      return _handleDioErrorForDownload(e);
    } catch (e) {
      return StorageResult.failure(
        AppError(
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          code: 'DOWNLOAD_FILE_ERROR',
          message: 'Failed to download file',
          details: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }
  
  StorageResult<String> _handleDioErrorForDownload(DioException error) {
    ErrorType type;
    String code;
    String message;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        type = ErrorType.network;
        code = 'TIMEOUT_ERROR';
        message = 'Request timeout';
        break;
      case DioExceptionType.badResponse:
        type = ErrorType.network;
        code = 'HTTP_ERROR';
        message = 'HTTP ${error.response?.statusCode}: ${error.response?.statusMessage}';
        break;
      case DioExceptionType.cancel:
        type = ErrorType.network;
        code = 'REQUEST_CANCELLED';
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        type = ErrorType.network;
        code = 'CONNECTION_ERROR';
        message = 'Connection error';
        break;
      default:
        type = ErrorType.unknown;
        code = 'UNKNOWN_ERROR';
        message = 'Unknown network error';
        break;
    }
    
    return StorageResult.failure(
      AppError(
        type: type,
        severity: ErrorSeverity.high,
        code: code,
        message: message,
        details: error.toString(),
        timestamp: DateTime.now(),
      ),
    );
  }

  StorageResult<Map<String, dynamic>> _handleDioError(DioException error) {
    ErrorType type;
    String code;
    String message;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        type = ErrorType.network;
        code = 'TIMEOUT_ERROR';
        message = 'Request timeout';
        break;
      case DioExceptionType.badResponse:
        type = ErrorType.network;
        code = 'HTTP_ERROR';
        message = 'HTTP ${error.response?.statusCode}: ${error.response?.statusMessage}';
        break;
      case DioExceptionType.cancel:
        type = ErrorType.network;
        code = 'REQUEST_CANCELLED';
        message = 'Request was cancelled';
        break;
      case DioExceptionType.connectionError:
        type = ErrorType.network;
        code = 'CONNECTION_ERROR';
        message = 'Connection error';
        break;
      default:
        type = ErrorType.unknown;
        code = 'UNKNOWN_ERROR';
        message = 'Unknown network error';
        break;
    }
    
    return StorageResult.failure(
      AppError(
        type: type,
        severity: ErrorSeverity.high,
        code: code,
        message: message,
        details: error.toString(),
        timestamp: DateTime.now(),
      ),
    );
  }
}
