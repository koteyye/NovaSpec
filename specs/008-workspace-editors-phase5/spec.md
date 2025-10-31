# Feature Specification: Workspace and Editors Phase 5.1

**Feature Branch**: `008-workspace-editors-phase5`  
**Created**: 2025-10-26  
**Status**: Draft  
**Input**: User description: "Implementation of workspace area with file explorer, work screen with tabs, and AI chat placeholder"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - File Explorer Integration (Priority: P1)

Пользователь может видеть файловую структуру открытого проекта в левой панели рабочего пространства

**Why this priority**: Критически важный компонент для навигации по проекту и доступа к файлам

**Independent Test**: Может быть полностью протестировано открытием проекта и проверкой отображения файловой структуры в левой панели

**Acceptance Scenarios**:

1. **Given** Пользователь открыл проект, **When** Рабочее пространство загружено, **Then** Левая панель показывает файловую структуру проекта
2. **Given** Файловая структура отображена, **When** Пользователь кликает на файл, **Then** Файл открывается в рабочей области
3. **Given** Файловая структура отображена, **When** Пользователь раскрывает папку, **Then** Показывается содержимое папки

---

### User Story 2 - Work Screen with Tab System (Priority: P1)

Пользователь может работать с несколькими файлами одновременно в центральной панели с системой вкладок

**Why this priority**: Основная рабочая область приложения - критически важна для функциональности

**Independent Test**: Может быть полностью протестировано открытием нескольких файлов и проверкой работы вкладок

**Acceptance Scenarios**:

1. **Given** Открыт один файл, **When** Пользователь открывает второй файл, **Then** Создается вторая вкладка
2. **Given** Открыто несколько вкладок, **When** Пользователь кликает на вкладку, **Then** Показывается содержимое соответствующего файла
3. **Given** Открыто несколько вкладок, **When** Пользователь закрывает вкладку, **Then** Вкладка удаляется и показывается следующая активная
4. **Given** Открыт markdown файл, **When** Файл отображается в рабочей области, **Then** Контент рендерится как markdown

---

### User Story 3 - AI Chat Placeholder (Priority: P2)

Пользователь видит правую панель с заглушкой AI чата, которую можно свернуть для расширения рабочей области

**Why this priority**: Важный компонент для будущего функционала и текущей компоновки интерфейса

**Independent Test**: Может быть полностью протестировано проверкой отображения и сворачивания панели

**Acceptance Scenarios**:

1. **Given** Рабочее пространство загружено, **When** Пользователь смотрит на правую панель, **Then** Отображается заглушка "Coming soon"
2. **Given** Правая панель отображена, **When** Пользователь нажимает кнопку сворачивания, **Then** Панель сворачивается и рабочая область расширяется
3. **Given** Панель свернута, **When** Пользователь нажимает кнопку развертывания, **Then** Панель снова отображается

---

### User Story 4 - File Type Support (Priority: P3)

Пользователь может работать с различными типами файлов: markdown/HTML рендер, аудио (.mp3, .wav), Swagger (JSON/YAML OpenAPI), и редактор кода

**Why this priority**: Расширяет функциональность рабочей области для разных типов контента

**Independent Test**: Может быть полностью протестировано открытием файлов разных типов и проверкой их корректного отображения

**Acceptance Scenarios**:

1. **Given** Открыт .md файл, **When** Файл отображается, **Then** Контент рендерится как markdown с использованием flutter_markdown
2. **Given** Открыт .html файл, **When** Файл отображается, **Then** Контент рендерится как HTML с использованием flutter_html
3. **Given** Открыт .mp3/.wav файл, **When** Файл отображается, **Then** Показывается аудиоплеер с использованием audioplayers
4. **Given** Открыт OpenAPI JSON/YAML файл, **When** Файл отображается, **Then** Показывается Swagger UI через webview_flutter
5. **Given** Открыт текстовый файл, **When** Файл отображается, **Then** Показывается Monaco Editor через monaco_editor пакет
6. **Given** Открыт неизвестный/нетекстовый файл, **When** Файл отображается, **Then** Показывается заглушка "Неподдерживаемый формат файла"

### User Story 5 - File Management Operations (Priority: P2)

Пользователь может управлять файлами в проекте через контекстное меню и панель инструментов

**Why this priority**: Базовые операции управления файлами необходимы для полноценной работы с проектом

