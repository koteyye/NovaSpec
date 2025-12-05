import 'package:flutter/material.dart';
import 'dart:io';
import '../viewers/markdown_viewer_simple.dart';
import '../viewers/html_viewer_simple.dart';
import '../viewers/audio_player_simple.dart';
import '../viewers/code_editor_simple.dart';
import '../viewers/swagger_viewer_simple.dart';
import '../services/markdown_service.dart';
import '../services/html_service.dart';
import '../services/openapi_service.dart';

class FileViewerRouter extends StatelessWidget {
  final String filePath;
  final Function(String)? onContentChanged;

  const FileViewerRouter({
    super.key,
    required this.filePath,
    this.onContentChanged,
  });

  Future<Widget> _buildViewer() async {
    final file = File(filePath);
    final extension = file.path.toLowerCase().split('.').last;

    // Markdown файлы
    if (MarkdownService().isValidMarkdownFile(filePath)) {
      return MarkdownViewerSimple(
        filePath: filePath,
        onContentChanged: onContentChanged,
      );
    }

    // HTML файлы
    if (HtmlService().isValidHtmlFile(filePath)) {
      return HtmlViewerSimple(
        filePath: filePath,
        onContentChanged: onContentChanged,
      );
    }

    // Аудио файлы - проверяем только расширение, без создания AudioPlayer
    const supportedAudioFormats = ['mp3', 'wav', 'm4a', 'aac', 'flac'];
    if (supportedAudioFormats.contains(extension)) {
      // Дополнительно проверяем, что файл существует
      if (await file.exists()) {
        return AudioPlayerSimple(
          filePath: filePath,
          onContentChanged: onContentChanged,
        );
      }
    }

    // OpenAPI/Swagger файлы
    if (OpenAPIService.supportedExtensions.contains(extension)) {
      return SwaggerViewerSimple(
        filePath: filePath,
        onContentChanged: onContentChanged,
      );
    }

    // Кодовые файлы и все остальное
    return CodeEditorSimple(
      filePath: filePath,
      onContentChanged: onContentChanged,
    );
  }

  Widget _buildErrorWidget(BuildContext context, dynamic error) {
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
            'Ошибка открытия файла',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Не удалось определить тип файла: $filePath',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка: $error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _buildViewer(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error);
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
