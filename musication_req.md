# Требования к музикации
Функционал музикации в приложении реализуйется через сервис gen-api.ru
На текущий момент, в приложении реализован базовый коннект к gen-api.ru через экран настроек. У пользователя в конфиге уже есть API ключ для сервиса и есть необходимый базовый URL для доступа к API.

## Предворительные требования
Перед реализации непосредственно функционала музикации, необходимо сделать следующее:
### Выбор AI модели для генерации Lyrics
На текущий момент в приложении не реализован AI-ассистент, в котором пользователь может выбирать AI модель (а в целевом решении модель для генерации Lyrics используется та же самая, которую пользователь выбрал в AI-ассистенте).
Необходимо в текущую заглушку AI-ассистент добавить поле для выбора модель:
Поле располагается внутри заглушки, в обычном состоянии это кликабельный элемент "Выбрать модель", при нажатии на который открывается список доступных моделей.
В список попадают все модели, которые вернул метод /models в выбранном на данный момент AI провайдере в конфиге (конфигурция и настройка уже реализована).
Пример запроса:
У всех AI-провайдеров кроме antropic:
```dart
final response = await dio.post(
  '${baseURL}/openai/v1/models',
  options: Options(
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
  ),
  data: {
    'model': 'openai/gpt-oss-20b',
    'messages': [
      {'role': 'user', 'content': 'Explain the importance of low latency LLMs'}
    ]
  },
);
```

У antropic:
```dart
final response = await dio.post(
  '${baseURL}/v1/models',
  options: Options(
    headers: {
      'x-api-key': anthropicApiKey,
      'anthropic-version': '2023-06-01',
    },
  ),
  data: {
    'model': 'anthropic/claude-2',
    'messages': [
      {'role': 'user', 'content': 'Explain the importance of low latency LLMs'}
    ]
  },
);
```

Если в список попадает более 10 модель, то в раскрывающимся списке становится доступен скролл (видно 10 модель)
После клика по модели, она выбирается и сохраняется в конфигурации
Состояние поля: "Выбрать модель" теперь будет называться "{Выбранная модель}"

При клике по полю, можно выбрать другую модель.
При каждом клике выполняется запрос на получение списка моделей.
Поле расположить в нижней части виджета AI-ассистента.
Больше ничего по AI-ассиснтеу в рамках данной задаче делать не нужно.

