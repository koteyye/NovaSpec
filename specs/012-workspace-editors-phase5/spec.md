# Feature Specification: File Format Support and Viewers

**Feature Branch**: `012-workspace-editors-phase5`  
**Created**: 2025-11-01  
**Status**: Draft  
**Input**: User description: "Напиши спецификацию для выполнении фазы 5 в @implementation-plan.md подробные инструкции по представлены в @requirements.md"
**Scope**: Поддержка форматов файлов для просмотра и редактирования (без учета уже реализованного управления вкладками)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Markdown and HTML File Viewing and Editing (Priority: P1)

Пользователь может открывать файлы .md и .html в рабочей зоне, просматривать их в отрендеренном виде и переключаться в режим редактирования кода.

**Why this priority**: Основной функционал для работы с документацией, критически важен для продуктивности пользователя

**Independent Test**: Можно протестировать независимо, открывая .md/.html файлы и проверяя рендеринг и переключение режимов

**Acceptance Scenarios**:

1. **Given** пользователь кликает на .md файл в проводнике, **When** файл открывается, **Then** содержимое отображается в отрендеренном виде через flutter_markdown
2. **Given** пользователь кликает на .html файл в проводнике, **When** файл открывается, **Then** содержимое отображается в отрендеренном виде через flutter_html
3. **Given** открыт .md/.html файл в режиме просмотра, **When** пользователь переключается в режим редактирования, **Then** файл открывается в Monaco Editor через webview_flutter
4. **Given** пользователь редактирует .md/.html файл в Monaco Editor, **When** сохраняет изменения, **Then** изменения записываются в файл через File.writeAsString

---

### User Story 2 - Audio File Playback (Priority: P1)

Пользователь может открывать и воспроизводить аудиофайлы .mp3 и .wav через минималистичный аудиоплеер.

**Why this priority**: Важный функционал для работы с аудиоконтентом, необходим для полноценной поддержки форматов

**Independent Test**: Можно протестировать независимо, открывая .mp3/.wav файлы и проверяя воспроизведение

**Acceptance Scenarios**:

1. **Given** пользователь кликает на .mp3 файл в проводнике, **When** файл открывается, **Then** запускается минималистичный аудиоплеер
2. **Given** пользователь кликает на .wav файл в проводнике, **When** файл открывается, **Then** запускается минималистичный аудиоплеер
3. **Given** открыт аудиоплеер, **When** пользователь нажимает play/pause, **Then** воспроизведение управляется корректно
4. **Given** открыт аудиоплеер, **When** пользователь перемещает ползунок прогресса, **Then** позиция воспроизведения изменяется
5. **Given** открыт аудиоплеер, **When** воспроизведение завершается, **Then** ползунок возвращается в начало

---

### User Story 3 - YAML/JSON OpenAPI Documentation (Priority: P2)

Пользователь может открывать YAML и JSON файлы, которые соответствуют синтаксису OpenAPI, и просматривать их как интерактивную Swagger UI документацию.

**Why this priority**: Полезно для работы с API документацией, но менее критично чем базовые форматы

**Independent Test**: Можно протестировать независимо, открывая валидные OpenAPI файлы и проверяя Swagger UI

**Acceptance Scenarios**:

1. **Given** пользователь открывает YAML файл, **When** файл соответствует синтаксису OpenAPI, **Then** отображается Swagger UI через webview_flutter
2. **Given** пользователь открывает JSON файл, **When** файл соответствует синтаксису OpenAPI, **Then** отображается Swagger UI через webview_flutter
3. **Given** пользователь открывает YAML/JSON файл, **When** файл НЕ соответствует синтаксису OpenAPI, **Then** файл открывается в универсальном редакторе кода
4. **Given** открыта Swagger UI документация, **When** пользователь взаимодействует с интерфейсом, **Then** все функции Swagger UI работают корректно

---

### User Story 4 - Universal Code Editor (Priority: P2)

Пользователь может открывать любые другие форматы файлов в универсальном редакторе кода на базе Monaco Editor, редактировать их и сохранять изменения.

**Why this priority**: Обеспечивает поддержку всех остальных форматов файлов, расширяет функциональность

**Independent Test**: Можно протестировать независимо, открывая файлы различных форматов и проверяя редактирование

**Acceptance Scenarios**:

