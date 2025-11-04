# Руководство разработчика: SwaggerServerService

**Версия:** 1.0  
**Дата обновления:** 2024  
**Статус:** Актуально

---

## 📋 Обзор

`SwaggerServerService` - это singleton сервис для запуска локального HTTP сервера, который обслуживает Swagger UI для просмотра OpenAPI спецификаций.

### Основные возможности:
- ✅ Автоматический поиск свободного порта (8080-8180)
- ✅ Подсчёт ссылок для безопасного управления жизненным циклом
- ✅ Переиспользование сервера для разных файлов
- ✅ Защита от утечек ресурсов
- ✅ Singleton паттерн с DI интеграцией

---

## 🎯 Использование в виджетах

### Базовый пример

```dart
import 'package:novaspec2/features/workspace/services/swagger_server_service.dart';

class MySwaggerWidget extends StatefulWidget {
  final String filePath;
  
  const MySwaggerWidget({super.key, required this.filePath});
  
  @override
  State<MySwaggerWidget> createState() => _MySwaggerWidgetState();
}

class _MySwaggerWidgetState extends State<MySwaggerWidget> {
  late final SwaggerServerService _swaggerService;
  String? _serverUrl;
  
  @override
  void initState() {
    super.initState();
    // Получаем singleton инстанс
    _swaggerService = SwaggerServerService();
    // ОБЯЗАТЕЛЬНО увеличиваем счётчик ссылок
    _swaggerService.addReference();
    _loadSwagger();
  }
  
  @override
  void dispose() {
    // ОБЯЗАТЕЛЬНО уменьшаем счётчик ссылок
    _swaggerService.removeReference();
    super.dispose();
  }
  
  Future<void> _loadSwagger() async {
    try {
      // Загружаем спецификацию и получаем URL сервера
      final url = await _swaggerService.loadOpenAPISpec(widget.filePath);
      setState(() {
        _serverUrl = url;
      });
    } catch (e) {
      print('Error loading Swagger: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Используем _serverUrl для загрузки в WebView
    return Container();
  }
}
```

---

## 🔄 Система подсчёта ссылок

### Как это работает

Сервер отслеживает количество активных виджетов через счётчик ссылок:

```dart
// При создании виджета
_swaggerService.addReference();  // referenceCount++

// При удалении виджета
_swaggerService.removeReference();  // referenceCount--
// Если referenceCount == 0, сервер автоматически останавливается
```

### ⚠️ ВАЖНО: Всегда используйте пару методов

```dart
// ✅ ПРАВИЛЬНО
@override
void initState() {
  super.initState();
  _swaggerService = SwaggerServerService();
  _swaggerService.addReference();  // <-- Обязательно!
}

@override
void dispose() {
  _swaggerService.removeReference();  // <-- Обязательно!
  super.dispose();
}

// ❌ НЕПРАВИЛЬНО
@override
void initState() {
  super.initState();
  _swaggerService = SwaggerServerService();
  // Забыли addReference() - утечка ресурсов!
}

@override
void dispose() {
  _swaggerService.stopServer();  // <-- НЕ делайте так! Убьёте сервер для всех!
  super.dispose();
}
```

---

## 🏗️ Использование через DI контейнер

### Рекомендуемый подход

```dart
import 'package:novaspec2/shared/services/di_container.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  SwaggerServerService? _swaggerService;
  
  @override
  void initState() {
    super.initState();
    // Получаем через DI
    _swaggerService = getIt<SwaggerServerService>();
    _swaggerService!.addReference();
  }
  
  @override
  void dispose() {
    _swaggerService?.removeReference();
    super.dispose();
  }
}
```

---

## 📊 API Reference

### Методы

#### `addReference()`
Увеличивает счётчик ссылок на сервер.

```dart
void addReference()
```

**Когда использовать:** В `initState()` виджета

---

#### `removeReference()`
Уменьшает счётчик ссылок. Если счётчик достигает 0, сервер автоматически останавливается.

