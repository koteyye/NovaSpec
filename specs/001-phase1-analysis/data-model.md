# Модель данных: Фаза 1 - Анализ и подготовка

**Дата**: 2025-10-19  
**Цель**: Определение сущностей и структур для анализа и миграции

## Сущности анализа

### TypeScriptComponent

**Описание**: Компонент UI из TypeScript проекта для анализа миграции

**Поля**:
- `id`: String - Уникальный идентификатор компонента
- `name`: String - Название компонента
- `type`: ComponentType - Тип компонента (widget, dialog, screen, etc.)
- `filePath`: String - Путь к файлу компонента
- `dependencies`: List<String> - Зависимости компонента
- `props`: List<ComponentProp> - Свойства компонента
- `styling`: ComponentStyling - Стили компонента
- `stateManagement`: StateManagementType - Тип управления состоянием
- `complexity`: ComplexityLevel - Уровень сложности миграции

**ComponentType**:
- `WIDGET` - Базовый виджет
- `DIALOG` - Диалоговое окно
- `SCREEN` - Экран приложения
- `CONTAINER` - Контейнерный компонент
- `INPUT` - Поле ввода
- `BUTTON` - Кнопка

**ComplexityLevel**:
- `LOW` - Прямая замена на Flutter эквивалент
- `MEDIUM` - Требует адаптации логики
- `HIGH` - Сложная миграция с перепроектированием

### DesignSystem

**Описание**: Система дизайна из TypeScript проекта

**Поля**:
- `colors`: ColorPalette - Палитра цветов
- `typography`: TypographySystem - Система типографики
- `spacing`: SpacingSystem - Система отступов
- `shadows`: ShadowSystem - Система теней
- `animations`: AnimationSystem - Система анимаций
- `breakpoints`: BreakpointSystem - Адаптивные точки

### MigrationMapping

**Описание**: Сопоставление компонентов TypeScript с Flutter эквивалентами

**Поля**:
- `tsComponent`: TypeScriptComponent - Исходный компонент
- `flutterEquivalent`: FlutterEquivalent - Эквивалент Flutter
- `migrationNotes`: String - Заметки по миграции
- `customCodeRequired`: bool - Требуется ли кастомный код
- `testingApproach`: String - Подход к тестированию
- `estimatedEffort`: EffortEstimate - Оценка усилий

## Сущности конфигурации Flutter

### FlutterProjectConfig

**Описание**: Конфигурация Flutter проекта

**Поля**:
- `projectName`: String - Название проекта
- `packageName`: String - Имя пакета
- `flutterVersion`: String - Версия Flutter
- `dartVersion`: String - Версия Dart
- `platforms`: List<TargetPlatform> - Целевые платформы
- `dependencies`: List<Dependency> - Зависимости
- `devDependencies`: List<Dependency> - Зависимости разработки

### Dependency

**Описание**: Зависимость проекта

**Поля**:
- `name`: String - Название пакета
- `version`: String - Версия
- `type`: DependencyType - Тип зависимости
- `purpose`: String - Назначение

**DependencyType**:
- `RUNTIME` - Исполняемая зависимость
- `DEV` - Зависимость разработки
- `TEST` - Тестовая зависимость (ЗАПРЕЩЕНО)

### AssetConfig

**Описание**: Конфигурация ресурсов проекта

**Поля**:
- `svgIcons`: List<SVGIcon> - SVG иконки
- `images`: List<ImageAsset> - Изображения
- `fonts`: List<FontConfig> - Шрифты
- `localizationFiles`: List<LocalizationFile> - Файлы локализации

## Сущности документации

### MigrationDocument

**Описание**: Документация по миграции

**Поля**:
- `title`: String - Заголовок документа
- `sections`: List<DocumentSection> - Разделы документа
- `componentMappings`: List<MigrationMapping> - Сопоставления компонентов
- `architectureNotes`: String - Заметки по архитектуре
- `bestPractices`: List<String> - Лучшие практики
- `commonPitfalls`: List<String> - Распространенные проблемы

### DocumentSection

**Описание**: Раздел документации

**Поля**:
- `id`: String - Идентификатор раздела
- `title`: String - Заголовок
- `content`: String - Содержимое
- `codeExamples`: List<CodeExample> - Примеры кода
- `diagrams`: List<Diagram> - Диаграммы

## Валидация данных

### Правила валидации

1. **TypeScriptComponent**:
   - `name` не должен быть пустым
   - `filePath` должен существовать
   - `type` должен быть валидным ComponentType

2. **MigrationMapping**:
   - `tsComponent` и `flutterEquivalent` не должны быть null
   - `estimatedEffort` должен быть положительным

3. **FlutterProjectConfig**:
   - `projectName` должен соответствовать соглашениям Flutter
   - Все зависимости должны иметь валидные версии

4. **MigrationDocument**:
   - `title` не должен быть пустым
   - Должен содержать хотя бы один раздел

## Отношения между сущностями

```
TypeScriptComponent 1..* --> 1 MigrationMapping --> 0..1 FlutterEquivalent
DesignSystem 1 --> 1..* TypeScriptComponent
FlutterProjectConfig 1 --> 1..* Dependency
FlutterProjectConfig 1 --> 1 AssetConfig
MigrationDocument 1 --> 1..* DocumentSection
MigrationDocument 1 --> 1..* MigrationMapping
```

## Состояния и переходы

### Анализ компонента
1. `DISCOVERED` - Компонент обнаружен
2. `ANALYZING` - Выполняется анализ
3. `ANALYZED` - Анализ завершен
4. `MAPPED` - Создано сопоставление миграции
5. `DOCUMENTED` - Задокументирован

### Настройка проекта
1. `INITIALIZED` - Проект инициализирован
2. `DEPENDENCIES_CONFIGURED` - Зависимости настроены
3. `ASSETS_INTEGRATED` - Ресурсы интегрированы
4. `LOCALIZATION_SETUP` - Локализация настроена
5. `READY` - Проект готов к разработке