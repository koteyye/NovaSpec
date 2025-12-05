import 'package:equatable/equatable.dart';

enum PlayerState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class AudioPlayerState extends Equatable {
  final Duration position;
  final Duration duration;
  final PlayerState playerState;
  final bool isLoading;
  final String? errorMessage;
  final String? currentFilePath;

  const AudioPlayerState({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playerState = PlayerState.stopped,
    this.isLoading = false,
    this.errorMessage,
    this.currentFilePath,
  });

  AudioPlayerState copyWith({
    Duration? position,
    Duration? duration,
    PlayerState? playerState,
    bool? isLoading,
    String? errorMessage,
    String? currentFilePath,
  }) {
    return AudioPlayerState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playerState: playerState ?? this.playerState,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentFilePath: currentFilePath ?? this.currentFilePath,
    );
  }

  bool get isPlaying => playerState == PlayerState.playing;
  bool get isPaused => playerState == PlayerState.paused;
  bool get isStopped => playerState == PlayerState.stopped;
  bool get hasError => errorMessage != null;
  bool get canPlay => currentFilePath != null && !hasError;
  bool get canPause => isPlaying;
  bool get canStop => isPlaying || isPaused;
  bool get canSeek => duration.inMilliseconds > 0;

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  String get positionText {
    final minutes = position.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get durationText {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  List<Object?> get props => [
        position,
        duration,
        playerState,
        isLoading,
        errorMessage,
        currentFilePath,
      ];

  @override
  String toString() {
    return 'AudioPlayerState('
        'position: $position, '
        'duration: $duration, '
        'state: $playerState, '
        'loading: $isLoading, '
        'error: $errorMessage'
        ')';
  }
}