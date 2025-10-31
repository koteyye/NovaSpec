/// Результат валидации настроек
class ValidationResult {
  final bool isValid;
  final String message;
  final String? details;
  final DateTime timestamp;
  
  ValidationResult({
    required this.isValid,
    required this.message,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  factory ValidationResult.success(String message, {String? details}) {
    return ValidationResult(
      isValid: true,
      message: message,
      details: details,
    );
  }
  
  factory ValidationResult.error(String message, {String? details}) {
    return ValidationResult(
      isValid: false,
      message: message,
      details: details,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationResult &&
        other.isValid == isValid &&
        other.message == message &&
        other.details == details;
  }
  
  @override
  int get hashCode => Object.hash(isValid, message, details);
  
  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, message: $message, details: $details)';
  }
}
