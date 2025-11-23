import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../providers/musication_provider.dart';
import '../services/musication_service.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/services/di_container.dart';

class MusicationButton extends StatelessWidget {
  final String projectPath;
  final String selectedText;
  final String filePath;

  const MusicationButton({
    super.key,
    required this.projectPath,
    required this.selectedText,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return Consumer<MusicationProvider>(
      builder: (context, provider, child) {
        if (provider.isGenerating) {
          return _buildGeneratingButton(context, provider, l10n);
        }
        return _buildIdleButton(context, l10n, settingsProvider);
      },
    );
  }

  Widget _buildIdleButton(
    BuildContext context,
    AppLocalizations l10n,
    SettingsProvider settingsProvider,
  ) {
    // Кнопка активна, если:
    // 1. Музикация включена в настройках
    // 2. Токен gen-api.ru настроен
    // (selectedText может быть пустым - тогда используется весь файл)
    final isDisabled = !settingsProvider.musicEnabled ||
                       settingsProvider.musicToken.isEmpty;

    return IconButton(
      onPressed: isDisabled 
          ? null 
          : () => _startMusication(context, settingsProvider),
      icon: SvgPicture.asset(
        'assets/icons/music.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(
          isDisabled ? Colors.grey : Theme.of(context).primaryColor,
          BlendMode.srcIn,
        ),
      ),
      tooltip: l10n.musication_button_tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }

  Widget _buildGeneratingButton(
    BuildContext context,
    MusicationProvider provider,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/music.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            Theme.of(context).primaryColor,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => _cancelMusication(context, l10n),
          icon: const Icon(Icons.close, size: 14),
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          padding: EdgeInsets.zero,
          tooltip: l10n.musication_cancel,
        ),
      ],
    );
  }

  Future<void> _startMusication(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<MusicationProvider>(); // Берем из Provider дерева!
    final service = getIt<MusicationService>();
    
    debugPrint('🎵 MusicationButton: Starting musication with provider from context');
    
    // Если selectedText пустой, читаем весь файл
    String textToGenerate = selectedText.trim();
    if (textToGenerate.isEmpty && filePath.isNotEmpty) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          textToGenerate = await file.readAsString();
        }
      } catch (e) {
        debugPrint('🎵 Error reading file: $e');
        textToGenerate = '';
      }
    }

    if (textToGenerate.isEmpty) {
      if (context.mounted) {
        final toastService = getIt<ToastService>();
        toastService.showError(
          title: l10n.musication_error,
          description: 'Выберите текст или откройте файл с содержимым',
        );
      }
      return;
    }

    try {
      // Запускаем процесс музикации
      await service.startMusication(
        projectPath: projectPath,
        selectedText: textToGenerate,
        genre: settingsProvider.musicGenre,
        provider: provider,
      );
    } catch (e) {
      if (context.mounted) {
        provider.setError(e.toString());
        final toastService = getIt<ToastService>();
        toastService.showError(
          title: l10n.musication_error,
          description: e.toString(),
        );
      }
    }
  }

  Future<void> _cancelMusication(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.musication_cancel),
        content: Text(l10n.musication_cancel_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.musication_close),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.musication_cancel),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<MusicationProvider>(); // Берем из Provider дерева!
      provider.setIdle();
    }
  }
}
