import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_explorer_provider.dart';
import '../providers/tab_provider.dart';
import 'file_explorer_panel.dart';
import 'ai_assistant_panel.dart';
import 'tab_bar.dart';
import 'work_area.dart';

class WorkspaceLayout extends StatelessWidget {
  const WorkspaceLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer2<FileExplorerProvider, TabProvider>(
        builder: (context, fileExplorerProvider, tabProvider, child) {
          if (fileExplorerProvider.isLoading || 
              tabProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (fileExplorerProvider.error != null || 
              tabProvider.error != null) {
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
                    'Ошибка загрузки workspace',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fileExplorerProvider.error ?? 
                    tabProvider.error ?? 'Неизвестная ошибка',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      fileExplorerProvider.clearError();
                      tabProvider.clearError();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return const Row(
            children: [
              // Левая панель - файловый проводник (может быть свернута)
              FileExplorerPanel(),
              
              // Центральная область - вкладки + контент
              Expanded(
                child: Column(
                  children: [
                    TabBarWidget(),
                    Expanded(child: WorkArea()),
                  ],
                ),
              ),
              
              // Правая панель - AI ассистент (может быть свернута)
              AiAssistantPanel(),
            ],
          );
        },
      ),
    );
  }






}
