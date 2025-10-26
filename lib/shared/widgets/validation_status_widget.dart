import 'package:flutter/material.dart';
import '../models/validation_result.dart';
import '../models/connection_status.dart';

class ValidationStatusWidget extends StatelessWidget {
  final ValidationResult? validationResult;
  final ConnectionStatusInfo? connectionStatus;
  final double? size;
  
  const ValidationStatusWidget({
    super.key,
    this.validationResult,
    this.connectionStatus,
    this.size = 16.0,
  });
  
  bool get isValid {
    if (validationResult != null) return validationResult!.isValid;
    if (connectionStatus != null) return connectionStatus!.isConnected;
    return false;
  }
  
  bool get isLoading {
    if (connectionStatus != null) return connectionStatus!.isPending;
    return false;
  }
  
  bool get hasError {
    if (validationResult != null) return !validationResult!.isValid;
    if (connectionStatus != null) return connectionStatus!.isError;
    return false;
  }
  
  String get message {
    if (validationResult != null) return validationResult!.message;
    if (connectionStatus != null) return connectionStatus!.message;
    return '';
  }
  
  String? get details {
    if (validationResult != null) return validationResult!.details;
    if (connectionStatus != null) return connectionStatus!.details;
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    if (isLoading) {
      icon = Icons.hourglass_empty;
      color = Colors.orange;
    } else if (isValid) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (hasError) {
      icon = Icons.error;
      color = Colors.red;
    } else {
      icon = Icons.help_outline;
      color = Colors.grey;
    }
    
    return Tooltip(
      message: details != null ? '$message\n$details' : message,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}

class ValidationStatusText extends StatelessWidget {
  final ValidationResult? validationResult;
  final ConnectionStatusInfo? connectionStatus;
  final TextStyle? style;
  
  const ValidationStatusText({
    super.key,
    this.validationResult,
    this.connectionStatus,
    this.style,
  });
  
  bool get isValid {
    if (validationResult != null) return validationResult!.isValid;
    if (connectionStatus != null) return connectionStatus!.isConnected;
    return false;
  }
  
  bool get isLoading {
    if (connectionStatus != null) return connectionStatus!.isPending;
    return false;
  }
  
  bool get hasError {
    if (validationResult != null) return !validationResult!.isValid;
    if (connectionStatus != null) return connectionStatus!.isError;
    return false;
  }
  
  String get message {
    if (validationResult != null) return validationResult!.message;
    if (connectionStatus != null) return connectionStatus!.message;
    return '';
  }
  
  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    if (isLoading) {
      color = Colors.orange;
      text = 'Проверка...';
    } else if (isValid) {
      color = Colors.green;
      text = message;
    } else if (hasError) {
      color = Colors.red;
      text = message;
    } else {
      color = Colors.grey;
      text = 'Не проверено';
    }
    
    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
        color: color,
        fontWeight: isValid ? FontWeight.w500 : null,
      ),
    );
  }
}