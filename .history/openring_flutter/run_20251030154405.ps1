# Flutter 应用快速启动脚本
# 使用方法: 右键 "使用 PowerShell 运行" 或在命令行运行 .\run.ps1

$FlutterPath = "C:\Users\a1396\Devkit\flutter\bin\flutter.bat"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "   OpenRing Flutter 快速启动" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 切换到项目目录
Set-Location $ProjectRoot

# 检查设备
Write-Host "[1/3] 检查可用设备..." -ForegroundColor Yellow
& $FlutterPath devices
Write-Host ""

# 询问用户选择
Write-Host "可用选项:" -ForegroundColor Cyan
Write-Host "  [1] 启动 Android 模拟器并运行应用" -ForegroundColor White
Write-Host "  [2] 在已连接的 Android 设备上运行" -ForegroundColor White
Write-Host "  [3] 仅启动模拟器（不运行应用）" -ForegroundColor White
Write-Host "  [4] 退出" -ForegroundColor White
Write-Host ""

$choice = Read-Host "请选择 [1-4]"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "[2/3] 启动模拟器 (Medium_Phone_API_35)..." -ForegroundColor Yellow
        Start-Process -FilePath $FlutterPath -ArgumentList "emulators", "--launch", "Medium_Phone_API_35" -NoNewWindow
        
        Write-Host "等待模拟器启动 (30 秒)..." -ForegroundColor Gray
        Start-Sleep -Seconds 30
        
        Write-Host ""
        Write-Host "[3/3] 运行应用..." -ForegroundColor Yellow
        & $FlutterPath run
    }
    "2" {
        Write-Host ""
        Write-Host "[2/2] 在已连接设备上运行应用..." -ForegroundColor Yellow
        & $FlutterPath run
    }
    "3" {
        Write-Host ""
        Write-Host "启动模拟器..." -ForegroundColor Yellow
        & $FlutterPath emulators --launch Medium_Phone_API_35
        Write-Host ""
        Write-Host "模拟器启动命令已发送。" -ForegroundColor Green
        Write-Host "待模拟器完全启动后，运行以下命令启动应用:" -ForegroundColor Cyan
        Write-Host "  .\run.ps1" -ForegroundColor Gray
        Write-Host "或:" -ForegroundColor Cyan
        Write-Host "  C:\Users\a1396\Devkit\flutter\bin\flutter.bat run" -ForegroundColor Gray
    }
    "4" {
        Write-Host "退出。" -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "无效选择，退出。" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

if ($choice -ne "3") {
    Read-Host "按 Enter 键退出"
}

