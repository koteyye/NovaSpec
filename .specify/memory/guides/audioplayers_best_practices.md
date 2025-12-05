# Руководство по безопасной работе с audioplayers во Flutter

## Проблема с нативными потоками

AudioPlayer в Flutter использует нативные каналы связи (Platform Channels), которые работают в фоновых потоках. Это может вызвать крашы приложения с ошибкой:
```
[ERROR:flutter/shell/common/shell.cc(1064)] The 'xyz.luan/audioplayers/events/...' channel sent a message from native to Flutter on a non-platform thread.
```

## ✅ Правильные практики

### 1. Проверка типа файла БЕЗ создания AudioPlayer

**❌ НЕПРАВИЛЬНО:**
```dart
Future<bool> isAudioFile(String filePath) async {
  final player = AudioPlayer();
  try {
    await player.setSourceDeviceFile(filePath);
    final duration = await player.getDuration();
    return duration != null;
  } finally {
    await player.dispose();
  }
}
```

**✅ ПРАВИЛЬНО:**
```dart
bool isAudioFile(String filePath) {
  const supportedFormats = ['mp3', 'wav', 'm4a', 'aac', 'flac'];
  final extension = filePath.toLowerCase().split('.').last;
  return supportedFormats.contains(extension);
}
```

### 2. Порядок инициализации AudioPlayer

**❌ НЕПРАВИЛЬНО:**
```dart
void initPlayer() {
  _player = AudioPlayer();
  
  // Подписываемся на стримы ДО загрузки файла
  _player.onPositionChanged.listen((pos) => setState(...));
  
  // Загружаем файл
  _player.setSourceDeviceFile(filePath);
}
```

**✅ ПРАВИЛЬНО:**
```dart
Future<void> initPlayer() async {
  AudioPlayer? tempPlayer;
  
  try {
    // Создаём временный плеер
    tempPlayer = AudioPlayer();
    
    // Устанавливаем режим
    await tempPlayer.setReleaseMode(ReleaseMode.stop);
    
    // Загружаем файл
    await tempPlayer.setSourceDeviceFile(filePath);
    
    // Проверяем состояние виджета
    if (_disposed || !mounted) {
      await tempPlayer.dispose();
      return;
    }
    
    // Присваиваем плеер только после успешной загрузки
    _player = tempPlayer;
    
    // Подписываемся на стримы ПОСЛЕ загрузки
    _setupListeners();
    
  } catch (e) {
    // Очищаем временный плеер при ошибке
    if (tempPlayer != null && _player != tempPlayer) {
      await tempPlayer.dispose();
    }
  }
}
```

### 3. Правильная подписка на стримы

**✅ ОБЯЗАТЕЛЬНО:**
```dart
StreamSubscription<Duration>? _positionSubscription;
StreamSubscription<PlayerState>? _stateSubscription;

void _setupListeners() {
  // Отменяем старые подписки
  _positionSubscription?.cancel();
  _stateSubscription?.cancel();
  
  // Создаём новые с обработкой ошибок
  _positionSubscription = _player.onPositionChanged.listen(
    (position) {
      if (!_disposed && mounted) {
        setState(() => _position = position);
      }
    },
    onError: (error) {
      // Игнорируем ошибки нативного потока
    },
    cancelOnError: false,
  );
}
```

### 4. Правильная очистка ресурсов

**✅ ОБЯЗАТЕЛЬНО:**
```dart
bool _disposed = false;

@override
void dispose() {
  _disposed = true;
  
  // Отменяем все подписки
  _positionSubscription?.cancel();
  _stateSubscription?.cancel();
  _positionSubscription = null;
  _stateSubscription = null;
  
  // Останавливаем и удаляем плеер
  _player?.stop().catchError((_) {});
  _player?.dispose();
  _player = null;
  
  super.dispose();
}
```

### 5. Защита от обновления состояния после dispose

**✅ ОБЯЗАТЕЛЬНО в каждом колбэке:**
```dart
_player.onPositionChanged.listen((position) {
  // Всегда проверяем перед setState!
  if (!_disposed && mounted) {
    setState(() => _position = position);
  }
});
```