### Настройка мока gen-api.ru
Для тестирования и дебага нужно сделать возможность переключаться на мок-сервис, который будет иметировать ответы на запросы.
Для переключения на мок-сервис, нужно в debug menu (оно уже реализовано, там сейчас можно показать онбординг, создать пустой проект или закрыть проект ) добавить чек-бокс "Мок gen-api.ru" и текстовое поле для указания URL мока (по умолчанию http://localhost:8080). По умолчанию мок-сервис не используется.
Если мок-сервис включен, то он доминирует над реальным сервисом, который указан в конфиге.

## Индикатор музикации

**СТАТУС:** ✅ **УЖЕ РЕАЛИЗОВАН** в `lib/features/topbar/widgets/top_bar.dart` (метод `_buildMusicStatus`, строки 367-430)

**Текущее состояние:**
- ✅ Иконка музыки (`Icons.music_note`)
- ✅ Отображение баланса: `${settingsProvider.musicBalance} ₽`
- ✅ Отображение жанра: `settingsProvider.getGenreDisplayName(musicGenre)`
- ✅ Иконка обновления (`Icons.refresh`) с `onTap: () => _refreshMusicBalance()`
- ❌ Метод `_refreshMusicBalance()` пустой (TODO)

**ЧТО НУЖНО ИСПРАВИТЬ:**

1. **Заменить хардкод баланса в SettingsProvider:**
```dart
// lib/core/providers/settings_provider.dart (строка 151)
// БЫЛО:
int get musicBalance => 150; // TODO: Implement actual balance fetching

// НУЖНО:
int get musicBalance => _musicBalance;
int _musicBalance = 0;
```

2. **Реализовать обновление баланса:**
```dart
// lib/features/topbar/widgets/top_bar.dart
void _refreshMusicBalance() async {
  try {
    final musicService = getIt<MusicGenerationService>();
    final result = await musicService.getBalance();
    
    if (result.isSuccess) {
      final balance = result.data ?? 0;
      final appProvider = context.read<AppProvider>();
      appProvider.updateMusicStatus(true, balance: balance);
      
      // Также обновить в SettingsProvider
      settingsProvider.updateMusicBalance(balance);
    } else {
      error(description: 'Ошибка получения баланса: ${result.error?.message}');
    }
  } catch (e) {
    error(description: 'Ошибка обновления баланса: $e');
  }
}
```

**Получение баланса gen-api.ru:**

Чтобы получить баланс, используется метод `/user`: 
Пример запроса:
```dart
final response = await dio.get(
  'https://api.gen-api.ru/api/v1/user',
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
      'User-Agent': 'NovaSpec/1.0',
    },
  ),
);
```
Пример ответа:
```json
{
  "name": "Kotey Ye",
  "email": "koteyye@gmail.com",
  "phone_number": null,
  "balance": 33,
  "email_verified_at": "2025-09-21T12:19:51.000000Z",
  "created_at": "2025-09-21T12:19:51.000000Z"
}
```
Баланс указан в поле "balance".

**Баланс в индикаторе обновляется:**
1. При проверке подключения в настройках (кнопка "Проверить" на экране настроек)
2. При сохранении настроек (кнопка "Сохранить" на экране настроек)
3. По клику на иконку "Обновить" в индикаторе музикации
4. После завершения цикла музикации (когда скачался сгенерированный файл)

**Интеграция обновления баланса:**
```dart
// После любого события обновления
final balance = await musicGenerationService.getBalance();
if (balance.isSuccess) {
  // Обновить AppProvider (для индикатора в топбаре)
  appProvider.updateMusicStatus(true, balance: balance.data);
  
  // Обновить SettingsProvider (для сохранения)
  settingsProvider.updateMusicBalance(balance.data);
  
  notifyListeners();
}
```

**Жанры музыки (найдено в коде):**

В `lib/core/providers/settings_provider.dart` (строки 86-108) уже реализованы маппинги жанров:
```dart
static const Map<String, String> genresRu = {
  'Поп': 'pop',
  'Русский рэп': 'russian rap',
  'Рок': 'rock',
  'Джаз': 'jazz',
  'Классика': 'classic',
  'Электронная музыка': 'electric music',
  'Хип-хоп': 'hip-hop',
  'R&B': 'r&b',
};

static const Map<String, String> genresEn = {
  'Pop Music': 'pop',
  'Russian rap': 'russian rap',
  'Rock': 'rock',
  'Jazz': 'jazz',
  'Classic': 'classic',
  'Electro music': 'electro music',
  'Hip-hop': 'hip-hop',
  'R&B': 'r&b',
};
```

Текущий жанр: `settingsProvider.musicGenre` (хранится как system name: 'pop', 'rock', и т.д.)

## Кнопка "Музикация"
Кликабельная-иконка "Музикация" находится в bar открытого файла (между контентом файла и вкладками), там же, где сейчас кликабельный иконки - Сохранить, Найти и заменить, Редактор
Иконку "Музикация" расположить следующей после "Редактор"
Кнопка отображается только для файлов с расширением .md и .html
Если не выбрана AI-модель в чате AI-ассистента, то кнопка задизейблена, а при наведении на нее отображается сообщение "Выберите AI-модель"

## Генерация Lyrics
После нажатия на кнопку "Музикация" выполняется 1-й этап музикации "Генерация Lyrics", на этом моменте выполняется запрос в подключенного на данный момент AI-провайдера и выбранную модель.
Пример запроса:
```curl
curl --location '${baseURL}/v1/chat/completions' \
--header 'Authorization: Bearer YOUR_API_KEY' \
--header 'Accept-Language: en-US,en' \
--header 'Content-Type: application/json' \
--data '{
    "model": "glm-4.6",
    "messages": [
        {
            "role": "user",
            "content": "Write a poem about spring"
        }
    ],
    "stream": true
}'
```
Нужно учесть особенности взаимодейсвтия с выбранным провайдером. Например у провайдера Z-AI есть дополнительно способ доступа к API, который указан в текущем конфиге. В зависимости от способа доступа меняется базовый baseURL
Если Coding Plan `https://api.z.ai/api/coding/paas/v4`
Если Pay-as-you-go `https://api.z.ai/api/paas/v4/`

Промт, который будет использоваться для генерации Lyrics:
```promt
Ты AI-ассистент в приложении SpecNova, и сейчас пользователь поставил тебе задачу сгенерировать Lyrics для песни, на основе ТЗ.
Песня должны быть в жанре ${Жанр из конфигурации}
Текст должен быть сделан в виде Lyrics пригодным для Suno
В ответе не указывай ничего лишнего, исключительно Lyrics
ТЗ, на основе которого нужно сгенерировать Lyrics: ${ТЗ из файла, в котором пользователь нажал кнопку музикация}
```

## Генерация песни через gen-api.ru
Выполняется запрос на генерацию песни через gen-api.ru:
Выполняется запрос на генерацию песни в Suno через gen-api.ru с использованием **dio**:

```dart
final response = await dio.post(
  'https://api.gen-api.ru/api/v1/networks/suno',
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  ),
  data: {
    'title': '${новый uuid}',
    'tags': genreFromConfig,
    'prompt': lyricsFromAI,
    'translate_input': false,
    'model': 'v5',
  },
);
```

Далее анализируем коды ответа:

##### 200 или 201

Запрос принят, получаем такое тело ответа:

```json
{
  "request_id": 28104643,
  "model": "suno",
  "status": "processing"
}
```

По данному телу ответа сохраняем временно request_id, он потребуется для отслеживания результата генерации

##### 402

Недостаточно средств на балансе gen-api

##### Остальные коды ошибок:

400	Запрос с таким request_id не найден
401	В запросе нет токена авторизации или токен неверный
404	Указана несуществующая нейросеть
503	Непредвиденная ошибка, обратитесь в службу поддержки
419	Слишком много запросов

***

## Опрашивание статуса генерации

Далее, когда у нас есть `request_id`, каждые 2 секунды через **Timer.periodic** вызывается метод проверки статуса:

### ❓ ВОПРОС 6: Таймаут опрашивания
**Нужно уточнить:**
- Максимальная длительность опрашивания? (рекомендую **5 минут**)
- Что делать при таймауте? (показать ошибку, сохранить состояние, retry?)
- Что делать при потере соединения во время опрашивания?

**Предлагаемые константы:**
```dart
const Duration POLLING_INTERVAL = Duration(seconds: 2);
const Duration MAX_POLLING_DURATION = Duration(minutes: 5);
const int MAX_POLLING_ATTEMPTS = 150; // 5 min / 2 sec = 150 попыток
```

**Реализация опрашивания:**

```dart
Timer? _pollingTimer;
int _pollingAttempts = 0;

void _startPolling(int requestId) {
  _pollingAttempts = 0;
  
  _pollingTimer = Timer.periodic(POLLING_INTERVAL, (timer) async {
    _pollingAttempts++;
    
    // Проверка таймаута
    if (_pollingAttempts >= MAX_POLLING_ATTEMPTS) {
      timer.cancel();
      _handleTimeout(requestId);
      return;
    }
    
    try {
      final response = await dio.get(
        'https://api.gen-api.ru/api/v1/request/get/$requestId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      final status = response.data['status'] as String;
      
      if (status == 'success') {
        timer.cancel();
        await _handleSuccess(response.data);
      } else if (status == 'failed') {
        timer.cancel();
        _handleError('Генерация не удалась');
      }
      // Если status == 'processing' - продолжаем опрашивание
      
    } on DioException catch (e) {
      // Обработка сетевых ошибок
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Продолжить попытки при временных проблемах с сетью
        return;
      }
      
      // При критических ошибках - остановить
      timer.cancel();
      _handleError('Ошибка сети: ${e.message}');
    }
  });
}

void _handleTimeout(int requestId) {
  // Сохранить состояние для продолжения при следующем запуске
  _saveState(requestId);
  error(description: 'Таймаут генерации. Попробуйте позже.');
}
```

**Статусы опрашивания:**
Следим за значением `"status"` в ответе.

Завершаем опрашивание когда получаем ответ со статусом `success`:

```json
{
  "id": 28104643,
  "status": "success",
  "response_type": "audio",
  "cost": 17,
  "progress": 100,
  "result": [
    "https://gen-api.storage.yandexcloud.net/input_files/1760102881_68e909e1ae303.mp3",
    "https://gen-api.storage.yandexcloud.net/input_files/1760102886_68e909e650cf9.mp3"
  ]
}
```

## Сохранение трека

В теле ответа, в массиве `result`, указаны ссылки на скачивание сгенерированных файлов (генерируется всегда 2).

### ❓ ВОПРОС 5: Сохранение MP3 файлов
- Сохранять **ОБА** файла автоматически?
- Или дать пользователю **выбрать один** из двух (показать превью/проиграть)?

**Предлагаемая реализация (сохранение обоих):**

```dart
// Скачивание через dio.download()
final projectPath = projectProvider.currentProject?.directory ?? '';
final urls = result['result'] as List<dynamic>;

for (int i = 0; i < urls.length; i++) {
  final url = urls[i] as String;
  final fileName = 'song_${uuid}_${i + 1}.mp3'; // ❓ Или другая конвенция именования?
  final savePath = path.join(projectPath, fileName);
  
  await dio.download(url, savePath);
}

// Обновление File Explorer
final fileExplorerProvider = context.read<FileExplorerProvider>();
fileExplorerProvider.refresh(); // Метод УЖЕ СУЩЕСТВУЕТ!
```

### ❓ ВОПРОС: Именование файлов
**Текущее предложение:** `song_{uuid}_{1|2}.mp3`

**Альтернативы:**
- `{timestamp}_song_{1|2}.mp3`
- `{projectName}_music_{uuid}_{1|2}.mp3`
- `music_{genre}_{timestamp}_{1|2}.mp3`

**Обновление проводника (найдено в коде):**
```dart
// lib/features/workspace/providers/file_explorer_provider.dart
Future<void> refresh() async {
  await loadDirectory(_currentDirectory);
}
```

После сохранения файлов вызываем:
```dart
fileExplorerProvider.refresh();
```

Пользователь сразу увидит новые MP3 файлы в File Explorer!

## Состояние музикации

**МЕСТОПОЛОЖЕНИЕ:** Нижний бар (StatusBar), слева от состояния "Доступен"/"Недоступен"

**Состояния генерации:**
- `generatingLyrics` → "Генерация Lyrics" (запрос к AI-модели)
- `generatingAudio` → "Генерация Audio" (запрос к gen-api.ru)
- `savingAudio` → "Сохранение Audio" (сохранение файлов)
- `completed` → "Музикация выполнена" (показывается 3 секунды, затем исчезает)
- `failed` → "Ошибка музикации: {errorMessage}"

**Модель состояния:**
```dart
enum MusicationStatus {
  idle,
  generatingLyrics,
  generatingAudio,
  savingAudio,
  completed,
  failed,
}

class MusicationState {
  final MusicationStatus status;
  final String? errorMessage;
  final int? requestId;
  final double progress; // 0.0 - 1.0
  
  String get displayText {
    switch (status) {
      case MusicationStatus.idle:
        return '';
      case MusicationStatus.generatingLyrics:
        return 'Генерация Lyrics';
      case MusicationStatus.generatingAudio:
        return 'Генерация Audio';
      case MusicationStatus.savingAudio:
        return 'Сохранение Audio';
      case MusicationStatus.completed:
        return 'Музикация выполнена';
      case MusicationStatus.failed:
        return 'Ошибка музикации: $errorMessage';
    }
  }
}
```

**Интеграция в StatusBar:**
```dart
// lib/features/workspace/widgets/status_bar.dart (или аналогичный)
Row(
  children: [
    if (musicationState.status != MusicationStatus.idle)
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            if (musicationState.status != MusicationStatus.completed &&
                musicationState.status != MusicationStatus.failed)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            const SizedBox(width: 8),
            Text(
              musicationState.displayText,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    // ... остальные элементы StatusBar
  ],
)
```

**Временное отображение:**
- Состояние "Музикация выполнена" показывается 3 секунды
- После этого статус возвращается в `idle`
- Состояние отображается ТОЛЬКО когда активен процесс музикации

#### Graceful shutdown музикации

**Сценарий:**
Пользователь закрывает приложение во время активной музикации.

**Поведение:**

1. **Показать AlertDialog:**
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => AlertDialog(
    title: Text(localizations.musication_close_dialog_title),
    content: Text(localizations.musication_close_dialog_message),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          // Отменить закрытие приложения
        },
        child: Text(localizations.musication_close_dialog_cancel),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          // Подтвердить закрытие
          _saveMusciationStateAndClose();
        },
        child: Text(localizations.musication_close_dialog_confirm),
      ),
    ],
  ),
);
```

2. **Сохранение состояния:**

### ❓ ВОПРОС 3: Путь к логу музикации
Где сохранять файл состояния?

**Предлагаемые варианты:**
- `{projectPath}/.novaspec/musication_state.json`
- `{appDocumentsDir}/NovaSpec/musication_state.json`
- SharedPreferences (не рекомендуется для больших данных)

**Структура лога:**
```json
{
  "request_id": 28104643,
  "project_path": "/home/user/my_project",
  "started_at": "2024-01-15T10:30:00.000Z",
  "status": "generatingAudio",
  "file_uuid": "550e8400-e29b-41d4-a716-446655440000",
  "genre": "pop",
  "lyrics": "Текст песни здесь...",
  "selected_text": "Исходное ТЗ..."
}
```

3. **Работа в фоне:**

### ❓ ВОПРОС 4: Фоновый режим на Desktop
- Нужна ли **системная иконка в трее** (tray_manager или system_tray пакет)?
- Или просто **скрытое окно** продолжает работу?
- Как уведомить пользователя о завершении, если окно закрыто?

**Предлагаемая реализация (с tray):**
```dart
// pubspec.yaml
dependencies:
  tray_manager: ^0.2.0

