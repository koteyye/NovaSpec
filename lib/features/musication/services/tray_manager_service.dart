import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:local_notifier/local_notifier.dart';

class TrayManagerService with TrayListener, WindowListener {
  static const String _trayIconPath = 'assets/icons/tray/tray_icon.png';

  bool _isInitialized = false;
  bool _hasPendingNotification = false;

  bool get isInitialized => _isInitialized;
  bool get hasPendingNotification => _hasPendingNotification;

  Future<void> initialize() async {
    if (_isInitialized ||
        !Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      return;
    }

    try {
      // Инициализация tray_manager
      await trayManager.setIcon(_trayIconPath);
      await trayManager.setToolTip('NovaSpec - Музикация в фоне');

      // Создаем меню трея
      final menu = Menu(
        items: [
          MenuItem(
            label: 'Показать NovaSpec',
            onClick: (menuItem) => _restoreWindow(),
          ),
          MenuItem.separator(),
          MenuItem(
            label: 'Завершить работу',
            onClick: (menuItem) => _forceExit(),
          ),
        ],
      );

      await trayManager.setContextMenu(menu);

      // Добавляем слушатели
      windowManager.addListener(this);

      _isInitialized = true;
      debugPrint('TrayManager инициализирован');
    } catch (e) {
      debugPrint('Ошибка инициализации TrayManager: $e');
    }
  }

  @override
  void onTrayIconMouseDown() {
    // Восстанавливаем окно при клике на иконку
    _restoreWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Показываем контекстное меню при правом клике
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    // Обработка кликов по пунктам меню
    switch (menuItem.label) {
      case 'Показать NovaSpec':
        _restoreWindow();
        break;
      case 'Завершить работу':
        _forceExit();
        break;
    }
  }

  Future<void> _restoreWindow() async {
    try {
      await windowManager.show();
      await windowManager.focus();
      debugPrint('Окно восстановлено');
    } catch (e) {
      debugPrint('Ошибка восстановления окна: $e');
    }
  }

  Future<void> _forceExit() async {
    await _showGracefulShutdownDialog();
  }

  Future<void> notifyGenerationComplete(String title, String body) async {
    _hasPendingNotification = true;

    try {
      // Локальное уведомление
      final notification = LocalNotification(
        identifier: 'musication_complete',
        title: title,
        body: body,
      );

      await notification.show();

      // Обновляем tooltip иконки
      await trayManager.setToolTip('NovaSpec - ✅ Генерация завершена');

      debugPrint('Уведомление о завершении генерации отправлено');
    } catch (e) {
      debugPrint('Ошибка отправки уведомления: $e');
    }
  }

  Future<void> notifyGenerationFailed(String error) async {
    _hasPendingNotification = true;

    try {
      final notification = LocalNotification(
        identifier: 'musication_failed',
        title: 'Ошибка музикации',
        body: error,
      );

      await notification.show();

      // Обновляем tooltip иконки
      await trayManager.setToolTip('NovaSpec - ❌ Ошибка генерации');

      debugPrint('Уведомление об ошибке отправлено');
    } catch (e) {
      debugPrint('Ошибка отправки уведомления об ошибке: $e');
    }
  }

  Future<void> clearPendingNotification() async {
    _hasPendingNotification = false;
    await trayManager.setToolTip('NovaSpec - Музикация в фоне');
  }

  @override
  void onWindowClose() async {
    // Перехватываем закрытие окна
    final shouldExit = await _showGracefulShutdownDialog();

    if (!shouldExit) {
      // Отменяем закрытие окна
      await _hideToTray();
    } else {
      // Разрешаем закрытие
      windowManager.destroy();
    }
  }

  Future<void> _hideToTray() async {
    try {
      await windowManager.hide();
      debugPrint('Окно скрыто в трей');
    } catch (e) {
      debugPrint('Ошибка скрытия окна в трей: $e');
    }
  }

  Future<bool> _showGracefulShutdownDialog() async {
    // TODO: Показать диалог подтверждения
    // Это нужно реализовать в зависимости от текущего контекста
    return false;
  }

  void dispose() {
    windowManager.removeListener(this);
    trayManager.destroy();
    _isInitialized = false;
  }
}
