import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:novaspec/core/config/theme/ns_colors.dart';
import 'package:novaspec/core/config/theme/ns_spacing.dart';
import 'package:novaspec/core/config/theme/ns_text_styles.dart';

/// Минималистичный аудиоплеер для воспроизведения MP3 файлов
class AudioPlayerWidget extends StatefulWidget {
  final String filePath;

  const AudioPlayerWidget({
    super.key,
    required this.filePath,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer.setFilePath(widget.filePath);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Не удалось загрузить аудио файл';
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_errorMessage != null) {
      return _buildErrorState(isDark);
    }

    return _buildPlayer(context, isDark);
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
            ),
            const SizedBox(height: NsSpacing.md),
            Text(
              'Загрузка аудио...',
              style: NsTextStyles.bodyMedium(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? NsColorsDark.destructive : NsColorsLight.destructive,
            ),
            const SizedBox(height: NsSpacing.md),
            Text(
              _errorMessage!,
              style: NsTextStyles.bodyMedium(context).copyWith(
                color: isDark ? NsColorsDark.destructive : NsColorsLight.destructive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(NsSpacing.xl),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(NsSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? NsColorsDark.card : NsColorsLight.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? NsColorsDark.border : NsColorsLight.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка музыки
              Icon(
                Icons.music_note,
                size: 80,
                color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
              ),
              const SizedBox(height: NsSpacing.lg),

              // Название файла
              Text(
                widget.filePath.split('/').last.split('\\').last,
                style: NsTextStyles.h4(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: NsSpacing.lg),

              // Прогресс бар
              StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _audioPlayer.duration ?? Duration.zero;
                  final progress = duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0.0;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                          inactiveTrackColor: isDark ? NsColorsDark.muted : NsColorsLight.muted,
                          thumbColor: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                          overlayColor: (isDark ? NsColorsDark.primary : NsColorsLight.primary).withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final newPosition = Duration(
                              milliseconds: (value * duration.inMilliseconds).round(),
                            );
                            _audioPlayer.seek(newPosition);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: NsSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: NsTextStyles.bodySmall(context),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: NsTextStyles.bodySmall(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: NsSpacing.md),

              // Кнопки управления
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Кнопка перемотки назад
                  IconButton(
                    onPressed: () {
                      final currentPosition = _audioPlayer.position;
                      final newPosition = currentPosition - const Duration(seconds: 10);
                      _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
                    },
                    icon: const Icon(Icons.replay_10),
                    iconSize: 32,
                    color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
                  ),
                  const SizedBox(width: NsSpacing.md),

                  // Кнопка Play/Pause
                  StreamBuilder<PlayerState>(
                    stream: _audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final isPlaying = playerState?.playing ?? false;
                      final processingState = playerState?.processingState;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (isPlaying) {
                              _audioPlayer.pause();
                            } else {
                              _audioPlayer.play();
                            }
                          },
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 32,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: NsSpacing.md),

                  // Кнопка перемотки вперед
                  IconButton(
                    onPressed: () {
                      final currentPosition = _audioPlayer.position;
                      final duration = _audioPlayer.duration ?? Duration.zero;
                      final newPosition = currentPosition + const Duration(seconds: 10);
                      _audioPlayer.seek(newPosition > duration ? duration : newPosition);
                    },
                    icon: const Icon(Icons.forward_10),
                    iconSize: 32,
                    color: isDark ? NsColorsDark.foreground : NsColorsLight.foreground,
                  ),
                ],
              ),
              const SizedBox(height: NsSpacing.md),

              // Регулятор громкости
              StreamBuilder<double>(
                stream: _audioPlayer.volumeStream,
                builder: (context, snapshot) {
                  final volume = snapshot.data ?? 1.0;

                  return Row(
                    children: [
                      Icon(
                        volume == 0 ? Icons.volume_off : Icons.volume_up,
                        color: isDark ? NsColorsDark.mutedForeground : NsColorsLight.mutedForeground,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                            activeTrackColor: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                            inactiveTrackColor: isDark ? NsColorsDark.muted : NsColorsLight.muted,
                            thumbColor: isDark ? NsColorsDark.primary : NsColorsLight.primary,
                            overlayColor: (isDark ? NsColorsDark.primary : NsColorsLight.primary).withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: volume,
                            onChanged: (value) {
                              _audioPlayer.setVolume(value);
                            },
                          ),
                        ),
                      ),
                      Text(
                        '${(volume * 100).round()}%',
                        style: NsTextStyles.bodySmall(context),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