// Показать иконку в трее
await trayManager.setIcon('assets/icons/tray_icon.ico');
await trayManager.setToolTip('NovaSpec - музикация в процессе...');
```

4. **Восстановление при запуске:**

```dart
// lib/core/services/music_generation_service.dart
Future<void> initialize() async {
  await _checkForPendingGeneration(); // УЖЕ СУЩЕСТВУЕТ!
}

// Расширить метод:
Future<void> _checkForPendingGeneration() async {
  final logPath = path.join(projectPath, '.novaspec', 'musication_state.json');
  final logFile = File(logPath);
  
  if (await logFile.exists()) {
    try {
      final jsonString = await logFile.readAsString();
      final state = jsonDecode(jsonString);
      final requestId = state['request_id'] as int;
      
      // Продолжить опрашивание с этим request_id
      await _continuePolling(requestId, state);
      
      // Если успешно - удалить лог
      await logFile.delete();
    } catch (e) {
      // Если ошибка или файл удален - удалить лог
      await logFile.delete();
    }
  }
}
```

**Обработка результатов:**
- ✅ Успешно скачан файл → удалить лог
- ✅ API ответил 404 (файл удален) → удалить лог без файла
- ✅ Другие ошибки → сохранить в лог и показать при следующем запуске

## Обработка ошибок и граничные случаи

### ❓ ВОПРОС 7: Множественная музикация
**Нужно уточнить:**
- Можно ли запустить несколько процессов музикации одновременно?
- Или блокировать повторный запуск, пока текущий не завершен?

**Предлагаемая реализация (блокировка):**
```dart
bool _isGenerating = false;

