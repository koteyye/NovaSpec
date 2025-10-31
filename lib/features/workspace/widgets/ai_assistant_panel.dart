import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/panel_provider.dart';

class AiAssistantPanel extends StatelessWidget {
  const AiAssistantPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PanelProvider>(
      builder: (context, panelProvider, child) {
        if (panelProvider.isAiAssistantCollapsed) {
          return Container(
            width: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 16),
                      onPressed: () => panelProvider.toggleAiAssistant(),
                      tooltip: 'Развернуть AI ассистента',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: 320,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // AI Assistant content
              Expanded(
                child: _buildAiAssistantContent(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
          const Icon(Icons.smart_toy, size: 16),
          const SizedBox(width: 8),
          const Text(
            'AI Ассистент',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 16),
            onPressed: () => context.read<PanelProvider>().toggleAiAssistant(),
            tooltip: 'Свернуть AI ассистента',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'AI Ассистент',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Задайте вопрос об вашем проекте',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