**Independent Test**: Может быть полностью протестировано выполнением операций управления файлами

**Acceptance Scenarios**:

1. **Given** Файл выбран в проводнике, **When** Пользователь кликает правой кнопкой, **Then** Открывается контекстное меню с операциями
2. **Given** Контекстное меню открыто, **When** Пользователь выбирает "Удалить", **Then** Файл удаляется из проекта
3. **Given** Контекстное меню открыто, **When** Пользователь выбирает "Копировать", **Then** Путь файла копируется в буфер обмена
4. **Given** Контекстное меню открыто, **When** Пользователь выбирает "Переименовать", **Then** Имя файла становится редактируемым полем
5. **Given** Проводник в фокусе, **When** Пользователь кликает правой кнопкой на пустом месте, **Then** Открывается меню с "Новый файл"/"Новая папка"

### User Story 6 - File Editing and Saving (Priority: P2)

Пользователь может редактировать файлы и сохранять изменения с возможностью переключения между режимами просмотра

**Why this priority**: Необходимо для полноценной работы с контентом проекта

**Independent Test**: Может быть полностью протестировано редактированием и сохранением различных типов файлов

**Acceptance Scenarios**:

1. **Given** Открыт markdown/html файл в режиме рендера, **When** Пользователь нажимает кнопку редактирования, **Then** Файл открывается в Monaco Editor
2. **Given** Открыт любой файл, **When** Пользователь нажимает кнопку сохранения, **Then** Изменения сохраняются в файл
3. **Given** Открыт markdown/html файл, **When** Пользователь нажимает "Копировать в буфер обмена", **Then** Копируется отрендеренный контент со стилями
4. **Given** Файл переименовывается, **When** Пользователь нажимает Enter, **Then** Новое имя сохраняется
5. **Given** Файл переименовывается, **When** Пользователь кликает мышью или нажимает другую клавишу, **Then** Переименование отменяется

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

- При открытии больших файлов (>10MB) показывается лоадер на момент прогрузки
- Если формат файла текстовый, он открывается в Monaco Editor, если нетекстовый или неизвестный - показывается заглушка "Неподдерживаемый формат файла"
- Минимально допустимый размер окна рабочего пространства должен быть определен
- При закрытии последней вкладки остается пустой рабочий экран с заглушкой "Откройте файл для просмотра"
- Ошибки Monaco Editor обрабатываются через ModernToast с fallback на текстовый режим
- При минимальных размерах окна панели AI чата и проводник автоматически сворачиваются

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST отображать трехпанельную компоновку рабочего пространства (файловый проводник, рабочая область, AI чат)
- **FR-002**: System MUST поддерживать изменение размеров панелей с горизонтальным разделителем
- **FR-003**: System MUST поддерживать скрытие файлового проводника по аналогии с AI-ассистентом
- **FR-004**: Users MUST be able to открывать файлы из файлового проводника в рабочей области
- **FR-005**: System MUST поддерживать систему вкладок для нескольких открытых файлов
- **FR-006**: System MUST рендерить markdown файлы с использованием flutter_markdown
- **FR-007**: System MUST рендерить HTML файлы с использованием flutter_html
- **FR-008**: System MUST воспроизводить аудиофайлы (.mp3, .wav) через audioplayers
- **FR-009**: System MUST отображать Swagger UI для OpenAPI JSON/YAML через webview_flutter
- **FR-010**: System MUST предоставлять Monaco Editor для текстовых файлов через monaco_editor
- **FR-011**: System MUST отображать заглушку "Неподдерживаемый формат файла" для нетекстовых файлов
- **FR-012**: System MUST отображать заглушку AI чата с возможностью сворачивания
- **FR-013**: System MUST сохранять состояние открытых вкладок между сессиями через SharedPreferences с JSON сериализацией
- **FR-014**: System MUST показывать лоадер при загрузке больших файлов
- **FR-015**: System MUST предоставлять контекстное меню для операций с файлами
- **FR-016**: System MUST поддерживать переименование файлов с редактируемым полем
- **FR-017**: System MUST поддерживать создание новых файлов и папок через контекстное меню
- **FR-018**: System MUST поддерживать переключение между режимами рендера и редактирования для markdown/html
- **FR-019**: System MUST предоставлять кнопку сохранения для любого открытого файла с прямой перезаписью без конфликтов
- **FR-020**: System MUST копировать отрендеренный контент (со стилями) для markdown/html файлов

