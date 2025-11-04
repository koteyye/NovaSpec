# Устранение проблем с портами Swagger сервера

**Быстрая справка для разработчиков NovaSpec2**

---

## 🚨 Симптомы проблемы

### Ошибка в логах:
```
SocketException: Failed to create server socket (OS Error: address already in use)
```
или
```
Exception: Failed to initialize Swagger server: SocketException: Failed to create 
server socket (OS Error: The shared flag to bind() needs to be `true` if binding 
multiple times on the same (address, port) combination.), address = localhost, port = 8080
```

### В браузере:
- Белый экран при открытии Swagger файла
- Сообщение "OpenAPI spec not loaded" на localhost:8080

---

## ⚡ Быстрое решение

### Вариант 1: PowerShell скрипт (Рекомендуется)

```powershell
# Из корня проекта
.\scripts\kill-swagger-ports.ps1
```

Скрипт автоматически найдёт и предложит завершить процессы, занимающие порты 8080-8180.

### Вариант 2: Вручную через PowerShell

```powershell
# 1. Найти процесс, занимающий порт
Get-NetTCPConnection -LocalPort 8080 | Select-Object OwningProcess

# 2. Завершить процесс (замените PID на реальный)
Stop-Process -Id <PID> -Force

# 3. Проверить, что порт освободился
Get-NetTCPConnection -LocalPort 8080
```

### Вариант 3: Через командную строку

```cmd
# 1. Найти процесс
netstat -ano | findstr :8080

# 2. Завершить процесс (замените PID на реальный)
taskkill /PID <PID> /F

# 3. Проверить
netstat -ano | findstr :8080
```

---

## 🔍 Диагностика

### Проверка состояния сервера в коде

```dart
final swaggerService = SwaggerServerService();
swaggerService.printDebugInfo();
```

Выведет:
```
=== SWAGGER SERVER DEBUG INFO ===
Server running: true
Server URL: http://localhost:8080
Port: 8080
Reference count: 2
Current spec path: /path/to/swagger.json
Has HTML content: true
Server instance exists: true
=================================
```

### Ключевые показатели:

- **Reference count** - должен соответствовать количеству открытых вкладок со Swagger
- **Server running** - должен быть `true` если файл открыт
- **Has HTML content** - должен быть `true` после загрузки файла

---

## 🛠️ Частые причины проблем

### 1. Приложение не закрылось корректно
**Симптом:** Порт занят при запуске приложения

**Решение:** Используйте скрипт `kill-swagger-ports.ps1`

### 2. Забыли вызвать removeReference()
**Симптом:** Reference count растёт, сервер не останавливается

**Проверка:**
```dart
// В dispose() ОБЯЗАТЕЛЬНО должно быть:
@override
void dispose() {
  _swaggerService.removeReference(); // <-- Это обязательно!
  super.dispose();
}
```

### 3. Несколько экземпляров приложения
**Симптом:** Конфликт портов между разными запусками

**Решение:** Закройте все экземпляры Flutter приложения и очистите порты

### 4. Debug режим с Hot Restart
**Симптом:** После hot restart порты остаются занятыми

**Решение:** 
- Используйте Hot Reload (R) вместо Hot Restart (Shift+R)
- Или полностью перезапустите приложение
- Или очистите порты скриптом

---

## 📋 Чеклист при дебаге

- [ ] Закрыты ли все другие экземпляры приложения?
- [ ] Проверили ли занятые порты через `netstat`?
- [ ] Вызывается ли `removeReference()` в `dispose()`?
- [ ] Совпадает ли reference count с количеством открытых вкладок?
- [ ] Есть ли в логах сообщение "Swagger server started on..."?
- [ ] Есть ли в логах ошибки при bind порта?

---

## 🔧 Продвинутые решения

### Изменить диапазон портов

По умолчанию сервер ищет свободный порт в диапазоне 8080-8180. Если нужно изменить:

```dart
// В swagger_server_service.dart, метод initializeBackgroundServer()
for (int port = 9000; port <= 9100; port++) {  // Изменить диапазон
  try {
    createdServer = await HttpServer.bind('localhost', port, shared: false);
    // ...
  }
}
```

### Принудительная остановка сервера

```dart
// ОПАСНО: Использовать только в крайнем случае!
final swaggerService = SwaggerServerService();
await swaggerService.forceStopServer();
```

**⚠️ Внимание:** Это убьёт сервер для всех открытых вкладок!

### Отладка сетевых соединений

```powershell
# Показать все соединения на портах 8080-8180
8080..8180 | ForEach-Object {
    $connections = Get-NetTCPConnection -LocalPort $_ -ErrorAction SilentlyContinue
    if ($connections) {
        Write-Host "Port $_ is BUSY" -ForegroundColor Red
        $connections | Format-Table LocalPort, State, OwningProcess
    }
}
```

---

## 📞 Если ничего не помогло

1. **Перезагрузите компьютер** - самый надёжный способ освободить все порты
2. **Проверьте firewall** - возможно блокирует локальные соединения
3. **Проверьте антивирус** - может блокировать создание HTTP сервера
4. **Проверьте Windows Defender** - может блокировать порты

### Логи для репорта проблемы

Соберите следующую информацию:

```powershell
# Системная информация
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"

# Занятые порты
netstat -ano | findstr :808

# Процессы Dart/Flutter
Get-Process | Where-Object {$_.ProcessName -like "*dart*" -or $_.ProcessName -like "*flutter*"}

# Вывод printDebugInfo()
# (скопировать из консоли приложения)
```

---

## 🎓 Полезные ссылки

- **Документация сервиса:** `docs/swagger-server-guide.md`
- **Ревью задачи:** `specs/013-webview2-swagger-review.md`
- **Чеклист тестирования:** `specs/013-testing-checklist.md`
- **Скрипт очистки:** `scripts/kill-swagger-ports.ps1`

---

**Версия:** 1.0  
**Последнее обновление:** После финальных исправлений  
**Автор:** NovaSpec2 Team