Future<void> startMusication() async {
  if (_isGenerating) {
    warning(description: 'Музикация уже выполняется. Дождитесь завершения.');
    return;
  }
  
  _isGenerating = true;
  try {
    await _generateMusic();
  } finally {
    _isGenerating = false;
  }
}
```

### Обработка HTTP кодов ошибок

**Генерация (POST /api/v1/networks/suno):**
- `200` / `201` → Успешно, получен request_id
- `402` → Недостаточно средств на балансе gen-api
- `400` → Неверный запрос
- `401` → Неверный токен авторизации
- `404` → Указана несуществующая модель
- `503` → Ошибка сервиса
- `419` → Слишком много запросов

**Опрашивание (GET /api/v1/request/get/{id}):**
- `200` → Успешно, получен статус
- `400` → Запрос с таким request_id не найден
- `401` → Неверный токен

**Обработка в коде:**
```dart
try {
  final response = await dio.post(...);
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    // Успех
  }
} on DioException catch (e) {
  final statusCode = e.response?.statusCode;
  String errorMessage;
  
  switch (statusCode) {
    case 402:
      errorMessage = localizations.musication_error_insufficient_funds;
      break;
    case 400:
      errorMessage = localizations.musication_error_request_not_found;
      break;
    case 401:
      errorMessage = localizations.musication_error_unauthorized;
      break;
    case 404:
      errorMessage = localizations.musication_error_model_not_found;
      break;
    case 503:
      errorMessage = localizations.musication_error_service_error;
      break;
    case 419:
      errorMessage = localizations.musication_error_too_many_requests;
      break;
    default:
      errorMessage = 'Ошибка: ${e.message}';
  }
  
  error(description: errorMessage);
}
```

### Отмена музикации вручную

**Нужно ли позволять отменить процесс?**
Если да:
```dart
void cancelMusication() {
  _pollingTimer?.cancel();
  _pollingTimer = null;
  _isGenerating = false;
  _status = MusicationStatus.idle;
  notifyListeners();
  
  info(description: 'Музикация отменена');
}
```

---

## Локализация

**КРИТИЧЕСКИ ВАЖНО:** ❌ ЗАПРЕЩЕНО хардкодить текст в коде!

ВСЕ текстовые элементы ДОЛЖНЫ использовать `flutter_localizations` и находиться в файлах:
- `lib/l10n/app_localizations.arb` (английский)
- `lib/l10n/app_localizations_ru.arb` (русский)

**Список необходимых ключей локализации:**

```arb
{
  // Кнопка и tooltip
  "musication_button_tooltip": "Музикация",
  "@musication_button_tooltip": {
    "description": "Tooltip для кнопки музикации в toolbar"
  },
  
  // Статусы генерации
  "musication_status_generating_lyrics": "Генерация Lyrics",
  "musication_status_generating_audio": "Генерация Audio",
  "musication_status_saving_audio": "Сохранение Audio",
  "musication_status_completed": "Музикация выполнена",
  
  // Graceful shutdown dialog
  "musication_close_dialog_title": "Завершение музикации",
  "musication_close_dialog_message": "Музикация еще не завершена. Вы уверены, что хотите закрыть программу?",
  "musication_close_dialog_confirm": "Закрыть",
  "musication_close_dialog_cancel": "Отменить",
  
  // Ошибки
  "musication_error_no_api_key": "API ключ gen-api.ru не настроен",
  "musication_error_no_ai_model": "AI модель не выбрана",
  "musication_error_no_selection": "Выделите текст для генерации песни",
  "musication_error_insufficient_funds": "Недостаточно средств на балансе",
  "musication_error_request_not_found": "Запрос не найден",
  "musication_error_unauthorized": "Неверный токен авторизации",
  "musication_error_model_not_found": "Указанная модель не найдена",
  "musication_error_service_error": "Ошибка сервиса, обратитесь в поддержку",
  "musication_error_too_many_requests": "Слишком много запросов, попробуйте позже",
  "musication_error_timeout": "Таймаут генерации. Попробуйте позже",
  "musication_error_network": "Ошибка сети",
  
  // Успех
  "musication_success": "Музыка успешно сгенерирована",
  "musication_cancelled": "Музикация отменена"
}
```

**Использование в коде:**
```dart
final localizations = AppLocalizations.of(context)!;
Text(localizations.musication_status_generating_lyrics);
```

---

## Общие требования
- ✅ Для музикации **НЕ НУЖНО** использовать тосты (кроме Graceful shutdown)
- ✅ **НЕ ПРИДУМЫВАТЬ** новых кнопок, состояний, UI элементов, кроме указанных в ТЗ
- ✅ **ВСЯ ЛОКАЛИЗАЦИЯ** через `app_localizations.arb` файлы
- ✅ Использовать существующие компоненты (`ModernButton`, `ModernToast`)
- ✅ Следовать архитектуре проекта (Provider паттерн)
- ✅ Обрабатывать ВСЕ возможные ошибки с понятными сообщениями

---

## Резюме открытых вопросов

### ❓ ВОПРОС 1: Промпт для генерации Lyrics
- Хардкод в коде или настраиваемый в Settings?
- Куда вставлять selectedText?
- Что делать если текст не выделен?
- Язык промпта зависит от locale?

### ✅ РЕШЕНО: Путь к логу музикации

**Решение:** Сохранять в `{projectPath}/.novaspec/musication_state.json`

### ❓ ВОПРОС 4: Фоновый режим
- Нужна ли системная иконка в трее?
- Или просто скрытое окно?

### ❓ ВОПРОС 5: Сохранение MP3
- Сохранять оба файла или дать выбор?

### ❓ ВОПРОС 6: Таймаут опрашивания
- Максимальная длительность? (рекомендую 5 минут)
- Действия при таймауте?

### ❓ ВОПРОС 7: Множественная музикация
- Блокировать повторный запуск или разрешить параллельные?

### ❓ ВОПРОС 8: Иконка кнопки
- `Icons.music_note` или SVG?
- Если SVG - путь к файлу?

### ❓ ВОПРОС: Именование файлов
- Текущее: `song_{uuid}_{1|2}.mp3`
- Альтернативы?

---

# 📋 ДОПОЛНЕНИЕ: Найденная инфраструктура в кодовой базе

## Существующие компоненты (готовые к использованию):

### Провайдеры:
- ✅ **SettingsProvider** - `musicEnabled`, `musicToken`, `musicGenre` (баланс хардкод 150 ₽)
- ✅ **AppProvider** - `updateMusicStatus(bool, {int? balance, String? genre})`
- ✅ **FileExplorerProvider** - `refresh()` для обновления проводника

### Сервисы:
- ✅ **MusicGenerationService** - `getBalance()`, `generateMusicForFile()`, `initialize()`
- ✅ **MusicValidationService** - `validateApiKey()`, `getBalance()`, `generateMusic()`

### UI:
- ✅ **TopBar._buildMusicStatus()** - индикатор РЕАЛИЗОВАН, но `_refreshMusicBalance()` пуст
- ✅ **WorkArea._buildEditorToolbar()** - добавить кнопку музикации сюда
- ✅ **TextEditingController** во всех редакторах - `.selection` для выделенного текста

### Жанры (уже в коде):
```dart
genresRu: {'Поп': 'pop', 'Русский рэп': 'russian rap', 'Рок': 'rock', ...}
```

## Что нужно исправить:

1. **Баланс в SettingsProvider** - заменить хардкод на реальное значение
2. **TopBar._refreshMusicBalance()** - реализовать получение баланса
3. **Кнопка музикации** - добавить в WorkArea toolbar
4. **MusicationProvider** - создать новый для управления состоянием
5. **Локализация** - добавить все ключи в app_localizations.arb

## Интеграция (примеры кода):

**Получение выделенного текста:**
```dart
final selection = textController.selection;
if (selection.isValid && !selection.isCollapsed) {
  final selectedText = textController.text.substring(selection.start, selection.end);
}
```

**Обновление баланса:**
```dart
final balance = await musicGenerationService.getBalance();
appProvider.updateMusicStatus(true, balance: balance.data);
settingsProvider.updateMusicBalance(balance.data);
```

**Обновление File Explorer:**
```dart
fileExplorerProvider.refresh(); // Метод уже существует!
```

---

## 🌍 Требования к локализации

**❌ ЗАПРЕЩЕНО:** Хардкодить текст интерфейса в коде!

**✅ ОБЯЗАТЕЛЬНО:** Все тексты через `AppLocalizations.of(context)!`

**Файлы локализации:**
- `lib/l10n/app_localizations.arb` (английский, базовый)
- `lib/l10n/app_localizations_ru.arb` (русский)

**Необходимые ключи для добавления:**

```arb
{
  "musication_button_tooltip": "Музикация",
  "@musication_button_tooltip": {
    "description": "Tooltip для кнопки музикации"
  },
  
  "musication_status_generating_lyrics": "Генерация Lyrics",
  "musication_status_generating_audio": "Генерация Audio",
  "musication_status_saving_audio": "Сохранение Audio",
  "musication_status_completed": "Музикация выполнена",
  
  "musication_close_dialog_title": "Завершение музикации",
  "musication_close_dialog_message": "Музикация еще не завершена. Вы уверены, что хотите закрыть программу?",
  "musication_close_dialog_confirm": "Закрыть",
  "musication_close_dialog_cancel": "Отменить",
  
  "musication_error_no_api_key": "API ключ gen-api.ru не настроен",
  "musication_error_no_ai_model": "AI модель не выбрана",
  "musication_error_no_selection": "Выделите текст для генерации песни",
  "musication_error_insufficient_funds": "Недостаточно средств на балансе",
  "musication_error_request_not_found": "Запрос не найден",
  "musication_error_unauthorized": "Неверный токен авторизации",
  "musication_error_model_not_found": "Указанная модель не найдена",
  "musication_error_service_error": "Ошибка сервиса, обратитесь в поддержку",
  "musication_error_too_many_requests": "Слишком много запросов, попробуйте позже",
  "musication_error_timeout": "Таймаут генерации. Попробуйте позже",
  "musication_error_network": "Ошибка сети",
  
  "musication_success": "Музыка успешно сгенерирована",
  "musication_cancelled": "Музикация отменена"
}
```

**Пример использования:**
```dart
final l10n = AppLocalizations.of(context)!;

