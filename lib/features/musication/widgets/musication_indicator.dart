import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/musication_provider.dart';
import '../models/musication_state.dart';

class MusicationIndicator extends StatelessWidget {
  const MusicationIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicationProvider>(
      builder: (context, provider, child) {
        debugPrint('🎵 MusicationIndicator.build: isActive=${provider.isActive}, status=${provider.state.status}');
        
        if (!provider.isActive) {
          return const SizedBox.shrink();
        }

        final isFailed = provider.state.status == MusicationStatus.failed;
        final isCompleted = provider.state.status == MusicationStatus.completed;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка статуса
              if (!isFailed && !isCompleted)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                )
              else if (isCompleted)
                Icon(
                  Icons.check_circle,
                  size: 10,
                  color: Colors.green.withValues(alpha: 0.7),
                )
              else if (isFailed)
                Icon(
                  Icons.error,
                  size: 10,
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                ),
              
              const SizedBox(width: 4),

              // Текст статуса
              Text(
                provider.getLocalizedText(context),
                style: TextStyle(
                  color: isFailed 
                      ? Theme.of(context).colorScheme.error.withValues(alpha: 0.8)
                      : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

