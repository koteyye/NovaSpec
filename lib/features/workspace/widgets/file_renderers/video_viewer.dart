import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/services/toast_service.dart';

class VideoViewer extends StatefulWidget {
  final String filePath;
  final String fileName;

  const VideoViewer({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Create video player controller
      _videoPlayerController = VideoPlayerController.file(
        File(widget.filePath),
      );

      // Initialize the controller
      await _videoPlayerController!.initialize();

      // Create chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white54,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Ошибка воспроизведения: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Toolbar
          _buildToolbar(context),
          
          // Video content
          Expanded(
            child: _buildVideoContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Закрыть',
          ),
          
          // File info
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.videocam,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                        FutureBuilder<Duration?>(
                          future: _videoPlayerController!.position,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = _videoPlayerController!.value.duration;
                            return Text(
                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Video controls
          if (_chewieController != null) ...[
            IconButton(
              onPressed: _togglePlayback,
              icon: Icon(
                _videoPlayerController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
              ),
              tooltip: _videoPlayerController!.value.isPlaying ? 'Пауза' : 'Воспроизвести',
            ),
            IconButton(
              onPressed: _toggleFullscreen,
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              tooltip: 'Полноэкранный режим',
            ),
          ],
          
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Свойства видео'),
                  ],
                ),
              ),
                const PopupMenuItem(
                  value: 'playback_speed',
                  child: Row(
                    children: [
                      Icon(Icons.speed),
                      SizedBox(width: 8),
                      Text('Скорость воспроизведения'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'quality',
                child: Row(
                  children: [
                    Icon(Icons.high_quality),
                    SizedBox(width: 8),
                    Text('Качество'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent(BuildContext context) {
    if (_error != null) {
      return _buildErrorState(context, _error!);
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Загрузка видео...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const Center(
      child: Text(
        'Видеоплеер не инициализирован',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки видео',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _initializeVideo();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  void _togglePlayback() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      setState(() {
        if (_videoPlayerController!.value.isPlaying) {
          _videoPlayerController!.pause();
        } else {
          _videoPlayerController!.play();
        }
      });
    }
  }

  void _toggleFullscreen() {
    // TODO: Implement fullscreen functionality
    show(description: 'Полноэкранный режим будет добавлен в следующей версии');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'info':
        _showVideoInfo();
        break;
      case 'playback_speed':
        _showPlaybackSpeedDialog();
        break;
      case 'quality':
        _showQualityDialog();
        break;
    }
  }

  void _showVideoInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Свойства видео'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _getVideoProperties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            final props = snapshot.data ?? {};
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Имя файла:', widget.fileName),
                _buildInfoRow('Путь:', widget.filePath),
                if (props['size'] != null) _buildInfoRow('Размер:', props['size']),
                if (props['duration'] != null) _buildInfoRow('Длительность:', props['duration']),
                if (props['resolution'] != null) _buildInfoRow('Разрешение:', props['resolution']),
                if (props['created'] != null) _buildInfoRow('Создан:', props['created']),
                if (props['modified'] != null) _buildInfoRow('Изменен:', props['modified']),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getVideoProperties() async {
    try {
      final file = File(widget.filePath);
      final stat = await file.stat();
      
      String? resolution;
      String? duration;
      
      if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
        final size = _videoPlayerController!.value.size;
        resolution = '${size.width.toInt()} x ${size.height.toInt()}';
        duration = _formatDuration(_videoPlayerController!.value.duration);
      }
      
      return {
        'size': _formatFileSize(stat.size),
        'duration': duration ?? 'Неизвестно',
        'resolution': resolution ?? 'Неизвестно',
        'created': stat.changed.toString().split('.')[0],
        'modified': stat.modified.toString().split('.')[0],
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скорость воспроизведения'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
            return RadioListTile<double>(
              title: Text('${speed}x'),
              value: speed,
              groupValue: _videoPlayerController?.value.playbackSpeed ?? 1.0,
              onChanged: (value) {
                if (value != null && _videoPlayerController != null) {
                  _videoPlayerController!.setPlaybackSpeed(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showQualityDialog() {
    show(description: 'Изменение качества будет доступно в следующей версии');
  }
}