// В UI
Text(l10n.musication_status_generating_lyrics)

// В error handling
error(description: l10n.musication_error_insufficient_funds)
```

---

# ✅ ФИНАЛЬНЫЕ РЕШЕНИЯ ПО ОТКРЫТЫМ ВОПРОСАМ

## Все вопросы решены:

### 1. ✅ Промпт для генерации Lyrics
**РЕШЕНИЕ:** Промпт **хардкод в коде** (не настраиваемый)

```dart
const String LYRICS_PROMPT_TEMPLATE = '''
Ты AI-ассистент в приложении NovaSpec, и сейчас пользователь поставил тебе задачу сгенерировать текст песни (Lyrics) на основе технического задания.

Требования:
- Жанр: {genre}
- Формат: куплеты и припев
- Язык: русский
- Стиль: эмоциональный, цепляющий
- Длительность: 2-3 минуты (примерно 15-20 строк)

Техническое задание:
{selectedText}

Верни ТОЛЬКО текст песни без дополнительных комментариев, заголовков и объяснений.
''';
```

### 2. ✅ Путь к логу музикации
**РЕШЕНИЕ:** Сохранять в `{projectPath}/.novaspec/musication_state.json`

**Структура лога:**
```json
{
  "request_id": 28104643,
  "project_path": "G:\\test_project",
  "started_at": "2024-01-15T10:30:00.000Z",
  "status": "generatingAudio",
  "file_uuid": "550e8400-e29b-41d4-a716-446655440000",
  "genre": "pop",
  "lyrics": "Текст песни...",
  "selected_text": "Исходное ТЗ..."
}
```

### 3. ✅ Фоновый режим
**РЕШЕНИЕ:** Системная иконка в трее (Вариант B)

**Требования:**
- При закрытии окна с активной музикацией - полностью скрыть окно
- Показать иконку в системном трее
- По завершении генерации - показать уведомление
- Двойной клик по иконке - восстановить окно

**Зависимости:**
```yaml
# pubspec.yaml
dependencies:
  tray_manager: ^0.2.0
  window_manager: ^0.3.0