### Flutter/Dart Specific Requirements

- **FR-006**: UI components MUST match TypeScript reference design exactly
- **FR-007**: All external integrations MUST use dio HTTP client
- **FR-008**: State management MUST follow Provider pattern with ChangeNotifier
- **FR-009**: All text elements MUST support flutter_localizations
- **FR-010**: File operations MUST use file_picker package
- **FR-011**: SVG icons MUST use flutter_svg package
- **FR-012**: WebView components MUST use webview_flutter package
- **FR-013**: UI components MUST use created components: ModernButton, ModernToast, CustomStyledDropdown
- **FR-014**: Standard Flutter buttons (ElevatedButton, TextButton) are PROHIBITED
- **FR-015**: DI MUST use get_it with singleton pattern for services
- **FR-016**: NO automated tests - all functionality MUST be validated manually by user
- **FR-017**: Unit tests, widget tests, integration tests are PROHIBITED

### UI/UX Requirements

- **FR-018**: UI components MUST точно соответствовать TypeScript референсу (nova-spec-ide-studio-main)
- **FR-019**: Цвет фона и границ рабочего пространства должны быть идентичны референсу (точные HEX/RGB значения)
- **FR-020**: Все иконки и текст должны быть окрашены строго в цвета референса с идентичной контрастностью
- **FR-021**: Высота панелей и отступы должны совпадать с референсом в px без лишнего пространства
- **FR-022**: Размер и стиль шрифтов должны соответствовать референсу (font-size, font-family, font-weight)
- **FR-023**: Межбуквенные и межстрочные интервалы должны быть идентичны эталону
- **FR-024**: Все элементы должны быть выровнены по вертикали и горизонтали как на референсе
- **FR-025**: Использовать те же иконки (SVG), что и на референсе — строго по размеру и цвету
- **FR-026**: Размеры кликабельных областей иконок и кнопок должны совпадать с референсом
- **FR-027**: Реализовать hover-эффекты и индикаторы активного состояния как на референсе
- **FR-028**: Поведение при изменении ширины окна должно соответствовать референсу без смещения элементов
- **FR-029**: Минимальная ширина рабочего пространства должна соответствовать референсу
- **FR-030**: System MUST определять минимально допустимый размер окна приложения (1200px ширина, 800px высота)
- **FR-031**: System MUST показывать заглушку "Откройте файл для просмотра" при отсутствии открытых вкладок

*Example of marking unclear requirements:*

- **FR-013**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-014**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities

- **WorkspaceTab**: Представляет открытую вкладку с файлом, содержит путь к файлу, тип контента, состояние, режим (рендер/редактирование)
- **FileExplorerNode**: Представляет узел в файловой структуре, содержит имя, путь, тип (файл/папка), дочерние элементы, состояние переименования
- **WorkspacePanel**: Представляет панель рабочего пространства, содержит тип, размер, состояние (свернута/развернута)
- **OpenFile**: Представляет открытый файл, содержит метаданные, контент, тип рендерера, флаг изменений
- **ContextMenuAction**: Представляет действие контекстного меню, содержит тип, иконку, заголовок, обработчик
- **FileOperation**: Представляет операцию с файлом, содержит тип (создание/удаление/переименование/копирование), параметры

## Clarifications

### Session 2025-10-26
- Q: Обработка конфликтов при одновременном редактировании → A: Разрешение перезаписи без предупреждений
- Q: Минимальные размеры окна приложения → A: 1200px ширина, 800px высота
- Q: Механизм сохранения состояния между сессиями → B: SharedPreferences с JSON сериализацией
- Q: Обработка ошибок Monaco Editor → C: Показать ModernToast с ошибкой и fallback на текстовый режим
- Q: Поведение панелей при минимальных размерах окна → A: Автоматически сворачивать AI чат и проводник

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: Пользователи могут открывать и переключаться между файлами менее чем за 1 секунду
- **SC-002**: Система поддерживает открытие до 20 вкладок одновременно без снижения производительности
- **SC-003**: 95% пользователей успешно могут найти и открыть любой файл в проекте с первой попытки
- **SC-004**: Время рендеринга markdown файлов до 100KB не превышает 2 секунд
- **SC-005**: Изменение размеров панелей работает плавно без лагов на устройствах с 4GB RAM

