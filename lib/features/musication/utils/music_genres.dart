import 'package:flutter/material.dart';

class MusicGenres {
  static const Map<String, String> _genreMap = {
    'pop': 'Поп',
    'russian rap': 'Русский рэп',
    'rock': 'Рок',
    'jazz': 'Джаз',
    'classic': 'Классика',
    'electric music': 'Электронная музыка',
    'hip-hop': 'Хип-хоп',
    'r&b': 'R&B',
  };

  static const Map<String, String> _reverseGenreMap = {
    'Поп': 'pop',
    'Русский рэп': 'russian rap',
    'Рок': 'rock',
    'Джаз': 'jazz',
    'Классика': 'classic',
    'Электронная музыка': 'electric music',
    'Хип-хоп': 'hip-hop',
    'R&B': 'r&b',
  };

  /// Получение списка всех жанров на русском языке
  static List<String> get allGenres => _genreMap.values.toList();

  /// Получение списка всех жанров на английском языке
  static List<String> get allGenreKeys => _genreMap.keys.toList();

  /// Получение русского названия жанра
  static String getDisplayName(String genre) {
    return _genreMap[genre.toLowerCase()] ?? genre;
  }

  /// Получение английского ключа жанра
  static String getGenreKey(String displayName) {
    return _reverseGenreMap[displayName] ?? displayName.toLowerCase();
  }

  /// Проверка поддержки жанра
  static bool isSupported(String genre) {
    return _genreMap.containsKey(genre.toLowerCase()) ||
        _reverseGenreMap.containsKey(genre);
  }

  /// Получение списка DropdownMenuItem для жанров
  static List<DropdownMenuItem<String>> getDropdownItems() {
    return allGenres.map((genre) {
      return DropdownMenuItem<String>(value: genre, child: Text(genre));
    }).toList();
  }

  /// Получение списка жанров для локализации
  static Map<String, String> getLocalizedGenres(String locale) {
    if (locale.startsWith('ru')) {
      return _reverseGenreMap;
    } else {
      return _genreMap;
    }
  }

  /// Получение иконки для жанра
  static IconData getGenreIcon(String genre) {
    switch (genre.toLowerCase()) {
      case 'pop':
      case 'поп':
        return Icons.music_note;
      case 'russian rap':
      case 'русский рэп':
      case 'hip-hop':
      case 'хип-хоп':
        return Icons.graphic_eq;
      case 'rock':
      case 'рок':
        return Icons.music_note;
      case 'jazz':
      case 'джаз':
        return Icons.piano;
      case 'classic':
      case 'классика':
        return Icons.queue_music;
      case 'electric music':
      case 'электронная музыка':
        return Icons.surround_sound;
      case 'r&b':
        return Icons.mic;
      default:
        return Icons.music_note;
    }
  }

  /// Получение цвета для жанра
  static Color getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'pop':
      case 'поп':
        return Colors.pink;
      case 'russian rap':
      case 'русский рэп':
      case 'hip-hop':
      case 'хип-хоп':
        return Colors.orange;
      case 'rock':
      case 'рок':
        return Colors.red;
      case 'jazz':
      case 'джаз':
        return Colors.blue;
      case 'classic':
      case 'классика':
        return Colors.purple;
      case 'electric music':
      case 'электронная музыка':
        return Colors.cyan;
      case 'r&b':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
