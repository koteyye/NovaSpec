import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/routes/app_routes.dart';

class MacOSMenuBar extends StatelessWidget {
  final VoidCallback onNewProject;
  final VoidCallback onOpenProject;
  final VoidCallback onSaveProject;
  final VoidCallback onSaveProjectAs;
  final VoidCallback onExit;

  const MacOSMenuBar({
    super.key,
    required this.onNewProject,
    required this.onOpenProject,
    required this.onSaveProject,
    required this.onSaveProjectAs,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildAppMenu(context, localizations),
          _buildFileMenu(context, localizations),
          _buildEditMenu(context, localizations),
          _buildViewMenu(context, localizations),
          _buildWindowMenu(context, localizations),
          _buildHelpMenu(context, localizations),
        ],
      ),
    );
  }

  Widget _buildAppMenu(BuildContext context, AppLocalizations localizations) {
    return _MenuBarButton(
      title: 'NovaSpec',
      onPressed: () => _showAppMenu(context, localizations),
    );
  }

  Widget _buildFileMenu(BuildContext context, AppLocalizations localizations) {
    return _MenuBarButton(
      title: 'Файл',
      onPressed: () => _showFileMenu(context, localizations),
    );
  }

  Widget _buildEditMenu(BuildContext context, AppLocalizations localizations) {
    return _MenuBarButton(
      title: 'Редактирование',
      onPressed: () => _showEditMenu(context, localizations),
    );
  }

  Widget _buildViewMenu(BuildContext context, AppLocalizations localizations) {
    return _MenuBarButton(
      title: 'Вид',
      onPressed: () => _showViewMenu(context, localizations),
    );
  }

  Widget _buildWindowMenu(BuildContext context, AppLocalizations localizations) {
    return _MenuBarButton(
      title: 'Окно',
      onPressed: () => _showWindowMenu(context, localizations),
    );
  }

  Widget _buildHelpMenu(BuildContext context, AppLocalizations localizations) {
    return _MenuBarButton(
      title: 'Справка',
      onPressed: () => _showHelpMenu(context, localizations),
    );
  }

  void _showAppMenu(BuildContext context, AppLocalizations localizations) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(0, 28, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'about',
          onTap: () => _showAboutDialog(context),
          child: const Text('О NovaSpec'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'preferences',
          onTap: () => _showPreferences(context),
          child: const Row(
            children: [
              Text('Настройки'),
              Spacer(),
              Text('⌘,'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'quit',
          onTap: onExit,
          child: const Row(
            children: [
              Text('Выйти из NovaSpec'),
              Spacer(),
              Text('⌘Q'),
            ],
          ),
        ),
      ],
    );
  }

  void _showFileMenu(BuildContext context, AppLocalizations localizations) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(60, 28, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'new',
          onTap: onNewProject,
          child: Row(
            children: [
              const Text('Новый проект'),
              const Spacer(),
              const Text('⌘N'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'open',
          onTap: onOpenProject,
          child: const Row(
            children: [
              Text('Открыть'),
              Spacer(),
              Text('⌘O'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'save',
          onTap: onSaveProject,
          child: const Row(
            children: [
              Text('Сохранить'),
              Spacer(),
              Text('⌘S'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'saveAs',
          onTap: onSaveProjectAs,
          child: const Row(
            children: [
              Text('Сохранить как'),
              Spacer(),
              Text('⌘⇧S'),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditMenu(BuildContext context, AppLocalizations localizations) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(110, 28, 0, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'undo',
          enabled: false,
          child: Row(
            children: [
              Text('Отменить'),
              Spacer(),
              Text('⌘Z'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'redo',
          enabled: false,
          child: Row(
            children: [
              Text('Повторить'),
              Spacer(),
              Text('⌘Y'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'cut',
          enabled: false,
          child: Row(
            children: [
              Text('Вырезать'),
              Spacer(),
              Text('⌘X'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'copy',
          enabled: false,
          child: Row(
            children: [
              Text('Копировать'),
              Spacer(),
              Text('⌘C'),
            ],
          ),
        ),
const PopupMenuItem<String>(
          value: 'paste',
          enabled: false,
          child: Row(
            children: [
              Icon(Icons.content_paste, size: 16),
              SizedBox(width: 8),
              Text('Вставить'),
              Spacer(),
              Text('⌘V'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'selectAll',
          enabled: false,
          child: Row(
            children: [
              Text('Выделить все'),
              Spacer(),
              Text('⌘A'),
            ],
          ),
        ),
      ],
    );
  }

  void _showViewMenu(BuildContext context, AppLocalizations localizations) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(180, 28, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'toggleTheme',
          onTap: () {},
          child: Text('Переключить тему'),
        ),
        PopupMenuItem<String>(
          value: 'toggleSidebar',
          onTap: () {},
          child: Text('Переключить боковую панель'),
        ),
      ],
    );
  }

  void _showWindowMenu(BuildContext context, AppLocalizations localizations) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(230, 28, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'minimize',
          onTap: () {},
          child: const Text('Свернуть'),
        ),
        PopupMenuItem<String>(
          value: 'zoom',
          onTap: () {},
          child: const Text('Масштаб'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'bringAllToFront',
          onTap: () {},
          child: const Text('Все на передний план'),
        ),
      ],
    );
  }

  void _showHelpMenu(BuildContext context, AppLocalizations localizations) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(300, 28, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'help',
          onTap: () {},
          child: const Text('Справка NovaSpec'),
        ),
        PopupMenuItem<String>(
          value: 'shortcuts',
          onTap: () {},
          child: const Text('Горячие клавиши'),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'NovaSpec',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.description, size: 48),
      children: [
        const Text('Создание технических заданий с помощью ИИ-ассистента'),
      ],
    );
  }

  void _showPreferences(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }
}

class _MenuBarButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;

  const _MenuBarButton({
    required this.title,
    required this.onPressed,
  });

  @override
  State<_MenuBarButton> createState() => _MenuBarButtonState();
}

class _MenuBarButtonState extends State<_MenuBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _isHovered 
                ? CupertinoColors.systemGrey5.resolveFrom(context)
                : Colors.transparent,
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.label.resolveFrom(context),
              fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}