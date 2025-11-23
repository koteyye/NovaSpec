import 'package:flutter/material.dart';
import '../../project/providers/project_provider.dart';
import '../../musication/widgets/musication_indicator.dart';
import '../../../shared/models/project_status.dart';

class StatusBar extends StatelessWidget {
  final ProjectProvider projectProvider;
  final bool showProgress;
  final double? progressValue;
  final String? progressMessage;

  const StatusBar({
    super.key,
    required this.projectProvider,
    this.showProgress = false,
    this.progressValue,
    this.progressMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left section - Status and project info
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 16),
                
                // Project status indicator
                _buildStatusIndicator(context),
                
                const SizedBox(width: 16),
                
                // Project name and path
                if (projectProvider.hasActiveProject) ...[
                  _buildProjectInfo(context),
                  const SizedBox(width: 16),
                ],
                
                // Progress indicator
                if (showProgress) ...[
                  _buildProgressIndicator(context),
                  const SizedBox(width: 16),
                ],
              ],
            ),
          ),
          
          // Right section - Additional info
          Row(
            children: [
              // Musication indicator
              const MusicationIndicator(),
              const SizedBox(width: 16),
              
              // File accessibility status
              if (projectProvider.hasActiveProject) ...[
                _buildFileAccessibilityStatus(context),
                const SizedBox(width: 16),
              ],
              
              // Timestamp
              _buildTimestamp(context),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, child) {
        final status = projectProvider.projectStatus;
        final theme = Theme.of(context);
        
        Color statusColor;
        IconData statusIcon;
        String statusText;
        
        if (!projectProvider.hasActiveProject) {
          statusColor = Colors.grey;
          statusIcon = Icons.circle_outlined;
          statusText = 'Нет проекта';
        } else {
          // Use string-based status from projectProvider
          if (status == 'Нет проекта') {
            statusColor = Colors.grey;
            statusIcon = Icons.circle_outlined;
            statusText = 'Нет проекта';
          } else if (status == 'Есть изменения') {
            statusColor = Colors.orange;
            statusIcon = Icons.circle;
            statusText = 'Есть изменения';
          } else {
            statusColor = Colors.green;
            statusIcon = Icons.circle;
            statusText = 'Сохранено';
          }
        }

        return Row(
          children: [
            Icon(
              statusIcon,
              size: 8,
              color: statusColor,
            ),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, child) {
        final project = projectProvider.currentProject;
        if (project == null || project.isEmpty) return const SizedBox.shrink();
        
        final theme = Theme.of(context);
        
        return Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              project.name,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getShortPath(project.filePath),
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 14,
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        if (progressMessage != null) ...[
          const SizedBox(width: 8),
          Text(
            progressMessage!,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileAccessibilityStatus(BuildContext context) {
    return ListenableBuilder(
      listenable: projectProvider,
      builder: (context, child) {
        final project = projectProvider.currentProject;
        if (project == null || project.isEmpty) return const SizedBox.shrink();
        
        final theme = Theme.of(context);
        final isAccessible = project.status != ProjectStatus.inaccessible && project.status != ProjectStatus.error;
        
        return Row(
          children: [
            Icon(
              isAccessible ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              size: 12,
              color: isAccessible 
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                  : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              isAccessible ? 'Доступен' : 'Недоступен',
              style: TextStyle(
                fontSize: 11,
                color: isAccessible 
                    ? theme.colorScheme.onSurfaceVariant
                    : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    return Text(
      _formatTime(now),
      style: TextStyle(
        fontSize: 11,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  String _getShortPath(String fullPath) {
    if (fullPath.isEmpty) return '';
    
    final parts = fullPath.split(RegExp(r'[\\/]'));
    if (parts.length <= 2) return fullPath;
    
    // Show only the last 2 parts of the path
    return '.../${parts[parts.length - 2]}/${parts.last}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Status bar with additional features
class EnhancedStatusBar extends StatefulWidget {
  final ProjectProvider projectProvider;
  final bool showProgress;
  final double? progressValue;
  final String? progressMessage;
  final List<StatusBarItem>? additionalItems;

  const EnhancedStatusBar({
    super.key,
    required this.projectProvider,
    this.showProgress = false,
    this.progressValue,
    this.progressMessage,
    this.additionalItems,
  });

  @override
  State<EnhancedStatusBar> createState() => _EnhancedStatusBarState();
}

class _EnhancedStatusBarState extends State<EnhancedStatusBar> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) {
      return _buildExpandedStatusBar(context);
    } else {
      return _buildCompactStatusBar(context);
    }
  }

  Widget _buildCompactStatusBar(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => setState(() => _isExpanded = true),
      child: StatusBar(
        projectProvider: widget.projectProvider,
        showProgress: widget.showProgress,
        progressValue: widget.progressValue,
        progressMessage: widget.progressMessage,
      ),
    );
  }

  Widget _buildExpandedStatusBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          
          // Close button
          GestureDetector(
            onTap: () => setState(() => _isExpanded = false),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Expanded content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First row - Basic info
                Row(
                  children: [
                    _buildStatusIndicator(context),
                    const SizedBox(width: 16),
                    if (widget.projectProvider.hasActiveProject) ...[
                      _buildProjectInfo(context),
                      const SizedBox(width: 16),
                    ],
                    if (widget.showProgress) ...[
                      _buildProgressIndicator(context),
                      const SizedBox(width: 16),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Second row - Additional info
                Row(
                  children: [
                    if (widget.projectProvider.hasActiveProject) ...[
                      _buildDetailedProjectInfo(context),
                      const SizedBox(width: 16),
                    ],
                    if (widget.additionalItems != null) ...[
                      ...widget.additionalItems!.map((item) => _buildStatusBarItem(item)),
                    ],
                    const Spacer(),
                    _buildDetailedTimestamp(context),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    // Reuse the same logic from compact status bar
    return StatusBar(
      projectProvider: widget.projectProvider,
      showProgress: false,
    ).build(context);
  }

  Widget _buildProjectInfo(BuildContext context) {
    // Reuse the same logic from compact status bar
    return StatusBar(
      projectProvider: widget.projectProvider,
      showProgress: false,
    ).build(context);
  }

  Widget _buildProgressIndicator(BuildContext context) {
    // Reuse the same logic from compact status bar
    return StatusBar(
      projectProvider: widget.projectProvider,
      showProgress: widget.showProgress,
      progressValue: widget.progressValue,
      progressMessage: widget.progressMessage,
    ).build(context);
  }

  Widget _buildDetailedProjectInfo(BuildContext context) {
    final project = widget.projectProvider.currentProject;
    if (project == null || project.isEmpty) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Создан: ${_formatDateTime(project.createdAt)}',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        Text(
          'Изменен: ${_formatDateTime(project.modifiedAt)}',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBarItem(StatusBarItem item) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: 12,
              color: item.color ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            item.text,
            style: TextStyle(
              fontSize: 10,
              color: item.color ?? Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTimestamp(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatDate(now),
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        Text(
          _formatTime(now),
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class StatusBarItem {
  final String text;
  final IconData? icon;
  final Color? color;

  const StatusBarItem({
    required this.text,
    this.icon,
    this.color,
  });
}