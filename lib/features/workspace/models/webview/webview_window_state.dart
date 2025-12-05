/// Модель для сохранения состояния окна WebView между сессиями
class WebViewWindowState {
  final double width;
  final double height;
  final double x;
  final double y;
  final bool isMaximized;
  final DateTime lastUpdated;
  
  WebViewWindowState({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.isMaximized = false,
  }) : lastUpdated = DateTime.now();
  
  /// Создает состояние окна с размерами по умолчанию
  factory WebViewWindowState.defaultState() {
    return WebViewWindowState(
      width: 1200,
      height: 800,
      x: 100,
      y: 100,
    );
  }
  
  /// Создает копию состояния с обновленными параметрами
  WebViewWindowState copyWith({
    double? width,
    double? height,
    double? x,
    double? y,
    bool? isMaximized,
  }) {
    return WebViewWindowState(
      width: width ?? this.width,
      height: height ?? this.height,
      x: x ?? this.x,
      y: y ?? this.y,
      isMaximized: isMaximized ?? this.isMaximized,
    );
  }
  
  /// Преобразует в Map для сохранения в SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'isMaximized': isMaximized,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
  
  /// Создает состояние из Map из SharedPreferences
  factory WebViewWindowState.fromMap(Map<String, dynamic> map) {
    return WebViewWindowState(
      width: (map['width'] as num?)?.toDouble() ?? 1200,
      height: (map['height'] as num?)?.toDouble() ?? 800,
      x: (map['x'] as num?)?.toDouble() ?? 100,
      y: (map['y'] as num?)?.toDouble() ?? 100,
      isMaximized: map['isMaximized'] as bool? ?? false,
    );
  }
  
  /// Валидирует состояние окна
  bool isValid() {
    return width > 100 && 
           height > 100 && 
           x >= 0 && 
           y >= 0;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WebViewWindowState &&
           other.width == width &&
           other.height == height &&
           other.x == x &&
           other.y == y &&
           other.isMaximized == isMaximized;
  }
  
  @override
  int get hashCode {
    return width.hashCode ^
           height.hashCode ^
           x.hashCode ^
           y.hashCode ^
           isMaximized.hashCode;
  }
  
  @override
  String toString() {
    return 'WebViewWindowState(width: $width, height: $height, x: $x, y: $y, isMaximized: $isMaximized)';
  }
}