1. **Given** пользователь открывает файл неподдерживаемого формата, **When** файл открывается, **Then** он отображается в Monaco Editor
2. **Given** пользователь редактирует файл в Monaco Editor, **When** вносит изменения, **Then** изменения отображаются в редакторе
3. **Given** пользователь сохраняет изменения в Monaco Editor, **When** сохранение завершено, **Then** изменения записываются в файл через File.writeAsString
4. **Given** открыт файл в Monaco Editor, **When** пользователь переключается между вкладками, **Then** состояние каждой вкладки сохраняется

---

---

### Edge Cases

- [Уже учтены в проекте]

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST render .md files using flutter_markdown package
- **FR-002**: System MUST render .html files using flutter_html package  
- **FR-003**: System MUST provide code editing mode for .md/.html files using Monaco Editor
- **FR-004**: System MUST play .mp3 and .wav files using audioplayers package
- **FR-005**: System MUST provide minimal audio player with play/pause and seek controls
- **FR-006**: System MUST validate YAML/JSON files for OpenAPI syntax
- **FR-007**: System MUST display OpenAPI files as Swagger UI using webview_flutter
- **FR-008**: System MUST run background HTTP server using shelf package for Swagger UI
- **FR-009**: System MUST open unsupported file formats in Monaco Editor
- **FR-010**: System MUST save file changes using File.writeAsString
- **FR-011**: [Уже реализовано] System MUST manage multiple file tabs with TabBar component
- **FR-012**: [Уже реализовано] System MUST prevent duplicate tabs for the same file
- **FR-013**: [Уже реализовано] System MUST maintain file state across tab switches
- **FR-014**: System MUST display file icons based on file type using flutter_svg
- **FR-015**: System MUST handle file opening from file explorer clicks

### Flutter/Dart Specific Requirements

- **FR-016**: UI components MUST match TypeScript reference design exactly
- **FR-017**: All external integrations MUST use dio HTTP client
- **FR-018**: State management MUST follow Provider pattern with ChangeNotifier
- **FR-019**: All text elements MUST support flutter_localizations
- **FR-020**: File operations MUST use file_picker package
- **FR-021**: SVG icons MUST use flutter_svg package
- **FR-022**: WebView components MUST use webview_flutter package
- **FR-023**: Audio playback MUST use audioplayers package
- **FR-024**: Markdown rendering MUST use flutter_markdown package
- **FR-025**: HTML rendering MUST use flutter_html package
- **FR-026**: YAML parsing MUST use yaml package
- **FR-027**: Background server MUST use shelf package
- **FR-028**: UI components MUST use created components: ModernButton, ModernToast, CustomStyledDropdown
- **FR-029**: Standard Flutter buttons (ElevatedButton, TextButton) are PROHIBITED
- **FR-030**: DI MUST use get_it with singleton pattern for services
- **FR-031**: NO automated tests - all functionality MUST be validated manually by user
- **FR-032**: Unit tests, widget tests, integration tests are PROHIBITED

### Key Entities *(include if feature involves data)*

- **WorkspaceFile**: Представляет открытый файл с информацией о пути, типе, содержимом и состоянии редактирования
- **FileTab**: [Уже реализовано] Управляет состоянием вкладки файла, включая режим просмотра/редактирования и несохраненные изменения
- **AudioPlayerState**: Состояние аудиоплеера с информацией о воспроизведении, позиции и длительности
- **OpenAPISpec**: Представляет OpenAPI спецификацию с валидацией и метаданными
- **MonacoEditor**: Редактор кода с поддержкой различных языков и синтаксиса

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Пользователь может открывать и просматривать .md/.html файлы в отрендеренном виде менее чем за 1 секунду
- **SC-002**: Пользователь может переключаться между режимами просмотра и редактирования менее чем за 500мс
- **SC-003**: Аудиоплеер начинает воспроизведение .mp3/.wav файлов менее чем за 2 секунды после открытия
- **SC-004**: Swagger UI для OpenAPI файлов загружается и отображается менее чем за 3 секунды
- **SC-005**: [Уже реализовано] Пользователь может открывать до 10 файлов одновременно без снижения производительности интерфейса
- **SC-006**: 95% пользователей успешно работают с основными форматами файлов (.md, .html, .mp3, .wav) без ошибок
- **SC-007**: [Уже реализовано] Время переключения между вкладками не превышает 200мс для любого типа файла
- **SC-008**: Система корректно обрабатывает 99% файлов различных форматов без сбоев