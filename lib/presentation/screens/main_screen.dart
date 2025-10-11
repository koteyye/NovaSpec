import 'package:flutter/material.dart';
import 'package:novaspec/presentation/widgets/top_bar/top_bar.dart';
import 'package:novaspec/presentation/widgets/file_explorer/file_explorer.dart';
import 'package:novaspec/presentation/widgets/spec_preview/spec_preview.dart';
import 'package:novaspec/presentation/widgets/ai_assistant/ai_assistant.dart';
import 'package:novaspec/presentation/widgets/status_bar/status_bar.dart';

/// Главный экран приложения
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          // TopBar
          TopBar(),

          // Основная область
          Expanded(
            child: Row(
              children: [
                // FileExplorer
                FileExplorer(),

                // SpecPreview
                Expanded(
                  child: SpecPreview(),
                ),

                // AIAssistant
                AIAssistant(),
              ],
            ),
          ),

          // StatusBar
          StatusBar(),
        ],
      ),
    );
  }
}
