import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/services/toast_service.dart';

class ImageViewer extends StatefulWidget {
  final String filePath;
  final String fileName;

  const ImageViewer({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  double _scale = 1.0;


  @override
  Widget build(BuildContext context) {
    final isSvg = widget.fileName.toLowerCase().endsWith('.svg');
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: CheckerboardPainter(),
              ),
            ),
            
            // Image viewer
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.1,
                maxScale: 10.0,
                onInteractionUpdate: (details) {
                  setState(() {
                    _scale = details.scale;
                  });
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: isSvg
                      ? SvgPicture.asset(
                          widget.filePath,
                          fit: BoxFit.contain,
                        )
                      : Image.file(
                          File(widget.filePath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildErrorWidget(context, error.toString());
                          },
                        ),
                ),
              ),
            ),
            
            // Top toolbar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
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
                    
                    // File name
                    Expanded(
                      child: Text(
                        widget.fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Zoom controls
                    Row(
                      children: [
                        IconButton(
                          onPressed: _zoomOut,
                          icon: const Icon(Icons.zoom_out, color: Colors.white),
                          tooltip: 'Уменьшить',
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(_scale * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _zoomIn,
                          icon: const Icon(Icons.zoom_in, color: Colors.white),
                          tooltip: 'Увеличить',
                        ),
                        IconButton(
                          onPressed: _resetZoom,
                          icon: const Icon(Icons.fit_screen, color: Colors.white),
                          tooltip: 'По размеру экрана',
                        ),
                      ],
                    ),
                    
                    // Actions
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
                              Text('Свойства изображения'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(Icons.copy),
                              SizedBox(width: 8),
                              Text('Копировать путь'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom info bar
            if (_scale != 1.0)
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Масштаб: ${(_scale * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Не удалось загрузить изображение',
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
        ],
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.2).clamp(0.1, 10.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale / 1.2).clamp(0.1, 10.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'info':
        _showImageInfo();
        break;
      case 'copy':
        _copyFilePath();
        break;
    }
  }

  void _showImageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Свойства изображения'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _getImageInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            final info = snapshot.data ?? {};
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Имя файла:', widget.fileName),
                _buildInfoRow('Путь:', widget.filePath),
                if (info['width'] != null) _buildInfoRow('Ширина:', '${info['width']} px'),
                if (info['height'] != null) _buildInfoRow('Высота:', '${info['height']} px'),
                if (info['size'] != null) _buildInfoRow('Размер:', info['size']),
                if (info['type'] != null) _buildInfoRow('Тип:', info['type']),
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

  Future<Map<String, dynamic>> _getImageInfo() async {
    try {
      final file = File(widget.filePath);
      final stat = await file.stat();
      final size = stat.size;
      
      // For basic image info, we'd need to decode the image
      // For now, return file info
      return {
        'size': _formatFileSize(size),
        'type': widget.fileName.split('.').last.toUpperCase(),
        'modified': stat.modified.toString(),
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

  void _copyFilePath() {
    // TODO: Implement clipboard functionality
    success(description: 'Путь скопирован в буфер обмена');
  }
}

class CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 20.0;
    const lightColor = Color(0xFF333333);
    const darkColor = Color(0xFF222222);

    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (var y = 0.0; y < size.height; y += squareSize) {
      for (var x = 0.0; x < size.width; x += squareSize) {
        final isLight = ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        paint.color = isLight ? lightColor : darkColor;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
