# Flutter 安装与环境配置指南

## 问题诊断

你的系统上 Flutter 虽然安装了（在 `C:\Users\a1396\AppData\Local\Programs\Common\flutter`），但：
- ❌ Flutter 目录为空或未正确安装
- ❌ 未添加到系统 PATH
- ❌ 命令行无法识别 `flutter` 命令

---

## 解决方案（二选一）

### 方案 A：使用 Flutter SDK 压缩包（推荐，快速）

#### 步骤 1: 下载 Flutter SDK
```powershell
# 在 PowerShell 中执行（以管理员身份运行）

# 1. 创建安装目录
New-Item -ItemType Directory -Force -Path "C:\flutter"

# 2. 下载 Flutter SDK（Windows 版）
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
$output = "$env:USERPROFILE\Downloads\flutter_windows_3.24.5-stable.zip"

Invoke-WebRequest -Uri $url -OutFile $output

# 3. 解压到 C:\flutter
Expand-Archive -Path $output -DestinationPath "C:\" -Force

Write-Host "Flutter SDK 已解压到 C:\flutter" -ForegroundColor Green
```

#### 步骤 2: 添加到系统 PATH
```powershell
# 临时添加到当前会话（立即生效）
$env:Path += ";C:\flutter\bin"

# 永久添加到用户 PATH（需要重启终端）
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\flutter\bin",
    "User"
)

Write-Host "Flutter 已添加到 PATH，请重启终端" -ForegroundColor Green
```

#### 步骤 3: 验证安装
```powershell
# 重启 PowerShell 后执行
flutter --version
flutter doctor
```

---

### 方案 B：使用 Scoop 包管理器（自动化）

```powershell
# 1. 安装 Scoop（如果未安装）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# 2. 安装 Flutter
scoop install flutter

# 3. 验证
flutter --version
```

---

## 快速验证

安装完成后，在新的 PowerShell 窗口中运行：

```powershell
# 检查 Flutter 版本
flutter --version

# 运行健康检查
flutter doctor -v

# 预期输出类似：
# Flutter 3.24.5 • channel stable
# Framework • revision abc123...
# Engine • revision def456...
# Tools • Dart 3.5.4 • DevTools 2.37.3
```

---

## 常见问题

### 问题 1: `flutter` 命令仍然无法识别

**解决方案**:
```powershell
# 检查 PATH
$env:Path -split ';' | Select-String 'flutter'

# 如果没有输出，手动添加：
$env:Path += ";C:\flutter\bin"

# 验证
flutter --version
```

### 问题 2: `flutter doctor` 报错缺少 Android SDK

**解决方案**:
```powershell
# Flutter 会自动下载 Android SDK，或者手动安装 Android Studio
# 下载地址：https://developer.android.com/studio
```

### 问题 3: 权限不足

**解决方案**:
```powershell
# 以管理员身份运行 PowerShell
Start-Process powershell -Verb RunAs
```

---

## 下一步：创建 Flutter 项目

安装完成后，继续执行：

```powershell
# 1. 切换到项目目录
cd C:\Users\a1396\Documents\GitHub\androidring

# 2. 创建 Flutter 项目
flutter create --org com.tsinghua openring_flutter

# 3. 进入项目
cd openring_flutter

# 4. 验证项目
flutter run -d windows  # 或 flutter run 连接 Android 设备
```

---

## 一键安装脚本

保存以下内容为 `install_flutter.ps1`，右键"以管理员身份运行"：

```powershell
# install_flutter.ps1
# Flutter 一键安装脚本

Write-Host "=== Flutter 安装脚本 ===" -ForegroundColor Cyan

# 1. 下载 Flutter SDK
Write-Host "正在下载 Flutter SDK..." -ForegroundColor Yellow
$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
$output = "$env:USERPROFILE\Downloads\flutter_windows_3.24.5-stable.zip"
Invoke-WebRequest -Uri $url -OutFile $output

# 2. 解压
Write-Host "正在解压..." -ForegroundColor Yellow
Expand-Archive -Path $output -DestinationPath "C:\" -Force

# 3. 添加到 PATH
Write-Host "正在配置环境变量..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\flutter\bin",
    "User"
)

# 4. 刷新当前会话
$env:Path += ";C:\flutter\bin"

# 5. 验证
Write-Host "正在验证安装..." -ForegroundColor Yellow
& "C:\flutter\bin\flutter.bat" --version

Write-Host ""
Write-Host "=== 安装完成！===" -ForegroundColor Green
Write-Host "请重启终端，然后运行: flutter doctor" -ForegroundColor Cyan
```

---

## 手动安装步骤（图形界面）

如果命令行方式失败，可以手动安装：

1. **下载 Flutter SDK**
   - 访问：https://docs.flutter.dev/get-started/install/windows
   - 点击 "Download Flutter SDK" 按钮
   - 下载 `flutter_windows_3.24.5-stable.zip`

2. **解压到固定位置**
   - 解压到 `C:\flutter\`（或其他不包含空格的路径）
   - **不要**解压到 `Program Files`

3. **添加到 PATH**
   - 按 `Win + X`，选择 "系统"
   - 点击 "高级系统设置"
   - 点击 "环境变量"
   - 在 "用户变量" 中找到 `Path`，点击 "编辑"
   - 点击 "新建"，添加 `C:\flutter\bin`
   - 点击 "确定" 保存

4. **验证安装**
   - 打开新的 PowerShell 窗口
   - 运行 `flutter --version`

---

## 需要帮助？

如果以上方法都失败，请提供以下信息：

```powershell
# 执行这些命令并截图
Get-Command flutter -ErrorAction SilentlyContinue
Get-ChildItem Env:Path | Format-List
Test-Path "C:\flutter\bin\flutter.bat"
```

