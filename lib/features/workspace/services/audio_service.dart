import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AudioService {
  static const List<String> supportedFormats = [
    'mp3',
    'wav',
    'm4a',
    'aac',
    'flac',
  ];

  /// Синхронная проверка аудио файла только по расширению
  /// Не создает AudioPlayer, безопасна для использования
  bool isValidAudioFile(String filePath) {
    try {
      final extension = filePath.toLowerCase().split('.').last;
      if (!supportedFormats.contains(extension)) {
        return false;
      }

      final file = File(filePath);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  Future<Duration?> getAudioDuration(String filePath) async {
    AudioPlayer? tempPlayer;
    try {
      tempPlayer = AudioPlayer();
      await tempPlayer.setSourceDeviceFile(filePath);
      return await tempPlayer.getDuration();
    } catch (e) {
      return null;
    } finally {
      await tempPlayer?.dispose();
    }
  }

  Future<Map<String, dynamic>> getAudioMetadata(String filePath) async {
    AudioPlayer? tempPlayer;
    try {
      final file = File(filePath);
      final stat = await file.stat();

      tempPlayer = AudioPlayer();
      await tempPlayer.setSourceDeviceFile(filePath);
      final duration = await tempPlayer.getDuration();

      return {
        'filePath': filePath,
        'fileName': file.path.split(Platform.pathSeparator).last,
        'fileSize': stat.size,
        'lastModified': stat.modified,
        'duration': duration,
        'durationText': duration != null
            ? _formatDuration(duration)
            : 'Unknown',
        'extension': filePath.toLowerCase().split('.').last,
      };
    } catch (e) {
      throw Exception('Failed to get audio metadata: $e');
    } finally {
      await tempPlayer?.dispose();
    }
  }

  List<String> getSupportedFormats() {
    return List.from(supportedFormats);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
