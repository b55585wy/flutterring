# 🔧 故障排除指南

**最后更新**: 2025-10-30

---

## ✅ 已解决的问题

### 问题 1: Gradle 版本与 Java 不兼容 ✅ 已解决

#### **错误信息**:
```
BUG! exception in phase 'semantic analysis' in source unit '_BuildScript_' 
Unsupported class file major version 65
BUILD FAILED
```

#### **原因**:
- Flutter 使用 JDK 21（class file major version 65）
- 原 Gradle 版本 8.0 不兼容 JDK 21
- Gradle 8.5+ 才支持 JDK 21

#### **解决方案** ✅:
升级以下文件：

1. **`android/gradle/wrapper/gradle-wrapper.properties`**:
   ```properties
   - distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
   + distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip
   ```

2. **`android/build.gradle`**:
   ```gradle
   dependencies {
   -   classpath "com.android.tools.build:gradle:8.1.0"
   +   classpath "com.android.tools.build:gradle:8.3.2"
   -   ext.kotlin_version = '1.9.0'
   +   ext.kotlin_version = '1.9.20'
   }
   ```

3. **`android/settings.gradle`**:
   ```gradle
   plugins {
   -   id "com.android.application" version "8.1.0" apply false
   +   id "com.android.application" version "8.3.2" apply false
   -   id "org.jetbrains.kotlin.android" version "1.9.0" apply false
   +   id "org.jetbrains.kotlin.android" version "1.9.20" apply false
   }
   ```

4. **清理并重新构建**:
   ```powershell
   cd android
   .\gradlew.bat clean
   cd ..
   flutter clean
   flutter run
   ```

#### **结果**: ✅ Gradle 8.7 下载成功，构建继续进行

---

### 问题 2: NDK 版本不一致警告 ⚠️ 已处理

#### **警告信息**:
```
Your project is configured with Android NDK 23.1.7779620, but the following plugin(s) 
depend on a different Android NDK version:
- flutter_local_notifications requires Android NDK 25.1.8937393
- path_provider_android requires Android NDK 25.1.8937393
...
```

#### **解决方案** ✅:
在 `android/app/build.gradle` 中指定 NDK 版本：

```gradle
android {
    namespace "com.tsinghua.openring_flutter"
    compileSdk flutter.compileSdkVersion
-   ndkVersion flutter.ndkVersion
+   ndkVersion "25.1.8937393"
}
```

#### **结果**: ⚠️ 警告消除，兼容性提升

---

## 📋 Java/Gradle 版本兼容表

| Java 版本 | Gradle 最低版本 | 推荐 Gradle 版本 | 状态 |
|----------|----------------|-----------------|------|
| JDK 8    | 2.0            | 4.10.3          | ❌ 过时 |
| JDK 11   | 5.0            | 7.0             | ⚠️ 旧版 |
| JDK 17   | 7.3            | 8.0             | ✅ 稳定 |
| JDK 21   | **8.5**        | **8.7+**        | ✅ **当前** |
| JDK 22   | 8.8            | 8.8+            | ✅ 最新 |

**当前配置**:
- ✅ Java: JDK 21
- ✅ Gradle: 8.7
- ✅ Android Gradle Plugin: 8.3.2
- ✅ Kotlin: 1.9.20

---

## 🚨 常见错误及解决方案

### 错误 1: "SDK location not found"

#### **症状**:
```
SDK location not found. Define location with sdk.dir in the local.properties file 
or with an ANDROID_HOME environment variable.
```

#### **解决**:
检查 `android/local.properties`:
```properties
flutter.sdk=C:\\Users\\a1396\\Devkit\\flutter
sdk.dir=C:\\Users\\a1396\\AppData\\Local\\Android\\Sdk
```

---

### 错误 2: "Execution failed for task ':app:checkDebugAarMetadata'"

#### **症状**:
```
Execution failed for task ':app:checkDebugAarMetadata'.
> Could not resolve all files for configuration ':app:debugRuntimeClasspath'.
```

#### **解决**:
1. 检查 AAR 文件是否存在:
   ```powershell
   ls android/app/libs/ChipletRing1.0.81.aar
   ```

2. 确认 `build.gradle` 中配置了 flatDir:
   ```gradle
   android {
       repositories {
           flatDir {
               dirs 'libs'
           }
       }
   }
   
   dependencies {
       implementation(name: 'ChipletRing1.0.81', ext: 'aar')
   }
   ```

---

### 错误 3: "AndroidX migration required"

#### **症状**:
```
[!] Your app isn't using AndroidX.
To avoid potential build failures, you can quickly migrate your app 
by following the steps on https://goo.gl/CP92wY .
```

#### **解决** (可选，通常不影响构建):
1. 在 Android Studio 中打开 `android/` 目录
2. 菜单: Refactor → Migrate to AndroidX
3. 点击 "Do Refactor"

**或手动添加** `gradle.properties`:
```properties
android.useAndroidX=true
android.enableJetifier=true
```

---

### 错误 4: "Unable to load class 'org.gradle.api.internal.project.ProjectInternal'"

