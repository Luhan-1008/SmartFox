param(
    [switch]$SkipFrontend,
    [switch]$SkipBackend
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$FrontendDir = Join-Path $RepoRoot 'frontend'
$BackendDir = Join-Path $RepoRoot 'backend'
$VenvDir = Join-Path $BackendDir '.venv'
$PythonExe = Join-Path $VenvDir 'Scripts\python.exe'
$PipExe = Join-Path $VenvDir 'Scripts\pip.exe'

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "未找到命令: $Name。请先安装后再运行脚本。"
    }
}

Write-Host '检查运行环境...'

if (-not $SkipFrontend) {
    Require-Command 'node'
    Require-Command 'npm'
}

if (-not (Get-Command 'python' -ErrorAction SilentlyContinue) -and -not (Get-Command 'py' -ErrorAction SilentlyContinue)) {
    throw '未找到 Python。请先安装 Python 3.11+。'
}

if (-not $SkipFrontend) {
    Write-Host '安装前端依赖...'
    Push-Location $FrontendDir
    try {
        if (Test-Path (Join-Path $FrontendDir 'package-lock.json')) {
            npm ci
        } else {
            npm install
        }
    }
    finally {
        Pop-Location
    }
}

if (-not $SkipBackend) {
    Write-Host '创建后端虚拟环境...'
    Push-Location $BackendDir
    try {
        if (-not (Test-Path $PythonExe)) {
            if (Get-Command 'py' -ErrorAction SilentlyContinue) {
                py -3 -m venv .venv
            } else {
                python -m venv .venv
            }
        }

        Write-Host '安装后端依赖...'
        & $PythonExe -m pip install --upgrade pip
        & $PipExe install -r requirements.txt
    }
    finally {
        Pop-Location
    }
}

Write-Host ''
Write-Host '初始化完成。'
Write-Host '启动项目请执行: .\scripts\run-dev.ps1'
