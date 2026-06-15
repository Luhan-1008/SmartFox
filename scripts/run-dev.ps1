param(
    [switch]$UseMySQL,
    [string]$BackendHost = '127.0.0.1',
    [int]$BackendPort = 8000,
    [int]$FrontendPort = 5173
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$FrontendDir = Join-Path $RepoRoot 'frontend'
$BackendDir = Join-Path $RepoRoot 'backend'
$VenvDir = Join-Path $BackendDir '.venv'
$PythonExe = Join-Path $VenvDir 'Scripts\python.exe'

if (-not (Test-Path $PythonExe)) {
    throw '未找到后端虚拟环境。请先执行 .\scripts\setup.ps1'
}

if (-not (Get-Command 'npm' -ErrorAction SilentlyContinue)) {
    throw '未找到 npm。请先安装 Node.js 22+。'
}

$env:PYTHONUTF8 = '1'

Push-Location $BackendDir
try {
    if ($UseMySQL) {
        Remove-Item Env:DJANGO_SETTINGS_MODULE -ErrorAction SilentlyContinue
        Write-Host '后端将使用默认 MySQL 配置启动。'
    }
    else {
        $env:DJANGO_SETTINGS_MODULE = 'server.settings_test'
        Write-Host '后端将使用 SQLite 测试配置启动。'
    }

    Write-Host '执行数据库迁移...'
    & $PythonExe manage.py migrate

    Write-Host '启动 Django 后端窗口...'
    $backendCommand = if ($UseMySQL) {
        "Set-Location '$BackendDir'; & '$PythonExe' manage.py runserver ${BackendHost}:${BackendPort}"
    } else {
        "Set-Location '$BackendDir'; `$env:DJANGO_SETTINGS_MODULE='server.settings_test'; & '$PythonExe' manage.py runserver ${BackendHost}:${BackendPort}"
    }
    Start-Process powershell -ArgumentList '-NoExit', '-Command', $backendCommand | Out-Null
}
finally {
    Pop-Location
}

Push-Location $FrontendDir
try {
    Write-Host '启动 Vite 前端窗口...'
    $frontendCommand = "Set-Location '$FrontendDir'; npm run dev -- --host 0.0.0.0 --port $FrontendPort"
    Start-Process powershell -ArgumentList '-NoExit', '-Command', $frontendCommand | Out-Null
}
finally {
    Pop-Location
}

Write-Host ''
Write-Host '项目正在启动。'
Write-Host "前端地址: http://localhost:$FrontendPort"
Write-Host "后端地址: http://$BackendHost:$BackendPort"
Write-Host '默认推荐先用 SQLite 模式；如果你本地 MySQL 已配置好，可加 -UseMySQL 参数。'