```

**Ассеты:**
```yaml
flutter:
  assets:
    - assets/icons/tray_icon.ico  # Для Windows
    - assets/icons/tray_icon.png  # Для Linux/macOS
```

**Реализация:**

```dart
// 1. Инициализация при запуске приложения
Future<void> _initializeTrayManager() async {
  await trayManager.setIcon(
    Platform.isWindows
        ? 'assets/icons/tray_icon.ico'
        : 'assets/icons/tray_icon.png',
  );
  
  // Контекстное меню для иконки в трее
  await trayManager.setContextMenu(
    Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Показать окно',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'Выход',
        ),
      ],
    ),
  );
}

// 2. Обработка закрытия окна
@override
void onWindowClose() async {
  final musicationProvider = getIt<MusicationProvider>();
  
  if (musicationProvider.isGenerating) {
    // Показать AlertDialog
    final shouldClose = await _showGracefulShutdownDialog();
    
    if (shouldClose) {
      // Сохранить состояние музикации
      await _saveMusicationState();
      
      // Скрыть окно и показать в трее
      await windowManager.hide();
      
      // Обновить tooltip трея
      await trayManager.setToolTip(
        'NovaSpec - музикация в процессе...',
      );
      
      // НЕ закрываем приложение - оно работает в фоне
      return;
    } else {
      // Отменить закрытие
      return;
    }
  }
  
  // Нет активной музикации - закрыть приложение
  await windowManager.destroy();
}

