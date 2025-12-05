import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../../shared/widgets/modern_button.dart';
import '../../../core/services/toast_service.dart';

class AudioPlayerSimple extends StatefulWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const AudioPlayerSimple({
    super.key,
    required this.filePath,
    this.onContentChanged,
  });

  @override
  State<AudioPlayerSimple> createState() => AudioPlayerSimpleState();
}

class AudioPlayerSimpleState extends State<AudioPlayerSimple> {
  AudioPlayer? _audioPlayer;
  bool _isLoading = false;
  bool _disposed = false;
  bool _isPlaying = false;
  String? _errorMessage;
  String? _fileName;
  Duration? _duration;
  Duration _position = Duration.zero;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _loadAudioFile();
  }

  @override
  void dispose() {
    _disposed = true;
    // Отменяем подписки на стримы
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _positionSubscription = null;
    _stateSubscription = null;
    // Останавливаем и удаляем плеер
    _audioPlayer?.stop().catchError((_) {});
    _audioPlayer?.dispose();
    _audioPlayer = null;
    super.dispose();
  }

  void _setupListeners() {
    // Отменяем предыдущие подписки если есть
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();

    // Подписываемся на изменение позиции
    _positionSubscription = _audioPlayer?.onPositionChanged.listen(
      (position) {
        if (!_disposed && mounted) {
          setState(() {
            _position = position;
          });
        }
      },
      onError: (error) {
        // Игнорируем ошибки стрима
      },
      cancelOnError: false,
    );

    // Подписываемся на изменение состояния плеера
    _stateSubscription = _audioPlayer?.onPlayerStateChanged.listen(
      (state) {
        if (!_disposed && mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      },
      onError: (error) {
        // Игнорируем ошибки стрима
      },
      cancelOnError: false,
    );
  }

  Future<void> _loadAudioFile() async {
    if (_disposed || !mounted) return;
    setState(() => _isLoading = true);
    _errorMessage = null;

    AudioPlayer? tempPlayer;

    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        throw Exception('Файл не найден');
      }

      // ВНИМАНИЕ: Создание AudioPlayer может вызвать warning в логах на Windows:
      // "channel sent a message from native to Flutter on a non-platform thread"
      // Это известная проблема плагина audioplayers, не приводящая к крашу.
      // См: https://github.com/bluefireteam/audioplayers/issues
      tempPlayer = AudioPlayer();

      // Устанавливаем режим остановки при завершении
      await tempPlayer.setReleaseMode(ReleaseMode.stop);

      // Устанавливаем источник без автозапуска
      await tempPlayer.setSourceDeviceFile(widget.filePath);

      // Проверяем состояние перед получением duration
      if (_disposed || !mounted) {
        await tempPlayer.dispose();
        return;
      }

      final duration = await tempPlayer.getDuration();

      // Если всё ок и виджет жив, присваиваем плеер
      if (_disposed || !mounted) {
        await tempPlayer.dispose();
        return;
      }

      _audioPlayer = tempPlayer;

      // Настраиваем слушатели только после успешной загрузки
      _setupListeners();

      if (_disposed || !mounted) return;
      setState(() {
        _fileName = file.path.split(Platform.pathSeparator).last;
        _duration = duration;
        _isLoading = false;
      });
    } catch (e) {
      // Очищаем временный плеер при ошибке
      if (tempPlayer != null && _audioPlayer != tempPlayer) {
        await tempPlayer.dispose().catchError((_) {});
      }

      if (_disposed || !mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (!_disposed && mounted) {
        error(description: 'Ошибка загрузки аудио: ${e.toString()}');
      }
    }
  }

  Future<void> _play() async {
    try {
      if (_audioPlayer == null || _disposed) return;
      await _audioPlayer!.resume();
    } catch (e) {
      if (!_disposed && mounted) {
        error(description: 'Ошибка воспроизведения: ${e.toString()}');
      }
    }
  }

  Future<void> _pause() async {
    try {
      if (_audioPlayer == null || _disposed) return;
      await _audioPlayer!.pause();
    } catch (e) {
      if (!_disposed && mounted) {
        error(description: 'Ошибка паузы: ${e.toString()}');
      }
    }
  }

  Future<void> _stop() async {
    try {
      if (_audioPlayer == null || _disposed) return;
      await _audioPlayer!.stop();
      if (_disposed || !mounted) return;
      setState(() {
        _position = Duration.zero;
      });
    } catch (e) {
      if (!_disposed && mounted) {
        error(description: 'Ошибка остановки: ${e.toString()}');
      }
    }
  }

  Widget _buildPlayerControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Иконка аудио
        Icon(
          Icons.audiotrack,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),

        // Имя файла
        if (_fileName != null)
          Text(
            _fileName!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 8),

        // Прогресс-бар
        if (_duration != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: 300,
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    min: 0,
                    max: _duration!.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final newPosition = Duration(seconds: value.toInt());
                      await _audioPlayer?.seek(newPosition);
                      setState(() {
                        _position = newPosition;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        _formatDuration(_duration!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Кнопки управления
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                size: 56,
              ),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _isPlaying ? _pause : _play,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.stop_circle, size: 48),
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              onPressed: _stop,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки аудио',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Повторить',
              type: ButtonType.primary,
              onPressed: _loadAudioFile,
            ),
          ],
        ),
      );
    }

    return Center(child: _buildPlayerControls());
  }
}
