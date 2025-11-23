import 'package:equatable/equatable.dart';

class MusicationApiResponse extends Equatable {
  final int? requestId;
  final String? model;
  final String? status;
  final int? cost;
  final int? progress;
  final List<MusicationAudioResult>? result;
  final String? error;

  const MusicationApiResponse({
    this.requestId,
    this.model,
    this.status,
    this.cost,
    this.progress,
    this.result,
    this.error,
  });

  factory MusicationApiResponse.fromMap(Map<String, dynamic> map) {
    return MusicationApiResponse(
      requestId: map['request_id'] as int?,
      model: map['model'] as String?,
      status: map['status'] as String?,
      cost: map['cost'] as int?,
      progress: map['progress'] as int?,
      result: map['result'] != null
          ? _parseResult(map['result'] as List)
          : null,
      error: map['error'] as String?,
    );
  }

  /// Парсинг массива result с учетом разных типов данных
  static List<MusicationAudioResult> _parseResult(List resultList) {
    final results = <MusicationAudioResult>[];
    int trackIndex = 1;

    for (final item in resultList) {
      // Если item - это строка (прямой URL)
      if (item is String) {
        results.add(
          MusicationAudioResult(
            title: 'Track_$trackIndex',
            url: item,
          ),
        );
        trackIndex++;
      }
      // Если item - это Map с полем 'url'
      else if (item is Map<String, dynamic> && item.containsKey('url')) {
        results.add(MusicationAudioResult.fromMap(item));
        trackIndex++;
      }
      // Пропускаем объекты с image/video без url
    }

    return results;
  }

  bool get isSuccess => status == 'success' || status == 'completed';
  bool get isPending => status == 'pending' || status == 'processing';
  bool get isFailed => status == 'failed' || status == 'error';
  bool get hasResult => result != null && result!.isNotEmpty;

  @override
  List<Object?> get props => [
    requestId,
    model,
    status,
    cost,
    progress,
    result,
    error,
  ];
}

class MusicationAudioResult extends Equatable {
  final String title;
  final String url;
  final String? image;
  final String? video;

  const MusicationAudioResult({
    required this.title,
    required this.url,
    this.image,
    this.video,
  });

  factory MusicationAudioResult.fromMap(Map<String, dynamic> map) {
    return MusicationAudioResult(
      title: map['title'] as String? ?? 'Untitled',
      url: map['url'] as String,
      image: map['image'] as String?,
      video: map['video'] as String?,
    );
  }

  String get fileName =>
      '$title.mp3'.replaceAll(RegExp(r'[^\w\s-]'), '').trim();

  @override
  List<Object?> get props => [title, url, image, video];
}
