import 'package:flutter/material.dart';
import '../models/musication_state.dart';
import '../../../l10n/app_localizations.dart';

class MusicationProvider extends ChangeNotifier {
  MusicationState _state = const MusicationState();

  MusicationState get state => _state;

  bool get isGenerating => _state.isGenerating;
  bool get isActive => _state.isActive;
  String get statusText => _state.displayText;
  double get progress => _state.progress;

  // Методы для получения локализованных текстов
  String getLocalizedText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (_state.status) {
      case MusicationStatus.generatingLyrics:
        return l10n.musication_generating_lyrics;
      case MusicationStatus.generatingAudio:
        return l10n.musication_generating_audio;
      case MusicationStatus.savingAudio:
        return l10n.musication_saving_audio;
      case MusicationStatus.completed:
        return l10n.musication_completed;
      case MusicationStatus.failed:
        return '${l10n.musication_failed}: ${_state.errorMessage ?? ''}';
      default:
        return '';
    }
  }

  void _updateState(MusicationState newState) {
    _state = newState;
    notifyListeners();
    debugPrint('🎵 MusicationProvider._updateState: status=${_state.status}, isActive=${_state.isActive}, isGenerating=${_state.isGenerating}');
  }

  void setGeneratingLyrics() {
    _updateState(
      _state.copyWith(status: MusicationStatus.generatingLyrics, progress: 0.1),
    );
  }

  void setGeneratingAudio(int requestId) {
    _updateState(
      _state.copyWith(
        status: MusicationStatus.generatingAudio,
        requestId: requestId,
        progress: 0.4,
      ),
    );
  }

  void setSavingAudio() {
    _updateState(
      _state.copyWith(status: MusicationStatus.savingAudio, progress: 0.8),
    );
  }

  void setCompleted() {
    _updateState(
      _state.copyWith(
        status: MusicationStatus.completed,
        progress: 1.0,
        errorMessage: null,
      ),
    );

    // Через 3 секунды возвращаем в idle
    Future.delayed(const Duration(seconds: 3), () {
      if (_state.status == MusicationStatus.completed) {
        setIdle();
      }
    });
  }

  void setError(String error) {
    _updateState(
      _state.copyWith(status: MusicationStatus.failed, errorMessage: error),
    );

    // Через 5 секунд возвращаем в idle
    Future.delayed(const Duration(seconds: 5), () {
      if (_state.status == MusicationStatus.failed) {
        setIdle();
      }
    });
  }

  void setIdle() {
    _updateState(const MusicationState());
  }

  void updateProgress(double progress) {
    _updateState(_state.copyWith(progress: progress.clamp(0.0, 1.0)));
  }
}
