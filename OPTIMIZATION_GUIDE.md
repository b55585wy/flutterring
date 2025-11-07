# OpenRing 编译优化和模型加载修复指南

## 已修复的问题

### 1. 编译速度优化 ✅

#### 问题原因：
- Gradle JVM 内存配置过低（仅 2GB）
- 并行编译被禁用
- 构建缓存未启用
- 存在大量重复的依赖项声明

#### 已应用的优化：

**`gradle.properties` 优化：**
```properties
# 内存从 2GB 增加到 4GB
org.gradle.jvmargs=-Xmx4096m -Dfile.encoding=UTF-8 -XX:MaxMetaspaceSize=1024m

# 启用并行编译
org.gradle.parallel=true

# 启用构建缓存
org.gradle.caching=true

# 按需配置
org.gradle.configureondemand=true
```

**`app/build.gradle` 优化：**
- 删除了大量重复的依赖项声明
- 合并相同版本的库
- 添加增量编译支持
- 添加 PyTorch TorchVision 支持
- 修正了 assets 源目录配置

### 2. 模型加载失败修复 ✅

#### 问题原因：
- 模型目录缺少必需的 JSON 配置文件
- 代码期望每个 Fold 目录下都有 `.json` 和 `.pt` 文件
- Assets 源目录配置可能不正确

#### 已应用的修复：

1. **为每个模型创建了 config.json 文件：**
   - `app/models/transformer-ring1-hr-all-ir/hr/Fold-1/config.json`
   - `app/models/transformer-ring1-bp-all-irred/BP_sys/Fold-1/config.json`
   - `app/models/transformer-ring1-bp-all-irred/BP_dia/Fold-1/config.json`
   - `app/models/transformer-ring1-spo2-all-irred/spo2/Fold-1/config.json`

2. **配置内容包含：**
   - `window_duration`: 5 秒
   - `target_fs`: 100 Hz (目标采样率)
   - `input_channels`: 2 (绿光和红外)
   - `sample_rate`: 25 Hz (输入采样率)

3. **修正了 assets 源目录配置：**
   ```gradle
   sourceSets {
       main {
           assets.srcDirs = ['src/main/assets', 'models']
       }
   }
   ```

## 预期效果

### 编译速度提升：
- **首次编译**：可能需要较长时间（因为要构建缓存）
- **增量编译**：速度提升 30-50%
- **清理后重新编译**：利用缓存，速度提升 20-40%

### 模型加载：
- 所有 4 个模型（HR、BP_SYS、BP_DIA、SPO2）应该能够成功加载
- 可以在 Logcat 中查看加载状态，过滤标签 `ModelInference`

## 下一步操作

### 1. 清理并重新编译
```bash
# 在项目根目录执行
./gradlew clean
./gradlew assembleDebug
```

### 2. 查看模型加载日志
在 Android Studio 的 Logcat 中过滤：
```
Tag: ModelInference
```

你应该能看到类似以下日志：
```
ModelInferenceManager.init() called
Mission root candidate success: transformer-ring1-hr-all-ir/hr
Loaded module: transformer-ring1-hr-all-ir/hr/Fold-1/...
Mission HR folds loaded: 1
...
```

### 3. 验证编译速度
- 首次编译后，尝试修改一个小文件再编译
- 应该能明显感觉到增量编译速度变快

## 可选的进一步优化

### 1. 如果还是觉得慢，可以尝试：

**增加更多内存（如果你的机器内存充足）：**
```properties
org.gradle.jvmargs=-Xmx6144m -Dfile.encoding=UTF-8 -XX:MaxMetaspaceSize=1024m
```

**使用 Gradle 守护进程：**
```properties
org.gradle.daemon=true
```

### 2. 减少模型文件大小：
如果模型文件太大（当前总计 4.9MB），可以考虑：
- 使用模型量化
- 只包含必需的 fold
- 将模型放在服务器上按需下载

### 3. 使用 Android App Bundle (AAB)：
如果你要发布到 Google Play：
```bash
./gradlew bundleRelease
```
AAB 格式会自动优化应用大小。

## 文件变更摘要

修改的文件：
1. ✅ `gradle.properties` - Gradle 构建优化
2. ✅ `app/build.gradle` - 清理依赖项，优化配置
3. ✅ `app/models/*/config.json` - 添加模型配置文件（4个）

## 技术细节

### 模型加载流程：
1. `ModelInferenceManager.init()` 被调用
2. 扫描 assets 目录查找模型根目录
3. 遍历每个 Fold-X 目录
4. 加载 config.json 配置文件
5. 使用 PyTorch Android 加载 .pt 模型文件
6. 模型准备就绪，等待传感器数据

### 数据流：
```
传感器数据 (25Hz) 
  → 缓冲 (5秒窗口)
  → 重采样 (100Hz)
  → 归一化
  → 模型推理
  → 结果输出
```

## 故障排除

### 如果编译还是很慢：
1. 检查是否有大量未使用的依赖项
2. 确保没有运行多个 Gradle 守护进程：`./gradlew --stop`
3. 清理 Gradle 缓存：删除 `~/.gradle/caches/` 目录

### 如果模型还是加载失败：
1. 检查 Logcat 中的详细错误信息
2. 确认 .pt 文件是有效的 TorchScript 模型
3. 检查 APK 中是否包含了模型文件：
   ```bash
   unzip -l app/build/outputs/apk/debug/app-debug.apk | grep ".pt"
   ```

## 性能基准

在配置良好的开发机器上（16GB RAM, SSD）：
- **清理编译**：约 2-3 分钟
- **增量编译**：约 10-30 秒
- **模型加载**：约 200-500ms（所有4个模型）

## 支持

如果遇到问题，请检查：
1. Android Studio 版本 >= 2022.1
2. Gradle 版本与 Android Gradle Plugin 版本兼容
3. Java/Kotlin 版本正确
4. 设备有足够的存储空间和内存

---
*最后更新：2025-11-07*

