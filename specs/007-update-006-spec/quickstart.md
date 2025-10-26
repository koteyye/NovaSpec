# Quick Start: Обновление 006 - Корректировка Z.AI и редизайн Top Bar

**Date**: 2025-10-26  
**Feature**: Корректировка существующей Z.AI реализации и редизайн Top Bar

## Обзор изменений

Это обновление включает:
1. **Корректировка Z.AI реализации** (уже добавлен, но работает некорректно)
2. **Редизайн Top Bar** для соответствия TypeScript референсу
3. **Исправление ошибок валидации** и логики определения URL

## Быстрый старт для разработки

### 1. Подготовка окружения

Убедитесь, что у вас установлены:
- Flutter 3.x
- Dart 3.x
- Все зависимости из `pubspec.yaml`

### 2. Основные файлы для изменения

#### Z.AI Корректировка
```
lib/features/settings/widgets/settings_dialog_content.dart  # Исправить UI для Z.AI
lib/core/providers/settings_provider.dart                 # Исправить логику Z.AI
lib/core/services/ai_validation_service.dart              # Исправить эндпоинт валидации
```

#### Top Bar Редизайн
```
lib/features/topbar/widgets/top_bar.dart                # Обновить дизайн
```

#### Локализация
```
lib/l10n/app_localizations_ru.dart                      # Добавить новые ключи (если нужно)
lib/l10n/app_localizations_en.dart                      # Add new keys (if needed)
```

### 3. Ключевые изменения

#### Z.AI Корректировка

**Исправить в `settings_dialog_content.dart`:**
```dart
// Существующий код для Z.AI (нужно исправить)
if (widget.settingsProvider.isZAIProvider) ...[
  StyledDropdown<ZAIAccessType>(
    value: widget.settingsProvider.zaiAccessType,
    items: ZAIAccessType.values.map((type) {
      return DropdownMenuItem(
        value: type,
        child: Text(type.displayName),
      );
    }).toList(),
    onChanged: (type) {
      if (type != null) {
        widget.settingsProvider.setZaiAccessType(type);
      }
    },
  ),
  const SizedBox(height: 16),
  
  CustomTextField(
    labelText: 'API Key',
    hintText: 'zai-...',
    obscureText: true,
    controller: _tokenController,
    onChanged: (value) => widget.settingsProvider.setApiKey(value),
    suffixIcon: IconButton(
      icon: const Icon(Icons.check),
      onPressed: () => _testAIConnection(context),
    ),
  ),
],
```

#### Top Bar Обновление

**Обновить структуру в `top_bar.dart`:**
```dart
Row(
  children: [
    // Левая сторона - кнопки меню
    _buildFileMenu(context, localizations),
    const SizedBox(width: 8),
    _buildSettingsMenu(context, localizations),
    const SizedBox(width: 8),
    _buildAboutButton(context, localizations),
    
    const Spacer(),
    
    // Правая сторона - индикаторы
    _buildAIProviderIndicator(context, theme),
    const SizedBox(width: 8),
    _buildConfluenceIndicator(context, theme),
    const SizedBox(width: 8),
    _buildMusicIndicator(context, theme),
  ],
)
```

### 4. Валидация API

**Исправить эндпоинт в `ai_validation_service.dart` (строка ~480):**
```dart
// Текущий неверный код:
final url = '${baseUrl ?? 'https://api.z.ai'}/api/v1/user';

// Исправить на:
Future<ValidationResult> _validateZAI(String apiKey, String? baseUrl) async {
  if (apiKey.length < 10) {
    return ValidationResult.error('Неверный формат API ключа Z.AI');
  }

  try {
    // Используем правильный base URL из settings
    final effectiveUrl = baseUrl ?? 'https://api.z.ai/api/paas/v4';
    final url = '$effectiveUrl/models'; // Исправить с /user на /models
    
    final response = await _dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );

    if (response.statusCode == 200) {
      return ValidationResult.success('API ключ Z.AI действителен');
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      return ValidationResult.error('Неверный API ключ Z.AI');
    }
  }
  
  return ValidationResult.error('Ошибка проверки подключения Z.AI');
}
```

### 5. Тестирование

#### Ручное тестирование Z.AI:
1. Откройте Settings → Integrations
2. Выберите Z.AI провайдер
3. Выберите тип доступа (Coding Plan / API)
4. Введите API ключ
5. Нажмите "Проверка"
6. Убедитесь, что подключение работает

#### Ручное тестирование Top Bar:
1. Откройте приложение
2. Проверьте расположение кнопок (слева: Файл, Настройки, О программе)
3. Проверьте индикаторы (справа: Провайдер, Confluence, Музикация)
4. Проверьте выпадающие меню
5. Проверьте светофор на macOS

### 6. Локализация

**Добавить в `app_localizations_ru.dart`:**
```dart
String get zaiTitle => 'Z.AI';
String get zaiAccessToken => 'Тип доступа Z.AI';
String get zaiCodingPlan => 'Coding Plan';
String get zaiApi => 'API';
String get zaiApiKey => 'API Key';
String get zaiValidationSuccess => 'Подключение к Z.AI успешно';
String get zaiValidationError => 'Ошибка подключения к Z.AI';
```

### 7. Common Pitfalls

#### Ошибки в Z.AI:
- ❌ Использование старого эндпоинта `/api/v1/user` (в ai_validation_service.dart:480)
- ✅ Использовать `/models` с правильным base URL
- ❌ Неправильная логика определения base URL (в settings_provider.dart)
- ✅ Переиспользовать существующую AI конфигурацию с добавлением `zaiAccessType`
- ❌ Отсутствует UI для выбора типа доступа Z.AI
- ✅ Добавить поля в существующий UI настроек AI провайдера

#### Ошибки в Top Bar:
- ❌ Неправильное расположение элементов
- ✅ Кнопки слева, индикаторы справа
- ❌ Использование стандартных Flutter кнопок
- ✅ Использовать созданные компоненты

### 8. Следующие шаги

1. Реализовать изменения в коде
2. Протестировать функциональность
3. Проверить визуальное соответствие референсу
4. Убедиться, что все тексты локализованы
5. Провести финальное тестирование

### 9. Полезные ресурсы

- [TypeScript референс](../../../nova-spec-ide-studio-main/src/components/TopBar.tsx)
- [Z.AI API документация](contracts/zai-api.yaml)
- [Flutter Provider паттерн](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)

---

**Важно**: Все изменения должны соответствовать конституции проекта и использовать только созданные UI компоненты.