## 🚨 Типичные ошибки

### 1. Создание AudioPlayer для проверки файлов
- ❌ Создаёт нативные каналы даже для неподдерживаемых файлов
- ✅ Используй только проверку расширения

### 2. Ранняя подписка на стримы
- ❌ Подписка до загрузки файла → стримы начинают работать в нативном потоке
- ✅ Подписка ПОСЛЕ setSourceDeviceFile()

### 3. Отсутствие проверок в колбэках
- ❌ `setState()` без проверки `mounted` → краш
- ✅ Всегда `if (!_disposed && mounted) setState(...)`

### 4. Забытые подписки
- ❌ `listen()` без сохранения в переменную → утечка памяти
- ✅ Сохраняй `StreamSubscription` и отменяй в `dispose()`

### 5. Отсутствие обработки ошибок в стримах
- ❌ Краш при ошибке в нативном коде
- ✅ `onError: (_) {}` и `cancelOnError: false`

## 📋 Чеклист для каждого AudioPlayer

- [ ] Проверка типа файла ТОЛЬКО по расширению
- [ ] Создание временного плеера перед присвоением
- [ ] Установка `ReleaseMode.stop` перед загрузкой
- [ ] Загрузка файла через `setSourceDeviceFile()`
- [ ] Проверка `_disposed || !mounted` после загрузки
- [ ] Присвоение `_player = tempPlayer` только после успеха
- [ ] Подписка на стримы ПОСЛЕ присвоения
- [ ] Сохранение всех `StreamSubscription` в поля класса
- [ ] Проверка `!_disposed && mounted` в каждом колбэке стрима
- [ ] `onError: (_) {}` для каждого стрима
- [ ] `cancelOnError: false` для каждого стрима
- [ ] Отмена всех подписок в `dispose()`
- [ ] `stop().catchError((_) {})` перед `dispose()` плеера
- [ ] Очистка временного плеера при ошибках

## 🎯 Итоговый шаблон

```dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SafeAudioPlayer extends StatefulWidget {
  final String filePath;
  
  const SafeAudioPlayer({super.key, required this.filePath});
  
  @override
  State<SafeAudioPlayer> createState() => _SafeAudioPlayerState();
}

class _SafeAudioPlayerState extends State<SafeAudioPlayer> {
  AudioPlayer? _player;
  bool _disposed = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  
  @override
  void initState() {
    super.initState();
    _initPlayer();
  }
  
  @override
  void dispose() {
    _disposed = true;
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player?.stop().catchError((_) {});
    _player?.dispose();
    super.dispose();
  }
  
  Future<void> _initPlayer() async {
    AudioPlayer? temp;
    
    try {
      temp = AudioPlayer();
      await temp.setReleaseMode(ReleaseMode.stop);
      await temp.setSourceDeviceFile(widget.filePath);
      
      if (_disposed || !mounted) {
        await temp.dispose();
        return;
      }
      
      _player = temp;
      _setupListeners();
      
    } catch (e) {
      if (temp != null && _player != temp) {
        await temp.dispose();
      }
    }
  }
  
  void _setupListeners() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    
    _positionSub = _player?.onPositionChanged.listen(
      (pos) {
        if (!_disposed && mounted) {
          setState(() => _position = pos);
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
    
    _stateSub = _player?.onPlayerStateChanged.listen(
      (state) {
        if (!_disposed && mounted) {
          setState(() => _isPlaying = state == PlayerState.playing);
        }
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Ваш UI
    return Container();
  }
}
```

## 📚 Дополнительные ресурсы

- [Flutter Platform Channels Threading](https://docs.flutter.dev/platform-integration/platform-channels#channels-and-platform-threading)
- [audioplayers package](https://pub.dev/packages/audioplayers)
- [Dart Streams Best Practices](https://dart.dev/tutorials/language/streams)

## 🔄 История изменений

- 2024: Первая версия после фикса краша с нативными потоками