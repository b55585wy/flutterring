@echo off
REM OpenRing 日志拉取脚本 (Windows)
REM 使用方法: pull_logs.bat

echo ==========================================
echo OpenRing 日志拉取工具
echo ==========================================
echo.

REM 检查adb是否可用
where adb >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 adb 命令
    echo 请确保 Android SDK Platform Tools 已安装并在 PATH 中
    pause
    exit /b 1
)

REM 检查设备是否连接
adb devices | findstr "device$" >nul
if %errorlevel% neq 0 (
    echo 错误: 未检测到已连接的Android设备
    echo 请确保:
    echo   1. 设备已通过USB连接
    echo   2. 已启用USB调试
    echo   3. 已授权此电脑进行调试
    pause
    exit /b 1
)

echo [√] 设备已连接
echo.

REM 创建本地日志目录
set LOCAL_LOG_DIR=logs
if not exist "%LOCAL_LOG_DIR%" mkdir "%LOCAL_LOG_DIR%"

REM 设备上的日志目录
set DEVICE_LOG_DIR=/storage/emulated/0/Documents/OpenRingLogs

echo 正在检查设备上的日志文件...
echo 设备路径: %DEVICE_LOG_DIR%
echo.

REM 拉取所有日志文件
echo 正在拉取日志文件...
adb pull "%DEVICE_LOG_DIR%/ModelInference_*.txt" "%LOCAL_LOG_DIR%\" 2>nul

echo.
echo ==========================================
echo 日志文件已保存到: %LOCAL_LOG_DIR%\
echo ==========================================
echo.
echo 最新日志文件:
dir /O-D "%LOCAL_LOG_DIR%\*.txt" 2>nul | findstr /V "Directory"
echo.
pause