#### **症状**:
```
Unable to load class 'org.gradle.api.internal.project.ProjectInternal'.
This is an unexpected error. Please file a bug...
```

#### **解决**:
清理所有缓存：
```powershell
cd android
.\gradlew.bat clean
cd ..
flutter clean
flutter pub get

# 删除 Gradle 缓存（最后手段）
Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches
```

---

### 错误 5: "Manifest merger failed"

#### **症状**:
```
Manifest merger failed : Attribute application@label value=(openring_flutter) 
from AndroidManifest.xml is also present at [:app] AndroidManifest.xml
```

#### **解决**:
检查 `AndroidManifest.xml` 中的冲突属性，确保没有重复的 `android:label` 或 `android:icon`。

---

### 错误 6: "Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'"

#### **症状**:
```
Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'.
> Failed to install the following Android SDK packages as some licences have not been accepted.
```

#### **解决**:
接受 Android SDK 许可证：
```powershell
C:\Users\a1396\Devkit\flutter\bin\flutter.bat doctor --android-licenses
# 连续输入 'y' 接受所有许可证
```

---

## 🔍 调试技巧

### 1. 查看详细构建日志
```powershell
cd android
.\gradlew.bat assembleDebug --stacktrace --info
```

### 2. 检查 Gradle 守护进程
```powershell
# 停止所有 Gradle 守护进程
cd android
.\gradlew.bat --stop

# 重新构建
cd ..
flutter run
```

### 3. 清理所有缓存
```powershell
flutter clean
cd android
.\gradlew.bat clean
.\gradlew.bat cleanBuildCache
cd ..
flutter pub get
```

### 4. 查看设备日志
```powershell
# 查看 Android 日志
C:\Users\a1396\AppData\Local\Android\Sdk\platform-tools\adb.exe logcat

# 过滤 Flutter 日志
adb logcat | Select-String "flutter"
```

---

## 📊 当前构建状态

### ✅ 已完成
- ✅ Gradle 版本升级到 8.7
- ✅ Android Gradle Plugin 升级到 8.3.2
- ✅ Kotlin 版本升级到 1.9.20
- ✅ NDK 版本指定为 25.1.8937393
- ✅ Gradle 缓存清理
- ✅ 模拟器运行中（emulator-5554）

### 🔄 进行中
- 🔄 Flutter 应用构建中（预计 3-5 分钟）
- 🔄 首次下载依赖包

### ⏳ 待验证
- ⏳ 应用安装到模拟器
- ⏳ UI 正常显示
- ⏳ Platform Channel 通信

---

## 🎯 验证清单

构建完成后，请验证：

### 1. 应用启动 ✅
- [ ] 模拟器中出现 "OpenRing" 图标
- [ ] 点击图标，应用启动
- [ ] 显示 Dashboard 页面

### 2. UI 导航 ✅
- [ ] 点击 "Start Measurement" 跳转到测量页
- [ ] 返回按钮正常工作
- [ ] 底部导航栏可切换页面

### 3. 测量页功能 ✅
- [ ] 数据源下拉菜单可选择
- [ ] 生理指标卡片显示（初始 "--"）
- [ ] 波形图表区域显示占位符
- [ ] 开始/停止按钮可点击

### 4. Platform Channel ⏳
- [ ] 按下 "开始测量" 不崩溃
- [ ] 查看 `flutter run` 日志，无红色错误

---

## 📞 如果仍有问题

### 收集信息
```powershell
# 1. Flutter 环境信息
C:\Users\a1396\Devkit\flutter\bin\flutter.bat doctor -v > flutter_doctor.txt

# 2. Gradle 版本信息
cd android
.\gradlew.bat --version > gradle_version.txt

# 3. 构建日志
.\gradlew.bat assembleDebug --stacktrace > build_log.txt 2>&1
```

### 提供以下信息
1. `flutter_doctor.txt` 内容
2. `gradle_version.txt` 内容
3. `build_log.txt` 中的错误信息
4. 完整的错误堆栈跟踪

---

## 🔄 应急方案

### 方案 A: 使用 Android Studio 构建
1. 在 Android Studio 中打开 `android/` 目录
2. 等待 Gradle 同步完成
3. 点击工具栏的 "Run" 按钮
4. 选择模拟器设备

### 方案 B: 降级到已知稳定版本
如果 Gradle 8.7 仍有问题，可以尝试：

**`gradle-wrapper.properties`**:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-all.zip
```

**`build.gradle`** 和 **`settings.gradle`**:
```gradle
classpath "com.android.tools.build:gradle:8.2.0"
```

---

## 🎊 成功标志

当您看到以下输出，说明构建成功：

```
✓ Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app.apk...
Waiting for sdk gphone64 x86 64 to report its views...
Debug service listening on ws://127.0.0.1:xxxxx/xxxxxxxx=/ws
Syncing files to device sdk gphone64 x86 64...

Flutter run key commands.
r Hot reload. 
R Hot restart.
q Quit (terminate the application on the device).
```

**然后在模拟器中，您将看到 OpenRing 应用运行！** 🚀

---

**记住**: 首次构建需要时间，耐心等待。后续热重载只需 1-2 秒！