```dart
Future<void> removeReference() async
```

**Когда использовать:** В `dispose()` виджета

---

#### `loadOpenAPISpec(String filePath)`
Загружает OpenAPI спецификацию и возвращает URL сервера.

```dart
Future<String> loadOpenAPISpec(String filePath) async
```

**Параметры:**
- `filePath` - полный путь к файлу спецификации (`.json` или `.yaml`)

**Возвращает:** URL сервера (например, `http://localhost:8080`)

**Throws:** `Exception` если файл не найден или сервер не запустился

**Пример:**
```dart
try {
  final url = await _swaggerService.loadOpenAPISpec('/path/to/swagger.json');
  print('Server URL: $url');
} catch (e) {
  print('Error: $e');
}
```

---

#### `stopServer()`
Останавливает сервер. Проверяет счётчик ссылок - если есть активные ссылки, сервер НЕ остановится.

```dart
Future<void> stopServer() async
```

**⚠️ ВНИМАНИЕ:** Обычно не нужно вызывать вручную! Используйте `removeReference()`.

---

#### `forceStopServer()`
Принудительно останавливает сервер, игнорируя счётчик ссылок.

```dart
Future<void> forceStopServer() async
```

**⚠️ ОПАСНО:** Используйте только в крайних случаях (например, при критической ошибке)!

---

### Геттеры

#### `serverUrl`
Текущий URL сервера или `null` если сервер не запущен.

```dart
String? get serverUrl
```

---

#### `isRunning`
Статус работы сервера.

```dart
bool get isRunning
```

---

#### `port`
Текущий порт сервера или `null`.

```dart
int? get port
```

---

#### `referenceCount`
Текущее количество активных ссылок.

```dart
int get referenceCount
```

**Пример использования для отладки:**
```dart
debugPrint('Active references: ${_swaggerService.referenceCount}');
```

---

## 🐛 Отладка и логирование

### Включение отладочных логов

Сервис автоматически выводит логи:

```
SwaggerServer reference count increased to 1
Swagger server started on http://localhost:8080
OpenAPI spec loaded successfully
SwaggerServer reference count decreased to 1
SwaggerServer reference count decreased to 0
No more references, stopping server...
Stopping Swagger server on port 8080...
Server stopped successfully
```

### Проверка состояния сервера

```dart
void checkServerState() {
  print('Server running: ${_swaggerService.isRunning}');
  print('Server URL: ${_swaggerService.serverUrl}');
  print('Server port: ${_swaggerService.port}');
  print('Reference count: ${_swaggerService.referenceCount}');
}
```

---

## ⚠️ Типичные ошибки и их решения

### 1. Ошибка: "Port already in use"

**Проблема:**
```
SocketException: Failed to create server socket (OS Error: address already in use)
```

**Причина:** Забыли вызвать `removeReference()` в `dispose()`

**Решение:**
```dart
@override
void dispose() {
  _swaggerService.removeReference();  // <-- Добавить эту строку
  super.dispose();
}
```

---

### 2. Ошибка: "Server stopped unexpectedly"

**Проблема:** Swagger UI перестал работать во всех вкладках

**Причина:** Кто-то вызвал `stopServer()` или `forceStopServer()` напрямую

**Решение:** Используйте только `addReference()` / `removeReference()`

---

### 3. Утечка памяти

**Проблема:** Память растёт при открытии/закрытии вкладок

**Причина:** Забыли вызвать `removeReference()` в `dispose()`

**Решение:** Всегда вызывайте `removeReference()` в паре с `addReference()`

---

## 🔒 Лучшие практики

### ✅ DO

1. **Всегда используйте reference counting:**
   ```dart
   _swaggerService.addReference();   // в initState()
   _swaggerService.removeReference(); // в dispose()
   ```

2. **Обрабатывайте ошибки:**
   ```dart
   try {
     final url = await _swaggerService.loadOpenAPISpec(filePath);
   } catch (e) {
     // Покажите ошибку пользователю
   }
   ```

