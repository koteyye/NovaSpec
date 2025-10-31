import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  final String fileName;

  const AudioPlayerWidget({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 0.8;
  double _playbackSpeed = 1.0;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() => _isLoading = true);
      
      // Set up subscriptions
      _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
        setState(() => _position = position);
      });

      _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
        setState(() => _duration = duration);
      });

      _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
        setState(() => _isPlaying = state == PlayerState.playing);
      });

      // Load the audio file
      await _audioPlayer.setSourceDeviceFile(widget.filePath);
      await _audioPlayer.setVolume(_volume);
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Ошибка загрузки аудио: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Audio icon and info
          _buildAudioInfo(context),
          
          const SizedBox(height: 32),
          
          // Playback controls
          _buildPlaybackControls(context),
          
          const SizedBox(height: 24),
          
          // Progress bar
          _buildProgressBar(context),
          
          const SizedBox(height: 24),
          
          // Volume and speed controls
          _buildAdditionalControls(context),
          
          const SizedBox(height: 24),
          
          // File info
          _buildFileInfo(context),
        ],
      ),
    );
  }

  Widget _buildAudioInfo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          child: Icon(
            _isPlaying ? Icons.graphic_eq : Icons.audiotrack,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          widget.fileName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _formatDuration(_duration),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button (placeholder)
        IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: () {
            // TODO: Implement previous track functionality
          },
          iconSize: 32,
        ),
        
        const SizedBox(width: 16),
        
        // Rewind button
        IconButton(
          icon: const Icon(Icons.replay_10),
          onPressed: _rewind,
          iconSize: 32,
        ),
        
        const SizedBox(width: 16),
        
        // Play/Pause button
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
            onPressed: _isLoading ? null : _togglePlayPause,
            iconSize: 32,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Fast forward button
        IconButton(
          icon: const Icon(Icons.forward_30),
          onPressed: _fastForward,
          iconSize: 32,
        ),
        
        const SizedBox(width: 16),
        
        // Next button (placeholder)
        IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: () {
            // TODO: Implement next track functionality
          },
          iconSize: 32,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: _position.inMilliseconds.toDouble(),
            max: _duration.inMilliseconds.toDouble().clamp(0, double.infinity),
            onChanged: (value) {
              _audioPlayer.seek(Duration(milliseconds: value.round()));
            },
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_position),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              _formatDuration(_duration),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(BuildContext context) {
    return Row(
      children: [
        // Volume control
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.volume_up,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  trackHeight: 2,
                ),
                child: Slider(
                  value: _volume,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() => _volume = value);
                    _audioPlayer.setVolume(value);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 32),
        
        // Speed control
        Expanded(
          child: Column(
            children: [
              Icon(
                Icons.speed,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: DropdownButton<double>(
                  value: _playbackSpeed,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                    return DropdownMenuItem<double>(
                      value: speed,
                      child: Text('${speed}x'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _playbackSpeed = value);
                      _audioPlayer.setPlaybackRate(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Информация о файле',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Имя файла', widget.fileName),
          _buildInfoRow('Путь', widget.filePath),
          _buildInfoRow('Длительность', _formatDuration(_duration)),
          _buildInfoRow('Текущая позиция', _formatDuration(_position)),
          _buildInfoRow('Скорость воспроизведения', '${_playbackSpeed}x'),
          _buildInfoRow('Громкость', '${(_volume * 100).round()}%'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      _showError('Ошибка воспроизведения: $e');
    }
  }

  Future<void> _rewind() async {
    try {
      final newPosition = (_position - const Duration(seconds: 10)) < Duration.zero 
          ? Duration.zero 
          : ((_position - const Duration(seconds: 10)) > _duration ? _duration : (_position - const Duration(seconds: 10)));
      await _audioPlayer.seek(newPosition);
    } catch (e) {
      _showError('Ошибка перемотки: $e');
    }
  }

  Future<void> _fastForward() async {
    try {
      final newPosition = (_position + const Duration(seconds: 30)) < Duration.zero 
          ? Duration.zero 
          : ((_position + const Duration(seconds: 30)) > _duration ? _duration : (_position + const Duration(seconds: 30)));
      await _audioPlayer.seek(newPosition);
    } catch (e) {
      _showError('Ошибка перемотки: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
