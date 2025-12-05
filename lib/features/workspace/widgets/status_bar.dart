import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tab_provider.dart';
import '../providers/file_explorer_provider.dart';
import '../../musication/widgets/musication_indicator.dart';
import '../../musication/providers/musication_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Consumer3<TabProvider, FileExplorerProvider, MusicationProvider>(
        builder: (context, tabProvider, fileExplorerProvider, musicationProvider, child) {
          debugPrint('🎵 StatusBar rebuild: musicationProvider.isActive=${musicationProvider.isActive}');
          return Row(
            children: [
              // File info
              Expanded(
                child: _buildFileInfo(context, tabProvider),
              ),
              
              // Musication progress indicator
              const MusicationIndicator(),
              const SizedBox(width: 4),
              
              // Position info (placeholder)
              _buildPositionInfo(context),
              
              // Encoding info
              _buildEncodingInfo(context),
              
              // Language info
              _buildLanguageInfo(context, tabProvider),
              
              // Git branch (placeholder)
              _buildGitInfo(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFileInfo(BuildContext context, TabProvider tabProvider) {
    final activeTab = tabProvider.activeTab;
    
    if (activeTab == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const SizedBox(width: 8),
        Icon(
          _getFileIcon(activeTab.path),
          size: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 4),
        Text(
          activeTab.title,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (activeTab.isModified) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.circle,
            size: 6,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ],
    );
  }

  Widget _buildPositionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Ln 1, Col 1',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildEncodingInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'UTF-8',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildLanguageInfo(BuildContext context, TabProvider tabProvider) {
    final activeTab = tabProvider.activeTab;
    
    if (activeTab == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        activeTab.language?.toUpperCase() ?? 'Plain',
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildGitInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.account_tree,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(
            'main',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'dart':
        return Icons.code;
      case 'js':
        return Icons.javascript;
      case 'ts':
        return Icons.code;
      case 'py':
        return Icons.psychology;
      case 'java':
        return Icons.coffee;
      case 'html':
        return Icons.web;
      case 'css':
        return Icons.palette;
      case 'json':
        return Icons.data_object;
      case 'md':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
