enum MusicationStatus {
  idle,
  generatingLyrics,
  generatingAudio,
  savingAudio,
  completed,
  failed,
}

class MusicationState {
  final MusicationStatus status;
  final String? errorMessage;
  final int? requestId;
  final double progress; // 0.0 - 1.0
  
  const MusicationState({
    this.status = MusicationStatus.idle,
    this.errorMessage,
    this.requestId,
    this.progress = 0.0,
  });

  MusicationState copyWith({
    MusicationStatus? status,
    String? errorMessage,
    int? requestId,
    double? progress,
  }) {
    return MusicationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      requestId: requestId ?? this.requestId,
      progress: progress ?? this.progress,
    );
  }

  String get displayText {
    switch (status) {
      case MusicationStatus.idle:
        return '';
      case MusicationStatus.generatingLyrics:
        return 'Генерация Lyrics';
      case MusicationStatus.generatingAudio:
        return 'Генерация Audio';
      case MusicationStatus.savingAudio:
        return 'Сохранение Audio';
      case MusicationStatus.completed:
        return 'Музикация выполнена';
      case MusicationStatus.failed:
        return 'Ошибка музикации: $errorMessage';
    }
  }

  bool get isGenerating => status != MusicationStatus.idle && 
                          status != MusicationStatus.completed && 
                          status != MusicationStatus.failed;
  
  bool get isActive => status != MusicationStatus.idle;
}