3. **Используйте DI контейнер:**
   ```dart
   _swaggerService = getIt<SwaggerServerService>();
   ```

4. **Проверяйте disposed состояние:**
   ```dart
   if (!mounted) return;
   setState(() { ... });
   ```

### ❌ DON'T

1. **НЕ вызывайте stopServer() напрямую:**
   ```dart
   _swaggerService.stopServer();  // ❌ Плохо
   ```

2. **НЕ создавайте новые инстансы:**
   ```dart
   final service = SwaggerServerService._internal();  // ❌ Невозможно
   ```

3. **НЕ забывайте removeReference():**
   ```dart
   @override
   void dispose() {
     // _swaggerService.removeReference();  // ❌ Забыли - утечка!
     super.dispose();
   }
   ```

4. **НЕ игнорируйте ошибки:**
   ```dart
   await _swaggerService.loadOpenAPISpec(filePath);  // ❌ Без try-catch
   ```

---

## 📦 Интеграция с WebView

### Пример с webview_flutter

```dart
import 'package:webview_flutter/webview_flutter.dart';

class SwaggerWebView extends StatefulWidget {
  final String filePath;
  
  const SwaggerWebView({super.key, required this.filePath});
  
  @override
  State<SwaggerWebView> createState() => _SwaggerWebViewState();
}

class _SwaggerWebViewState extends State<SwaggerWebView> {
  late final SwaggerServerService _swaggerService;
  WebViewController? _webViewController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _swaggerService = SwaggerServerService();
    _swaggerService.addReference();
    _initWebView();
    _loadSwagger();
  }
  
  @override
  void dispose() {
    _swaggerService.removeReference();
    super.dispose();
  }
  
  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );
  }
  
  Future<void> _loadSwagger() async {
    try {
      final url = await _swaggerService.loadOpenAPISpec(widget.filePath);
      await _webViewController?.loadRequest(Uri.parse(url));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_webViewController == null) {
      return const Center(child: Text('Error loading WebView'));
    }
    
    return WebViewWidget(controller: _webViewController!);
  }
}
```

---

## 🧪 Тестирование

### Ручное тестирование

```dart
void testSwaggerServer() async {
  final service = SwaggerServerService();
  
  // Тест 1: Базовая загрузка
  service.addReference();
  final url1 = await service.loadOpenAPISpec('/path/to/spec1.json');
  print('Test 1 - URL: $url1, Running: ${service.isRunning}');
  
  // Тест 2: Множественные ссылки
  service.addReference();
  print('Test 2 - References: ${service.referenceCount}');
  
  // Тест 3: Остановка при одной ссылке
  await service.removeReference();
  print('Test 3 - Running after remove: ${service.isRunning}');
  
  // Тест 4: Полная остановка
  await service.removeReference();
  print('Test 4 - Running after final remove: ${service.isRunning}');
}
```

---

## 📚 Дополнительные ресурсы

- **Спецификация задачи:** `specs/013-webview2-swagger`
- **Ревью задачи:** `specs/013-webview2-swagger-review.md`
- **Чеклист тестирования:** `specs/013-testing-checklist.md`

---

## ❓ FAQ

### В: Можно ли использовать сервер для разных файлов одновременно?

О: Да, сервер автоматически перезагружает контент при вызове `loadOpenAPISpec()` с новым файлом. Все активные WebView увидят новый контент.

### В: Что произойдёт, если забыть вызвать removeReference()?

О: Сервер не остановится даже после закрытия всех вкладок, порт останется занятым. Это утечка ресурсов.

### В: Можно ли запустить несколько серверов на разных портах?

О: Нет, сервис реализован как singleton. Один экземпляр = один порт.

### В: Как проверить, свободен ли порт?

О: Сервис автоматически находит свободный порт в диапазоне 8080-8180.

---

**Версия документа:** 1.0  
**Последнее обновление:** После исправления критических багов  
**Автор:** NovaSpec2 Team