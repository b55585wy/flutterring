# Flutter 一键安装脚本
# 使用方法：在 PowerShell 中执行 ./install_flutter.ps1

param(
    [string]$InstallPath = "C:\flutter",
    [switch]$SkipDownload = $false
)

$ErrorActionPreference = "Stop"

Write-Host "=== Flutter 安装脚本 ===" -ForegroundColor Cyan
Write-Host "安装路径: $InstallPath" -ForegroundColor Yellow
Write-Host ""

# 检查是否已安装
if (Test-Path "$InstallPath\bin\flutter.bat") {
    Write-Host "检测到 Flutter 已安装在 $InstallPath" -ForegroundColor Yellow
    $response = Read-Host "是否重新安装？(y/n)"
    if ($response -ne 'y') {
        Write-Host "取消安装" -ForegroundColor Red
        exit 0
    }
}

try {
    # 1. 下载 Flutter SDK
    if (-not $SkipDownload) {
        Write-Host "[1/5] 正在下载 Flutter SDK 3.24.5..." -ForegroundColor Yellow
        $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
        $zipFile = "$env:TEMP\flutter_windows_3.24.5-stable.zip"
        
        if (Test-Path $zipFile) {
            Write-Host "  → 使用已下载的文件: $zipFile" -ForegroundColor Green
        } else {
            Write-Host "  → 下载地址: $url" -ForegroundColor Gray
            Write-Host "  → 文件大小: ~250 MB，请耐心等待..." -ForegroundColor Gray
            
            Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
            Write-Host "  ✓ 下载完成" -ForegroundColor Green
        }
    } else {
        $zipFile = "$env:TEMP\flutter_windows_3.24.5-stable.zip"
        if (-not (Test-Path $zipFile)) {
            Write-Host "错误: 未找到 Flutter SDK 压缩包: $zipFile" -ForegroundColor Red
            exit 1
        }
    }
    
    # 2. 清理旧安装
    if (Test-Path $InstallPath) {
        Write-Host "[2/5] 清理旧安装..." -ForegroundColor Yellow
        Remove-Item -Path $InstallPath -Recurse -Force
        Write-Host "  ✓ 已清理" -ForegroundColor Green
    } else {
        Write-Host "[2/5] 跳过清理（无旧安装）" -ForegroundColor Gray
    }
    
    # 3. 解压 Flutter SDK
    Write-Host "[3/5] 正在解压 Flutter SDK..." -ForegroundColor Yellow
    $extractPath = Split-Path -Parent $InstallPath
    Expand-Archive -Path $zipFile -DestinationPath $extractPath -Force
    Write-Host "  ✓ 解压完成: $InstallPath" -ForegroundColor Green
    
    # 4. 验证文件
    Write-Host "[4/5] 验证安装文件..." -ForegroundColor Yellow
    if (-not (Test-Path "$InstallPath\bin\flutter.bat")) {
        Write-Host "  ✗ 错误: flutter.bat 未找到" -ForegroundColor Red
        exit 1
    }
    Write-Host "  ✓ 文件验证通过" -ForegroundColor Green
    
    # 5. 配置环境变量
    Write-Host "[5/5] 配置环境变量..." -ForegroundColor Yellow
    
    $flutterBinPath = "$InstallPath\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    # 检查是否已存在
    if ($currentPath -like "*$flutterBinPath*") {
        Write-Host "  → PATH 已包含 Flutter，跳过添加" -ForegroundColor Gray
    } else {
        # 添加到用户 PATH
        $newPath = $currentPath + ";$flutterBinPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "  ✓ 已添加到用户 PATH: $flutterBinPath" -ForegroundColor Green
    }
    
    # 添加到当前会话
    $env:Path += ";$flutterBinPath"
    
    Write-Host ""
    Write-Host "=== 安装完成！===" -ForegroundColor Green
    Write-Host ""
    
    # 6. 验证安装
    Write-Host "正在验证 Flutter 安装..." -ForegroundColor Cyan
    & "$InstallPath\bin\flutter.bat" --version
    
    Write-Host ""
    Write-Host "后续步骤:" -ForegroundColor Cyan
    Write-Host "  1. 重启终端（或 PowerShell）" -ForegroundColor White
    Write-Host "  2. 运行: flutter doctor" -ForegroundColor White
    Write-Host "  3. 根据提示安装缺少的依赖" -ForegroundColor White
    Write-Host ""
    Write-Host "创建项目:" -ForegroundColor Cyan
    Write-Host "  cd $PWD" -ForegroundColor White
    Write-Host "  flutter create --org com.tsinghua openring_flutter" -ForegroundColor White
    
} catch {
    Write-Host ""
    Write-Host "=== 安装失败 ===" -ForegroundColor Red
    Write-Host "错误信息: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "请尝试手动安装:" -ForegroundColor Yellow
    Write-Host "  1. 访问: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "  2. 下载 Flutter SDK ZIP 文件" -ForegroundColor White
    Write-Host "  3. 解压到 C:\flutter\" -ForegroundColor White
    Write-Host "  4. 将 C:\flutter\bin 添加到 PATH" -ForegroundColor White
    exit 1
}

