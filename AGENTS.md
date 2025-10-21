# NovaSpec Agent Context

## Project Overview
NovaSpec - Flutter/Dart версия приложения для создания технических заданий с ИИ-ассистентом.

## Technology Stack
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider/Bloc
- **HTTP Client**: dio
- **File Operations**: file_picker, dart:io
- **Storage**: SharedPreferences, flutter_secure_storage
- **UI Components**: Material Design 3
- **Localization**: flutter_localizations
 - **Monaco Editor**: monaco_editor
 - **WebView**: webview_flutter (Swagger UI)
- **Audio**: audioplayers
- **Markdown**: flutter_markdown
- **HTML**: flutter_html
- **SVG**: flutter_svg

## Architecture Principles
- MVVM pattern with Dependency Injection
- Feature-based project structure
- Manual testing only (no automated tests)
- Visual identity with TypeScript reference
- Russian and English localization support

## Key Dependencies
- dio: HTTP requests for all external integrations
- shared_preferences: App settings and configuration
- flutter_secure_storage: API tokens and sensitive data
- file_picker: File and directory selection
 - monaco_editor: Monaco Editor integration
 - webview_flutter: Swagger UI integration
- flutter_svg: SVG icon rendering
- flutter_localizations: Internationalization support
- audioplayers: Audio playback functionality
- flutter_markdown: Markdown rendering
- flutter_html: HTML rendering

## Project Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes/
│   └── themes/
├── core/
│   ├── constants/
│   ├── utils/
│   └── services/
├── shared/
│   ├── widgets/
│   └── models/
├── features/
│   ├── onboarding/
│   ├── project_management/
│   ├── settings/
│   ├── file_explorer/
│   ├── workspace/
│   ├── ai_assistant/
│   └── templates/
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_ru.dart
    └── app_localizations_en.dart
```

## Constitution Compliance
- UI identity with TypeScript reference (nova-spec-ide-studio-main)
- Flutter/Dart ecosystem usage only
- MVVM architecture with clear separation
- Localization support for Russian and English
- API integrations through dio only
- Manual testing only (no automated tests)

## Current Phase: Phase 1 - Analysis and Preparation
Focus on analyzing TypeScript project and setting up Flutter foundation.