// 3. Обработка кликов по иконке в трее
class _TrayListener extends TrayListener {
  @override
  void onTrayIconMouseDown() {
    // Одиночный клик - ничего не делаем
  }

  @override
  void onTrayIconRightMouseDown() {
    // Правый клик - показать контекстное меню
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        _restoreWindow();
        break;
      case 'exit':
        _forceExit();
        break;
    }
  }
}

// 4. Восстановление окна из трея
Future<void> _restoreWindow() async {
  await windowManager.show();
  await windowManager.focus();
}

// 5. Уведомление при завершении генерации
Future<void> _notifyGenerationComplete() async {
  // Показать system notification
  await trayManager.setToolTip('NovaSpec - музикация завершена!');
  
  // Можно использовать local_notifier для полноценных уведомлений
  // await LocalNotifier.notify(
  //   title: 'NovaSpec',
  //   body: 'Музикация успешно завершена!',
  //   actions: [
  //     LocalNotificationAction(text: 'Открыть'),
  //   ],
  // );
  
  // Восстановить окно автоматически (опционально)
  await _restoreWindow();
}

// 6. Принудительный выход
Future<void> _forceExit() async {
  final musicationProvider = getIt<MusicationProvider>();
  
  if (musicationProvider.isGenerating) {
    // Сохранить состояние перед выходом
    await _saveMusicationState();
  }
  
  await windowManager.destroy();
}
```

**AlertDialog при закрытии:**
```dart
Future<bool> _showGracefulShutdownDialog() async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.musication_close_dialog_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.musication_close_dialog_message),
          const SizedBox(height: 16),
          Text(
            'Приложение продолжит работу в системном трее.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.musication_close_dialog_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.musication_close_dialog_confirm),
        ),
      ],
    ),
  );
  
  return result ?? false;
}
```

**Иконки для трея:**
- **Windows:** `tray_icon.ico` (размеры: 16x16, 32x32, 48x48)
- **Linux/macOS:** `tray_icon.png` (размер: 22x22 или 24x24)

**Цвет иконки:** Монохромная, адаптируется под светлую/темную тему системы

### 4. ✅ Сохранение MP3 файлов
**РЕШЕНИЕ:** Сохранять **ОБА** файла автоматически в **корень открытого проекта**

**Реализация:**
```dart
final projectPath = projectProvider.currentProject?.directory ?? '';
final uuid = const Uuid().v4();

for (int i = 0; i < urls.length; i++) {
  final url = urls[i] as String;
  final fileName = 'song_${uuid}_${i + 1}.mp3';
  final savePath = path.join(projectPath, fileName);
  
  await dio.download(url, savePath);
}

// Обновить File Explorer
fileExplorerProvider.refresh();
```

### 5. ✅ Таймаут опрашивания
**РЕШЕНИЕ:** 
- Максимальная длительность: **5 минут**
- При таймауте: **сохранить лог с request_id**
- Генерация - НЕ быстрый процесс, таймаут необходим

**Константы:**
```dart
const Duration POLLING_INTERVAL = Duration(seconds: 2);
const Duration MAX_POLLING_DURATION = Duration(minutes: 5);
const int MAX_POLLING_ATTEMPTS = 150; // 5 min / 2 sec
```

**Обработка таймаута:**
```dart
void _handleTimeout(int requestId) {
  // 1. Сохранить состояние
  _saveMusciationState(requestId);
  
  // 2. Показать уведомление
  info(description: 'Таймаут генерации. Состояние сохранено, продолжим при следующем запуске.');
  
  // 3. При следующем запуске - продолжить
  // В MusicGenerationService.initialize() уже есть _checkForPendingGeneration()
}
```

### 6. ✅ Множественная музикация
**РЕШЕНИЕ:** **ЗАПРЕЩЕНО** запускать новую, пока текущая не завершена

**Реализация:**
```dart
class MusicationProvider extends ChangeNotifier {
  bool _isGenerating = false;
  
