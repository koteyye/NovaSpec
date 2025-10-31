import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfViewer extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PdfViewer({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _getPdfInfo();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
        ),
      );
    
    _loadPdf();
  }

  void _loadPdf() {
    // For now, we'll create a simple HTML viewer that can display PDF
    // In a real implementation, you might want to use PDF.js or a native PDF viewer
    final pdfHtml = _generatePdfViewerHtml();
    _controller.loadHtmlString(pdfHtml);
  }

  String _generatePdfViewerHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${widget.fileName}</title>
    <style>
        body {
            margin: 0;
            padding: 20px;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f5f5f5;
        }
        .pdf-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
        }
        .pdf-header {
            border-bottom: 1px solid #e0e0e0;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        .pdf-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin: 0 0 10px 0;
        }
        .pdf-info {
            display: flex;
            gap: 20px;
            color: #666;
            font-size: 14px;
        }
        .pdf-content {
            min-height: 400px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #fafafa;
            border: 2px dashed #ddd;
            border-radius: 4px;
            margin: 20px 0;
        }
        .pdf-placeholder {
            text-align: center;
            color: #666;
        }
        .pdf-icon {
            font-size: 64px;
            margin-bottom: 20px;
            color: #e74c3c;
        }
        .controls {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 20px;
        }
        .btn {
            padding: 8px 16px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn:hover {
            background: #f0f0f0;
        }
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="pdf-container">
        <div class="pdf-header">
            <h1 class="pdf-title">${widget.fileName}</h1>
            <div class="pdf-info">
                <span>📄 PDF Document</span>
                <span>📁 ${widget.filePath}</span>
            </div>
        </div>
        
        <div class="pdf-content">
            <div class="pdf-placeholder">
                <div class="pdf-icon">📄</div>
                <h3>Просмотр PDF</h3>
                <p>Для полноценного просмотра PDF файлов требуется интеграция с PDF.js или нативным PDF рендерером.</p>
                <p>Текущий файл: ${widget.fileName}</p>
            </div>
        </div>
        
        <div class="controls">
            <button class="btn" onclick="window.flutter_inappwebview.callHandler('previousPage')">← Предыдущая</button>
            <span style="padding: 8px 16px;">Страница <span id="currentPage">1</span> из <span id="totalPages">?</span></span>
            <button class="btn" onclick="window.flutter_inappwebview.callHandler('nextPage')">Следующая →</button>
            <button class="btn" onclick="window.flutter_inappwebview.callHandler('zoomIn')">Увеличить</button>
            <button class="btn" onclick="window.flutter_inappwebview.callHandler('zoomOut')">Уменьшить</button>
        </div>
    </div>
    
    <script>
        // JavaScript handlers for PDF controls
        window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            console.log('PDF Viewer ready');
        });
    </script>
</body>
</html>
    ''';
  }

  Future<void> _getPdfInfo() async {
    try {
      // In a real implementation, you would get this from the PDF
      setState(() {
        _totalPages = 1; // Placeholder
      });
    } catch (e) {
      print('Error getting PDF info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Toolbar
          _buildToolbar(context),
          
          // Content
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Закрыть',
          ),
          
          // File info
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red[700],
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
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_totalPages > 0)
                        Text(
                          'Страница $_currentPage из $_totalPages',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation controls
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? _previousPage : null,
                icon: const Icon(Icons.keyboard_arrow_left),
                tooltip: 'Предыдущая страница',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages ? _nextPage : null,
                icon: const Icon(Icons.keyboard_arrow_right),
                tooltip: 'Следующая страница',
              ),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme.of(context).dividerColor,
              ),
              IconButton(
                onPressed: _zoomOut,
                icon: const Icon(Icons.zoom_out),
                tooltip: 'Уменьшить',
              ),
              Text(
                '${(_zoomLevel * 100).round()}%',
                style: const TextStyle(fontSize: 12),
              ),
              IconButton(
                onPressed: _zoomIn,
                icon: const Icon(Icons.zoom_in),
                tooltip: 'Увеличить',
              ),
              IconButton(
                onPressed: _resetZoom,
                icon: const Icon(Icons.fit_screen),
                tooltip: 'По размеру экрана',
              ),
            ],
          ),
          
          // More options
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Свойства документа'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Печать'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Экспортировать'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return _buildErrorState(context, _error!);
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка PDF...'),
          ],
        ),
      );
    }

    return WebViewWidget(controller: _controller);
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(32),
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
            'Ошибка загрузки PDF',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPdf,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _navigateToPage();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      _navigateToPage();
    }
  }

  void _navigateToPage() {
    _controller.runJavaScript('''
      document.getElementById('currentPage').textContent = '$_currentPage';
    ''');
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.2).clamp(0.5, 3.0);
    });
    _updateZoom();
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.2).clamp(0.5, 3.0);
    });
    _updateZoom();
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
    _updateZoom();
  }

  void _updateZoom() {
    _controller.runJavaScript('''
      document.body.style.zoom = '$_zoomLevel';
    ''');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'info':
        _showPdfInfo();
        break;
      case 'print':
        _printPdf();
        break;
      case 'export':
        _exportPdf();
        break;
    }
  }

  void _showPdfInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Свойства PDF документа'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _getPdfProperties(),
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
                _buildInfoRow('Страниц:', '$_totalPages'),
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

  Future<Map<String, dynamic>> _getPdfProperties() async {
    try {
      final file = File(widget.filePath);
      final stat = await file.stat();
      
      return {
        'size': _formatFileSize(stat.size),
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

  void _printPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция печати будет доступна в следующей версии')),
    );
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция экспорта будет доступна в следующей версии')),
    );
  }
}
