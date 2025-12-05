# Скрипт для освобождения портов Swagger сервера (8080-8180)
# Использование: .\kill-swagger-ports.ps1

Write-Host "=== Swagger Server Port Killer ===" -ForegroundColor Cyan
Write-Host "Поиск процессов, занимающих порты 8080-8180..." -ForegroundColor Yellow
Write-Host ""

$portsToCheck = 8080..8180
$processesFound = @{}

foreach ($port in $portsToCheck) {
    try {
        # Получаем список соединений на данном порту
        $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue

        if ($connections) {
            foreach ($conn in $connections) {
                $pid = $conn.OwningProcess

                if ($pid -and -not $processesFound.ContainsKey($pid)) {
                    try {
                        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
                        if ($process) {
                            $processesFound[$pid] = @{
                                Process = $process
                                Ports = @($port)
                            }
                        }
                    } catch {
                        # Процесс может завершиться между проверками
                    }
                } elseif ($pid -and $processesFound.ContainsKey($pid)) {
                    $processesFound[$pid].Ports += $port
                }
            }
        }
    } catch {
        # Порт не занят или нет доступа
    }
}

if ($processesFound.Count -eq 0) {
    Write-Host "✓ Порты 8080-8180 свободны!" -ForegroundColor Green
    Write-Host ""
    exit 0
}

# Показываем найденные процессы
Write-Host "Найдено процессов: $($processesFound.Count)" -ForegroundColor Yellow
Write-Host ""

foreach ($pid in $processesFound.Keys) {
    $info = $processesFound[$pid]
    $process = $info.Process
    $ports = $info.Ports -join ", "

    Write-Host "PID: $pid" -ForegroundColor White
    Write-Host "  Имя: $($process.ProcessName)" -ForegroundColor Gray
    Write-Host "  Порты: $ports" -ForegroundColor Gray
    Write-Host "  Путь: $($process.Path)" -ForegroundColor Gray
    Write-Host ""
}

# Спрашиваем подтверждение
$confirmation = Read-Host "Убить эти процессы? (Y/N)"

if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
    Write-Host ""
    Write-Host "Завершение процессов..." -ForegroundColor Yellow

    $killed = 0
    $failed = 0

    foreach ($pid in $processesFound.Keys) {
        try {
            Stop-Process -Id $pid -Force -ErrorAction Stop
            Write-Host "✓ Процесс $pid завершён" -ForegroundColor Green
            $killed++
        } catch {
            Write-Host "✗ Не удалось завершить процесс $pid`: $_" -ForegroundColor Red
            $failed++
        }
    }

    Write-Host ""
    Write-Host "Результат:" -ForegroundColor Cyan
    Write-Host "  Завершено: $killed" -ForegroundColor Green
    Write-Host "  Ошибок: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })

    # Даём время ОС освободить порты
    Write-Host ""
    Write-Host "Ожидание освобождения портов..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    # Проверяем, что порты освободились
    Write-Host "Проверка портов..." -ForegroundColor Yellow
    $stillBusy = @()

    foreach ($port in $portsToCheck) {
        try {
            $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
            if ($connections) {
                $stillBusy += $port
            }
        } catch {
            # Порт свободен
        }
    }

    if ($stillBusy.Count -eq 0) {
        Write-Host ""
        Write-Host "✓ Все порты успешно освобождены!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠ Некоторые порты всё ещё заняты: $($stillBusy -join ', ')" -ForegroundColor Yellow
        Write-Host "Попробуйте запустить скрипт ещё раз или перезагрузите компьютер." -ForegroundColor Gray
    }

} else {
    Write-Host ""
    Write-Host "Операция отменена." -ForegroundColor Gray
}

Write-Host ""
Write-Host "Готово!" -ForegroundColor Cyan