  bool get isGenerating => _isGenerating;
  
  Future<void> startMusication() async {
    if (_isGenerating) {
      warning(description: 'Музикация уже выполняется. Дождитесь завершения текущей.');
      return;
    }
    
    _isGenerating = true;
    notifyListeners(); // Кнопка станет disabled
    
    try {
      await _generateMusic();
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}
```

**UI блокировка:**
```dart
// В кнопке музикации
Consumer<MusicationProvider>(
  builder: (context, musicationProvider, child) {
    final isEnabled = !musicationProvider.isGenerating && 
                      hasApiKey && 
                      selectedText.isNotEmpty;
    
    return IconButton(
      onPressed: isEnabled ? () => _startMusication() : null,
      // ...
    );
  },
)
```

### 7. ✅ Иконка кнопки музикации
**РЕШЕНИЕ:** Использовать **SVG иконку** из `assets/icons/music.svg`

**Реализация:**
```dart
import 'package:flutter_svg/flutter_svg.dart';

IconButton(
  icon: SvgPicture.asset(
    'assets/icons/music.svg',
    width: 16,
    height: 16,
    colorFilter: ColorFilter.mode(
      isEnabled 
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      BlendMode.srcIn,
    ),
  ),
  tooltip: l10n.musication_button_tooltip,
  onPressed: isEnabled ? () => _startMusication() : null,
)
```

**Не забыть:** Добавить иконку в `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/icons/music.svg
```

### 8. ✅ Именование файлов
**РЕШЕНИЕ:** `song_{uuid}_1.mp3` и `song_{uuid}_2.mp3`

**Пример:**
- `song_550e8400-e29b-41d4-a716-446655440000_1.mp3`
- `song_550e8400-e29b-41d4-a716-446655440000_2.mp3`

---

## 📊 Итоговая статистика:

- ✅ **Решено:** 8 из 8 вопросов **(100%)**
- 🚀 **Готовность к реализации:** **100%**

---

## 🎉 ТЗ ПОЛНОСТЬЮ ГОТОВО К РЕАЛИЗАЦИИ!

Все вопросы решены, все детали уточнены. Можно начинать разработку!

---

## 📦 Дополнительные зависимости для реализации

Для полной реализации музикации нужно добавить в `pubspec.yaml`:

```yaml
dependencies:
  # Уже есть в проекте:
  dio: ^5.7.0
  flutter_svg: ^2.0.9
  provider: ^6.1.2
  get_it: ^7.6.4
  uuid: ^4.0.0  # Для генерации UUID файлов
  
  # Нужно добавить:
  tray_manager: ^0.2.0      # Иконка в системном трее
  window_manager: ^0.3.0    # Управление окном
  local_notifier: ^0.1.5    # Уведомления (опционально)
```

**Минимальная версия SDK:**
```yaml
environment:
  sdk: ^3.8.1
```

---

## 🎨 Необходимые ассеты

Создать следующие файлы иконок:

### 1. Иконка кнопки музикации:
- **Путь:** `assets/icons/music.svg`
- **Размер:** 24x24 px
- **Формат:** SVG монохромный
- **Цвет:** Адаптивный (меняется в коде)

### 2. Иконка системного трея:
- **Windows:** `assets/icons/tray_icon.ico`
  - Размеры: 16x16, 32x32, 48x48 (multi-size .ico)
  - Монохромная для адаптации под светлую/темную тему
  
- **Linux/macOS:** `assets/icons/tray_icon.png`
  - Размер: 22x22 или 24x24 px
  - Прозрачный фон
  - Монохромная

**Обновить pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/icons/music.svg
    - assets/icons/tray_icon.ico
    - assets/icons/tray_icon.png
```

---

## 📋 Чек-лист перед началом реализации

### Архитектура:
- [ ] Создать `lib/features/musication/` директорию
- [ ] Создать `MusicationProvider` (ChangeNotifier)
- [ ] Создать модели (`MusicationState`, `MusicationStatus`)

### Интеграция с существующими компонентами:
- [ ] Обновить `SettingsProvider` - добавить `updateMusicBalance()`
- [ ] Реализовать `TopBar._refreshMusicBalance()`
- [ ] Добавить кнопку музикации в `WorkArea._buildEditorToolbar()`

### Локализация:
- [ ] Добавить все 22 ключа в `app_localizations.arb`
- [ ] Добавить переводы в `app_localizations_ru.arb`

### Иконки и ассеты:
- [ ] Создать `tray_icon.ico` (Windows)
- [ ] Создать `tray_icon.png` (Linux/macOS)
- [ ] Обновить `pubspec.yaml` assets

### Зависимости:
- [ ] Добавить `tray_manager: ^0.2.0`
- [ ] Добавить `window_manager: ^0.3.0`
- [ ] Добавить `uuid: ^4.0.0` (если нет)
- [ ] Запустить `flutter pub get`

### Ручное тестирование:
- [ ] Тест полного цикла музикации
- [ ] Тест graceful shutdown
- [ ] Тест восстановления из лога
- [ ] Тест работы иконки в трее
- [ ] Тест блокировки множественной генерации
- [ ] Тест обработки всех кодов ошибок
- [ ] Тест таймаута (5 минут)

---

## 🚀 Готово к разработке!

**Статус:** ТЗ на 100% готово  
**Все вопросы:** Решены  
**Архитектура:** Определена  
**Интеграция:** Спланирована  

Можно начинать реализацию! 💪
