# Flutter 项目快速配置脚本
# 用法: 在 openring_flutter 目录下右键 "使用 PowerShell 运行"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "   Flutter 项目快速配置脚本" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 检测 Flutter
Write-Host "[1/4] 检查 Flutter 安装..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✓ Flutter 已安装: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter 未找到！请先安装 Flutter 并添加到 PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "参考: https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Cyan
    Write-Host "或查看: QUICK_START.md 的 '步骤 1: 配置 Flutter PATH'" -ForegroundColor Cyan
    pause
    exit 1
}

Write-Host ""

# 步骤 2: Flutter Doctor
Write-Host "[2/4] 运行 Flutter Doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# 步骤 3: 获取依赖
Write-Host "[3/4] 获取依赖 (flutter pub get)..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 依赖获取成功" -ForegroundColor Green
} else {
    Write-Host "✗ 依赖获取失败，请检查网络或 pubspec.yaml" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""

# 步骤 4: 生成 Freezed 代码
Write-Host "[4/4] 生成 Freezed 代码 (build_runner)..." -ForegroundColor Yellow
Write-Host "这可能需要 30 秒..." -ForegroundColor Gray
flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 代码生成成功" -ForegroundColor Green
} else {
    Write-Host "✗ 代码生成失败，请查看上方错误信息" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "   ✓ 配置完成！" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 5: 检查设备
Write-Host "检查可用设备..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# 提示
Write-Host "下一步操作:" -ForegroundColor Cyan
Write-Host "  1. 连接 Android 设备或启动模拟器" -ForegroundColor White
Write-Host "  2. 运行应用:" -ForegroundColor White
Write-Host "     flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "  或使用 Android Studio / VS Code 运行" -ForegroundColor White
Write-Host ""

pause

