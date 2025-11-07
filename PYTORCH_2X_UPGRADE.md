# PyTorch Android 2.x 升级说明

## 升级内容

### 依赖版本升级
- **从**: `pytorch_android:1.13.1` 
- **到**: `pytorch_android:2.1.0`

### 升级原因
TorchScript 模型使用了 `aten::scaled_dot_product_attention` 算子，该算子在 PyTorch 1.13.1 Android 运行时不存在，导致模型加载失败：

```
Unknown builtin op: aten::scaled_dot_product_attention.
com.facebook.jni.CppException at org.pytorch.Module.load
```

PyTorch 2.x 原生支持 Scaled Dot-Product Attention (SDPA)，可直接加载使用该算子的模型。

## 构建验证

### 构建状态
✅ **构建成功** (2024-11-07 13:05)
- APK 大小: 310 MB
- 包含库: `libpytorch_jni.so`, `libpytorch_vision_jni.so`
- 构建时间: ~2分钟

### 构建输出
```bash
BUILD SUCCESSFUL in 1m 57s
38 actionable tasks: 30 executed, 8 from cache
```

## 验证步骤

### 1. 安装 APK
```bash
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### 2. 运行应用并检查日志
```bash
# 实时查看模型加载日志
adb logcat | grep ModelInference

# 或查看设备上的日志文件
adb pull /storage/emulated/0/Documents/OpenRingLogs/ModelInference_*.txt ./
```

### 3. 验证模型加载状态
应用启动后，在 Logs 标签页查看：
- ✅ **期望**: "Model loaded successfully" 出现 4 次 (HR, BP_SYS, BP_DIA, SPO2)
- ❌ **旧错误**: "Unknown builtin op: aten::scaled_dot_product_attention"

### 4. 验证实时推理
连接设备后开始在线测量，应能看到：
- HR (心率) 数值更新
- BP_SYS (收缩压) 数值更新
- BP_DIA (舒张压) 数值更新
- SpO2 (血氧) 数值更新
- 日志显示: "HR=XX bpm (XXms)", "BP_SYS=XX mmHg (XXms)" 等

## 关键代码位置

### 模型加载
- 文件: `app/src/main/java/com/tsinghua/openring/inference/ModelInferenceManager.java`
- 方法: `loadMission(Mission mission, String missionRoot)` (行 281-400)
- 日志输出: "Model loaded successfully" 或 "Model load failed"

### 推理执行
- 方法: `runAllMissions()` (行 428-511)
- 频率: 每 2 秒执行一次（缓冲区满 5 秒数据时）
- 输出: 通过 `Listener` 回调更新 UI

## 已知问题

### APK 体积增大
- PyTorch 2.1.0 运行库比 1.13.1 更大
- 可选优化：使用 `pytorch_android_lite` (需验证算子支持)
- 或启用 ProGuard/R8 压缩（需添加 keep 规则）

### 潜在兼容性
如遇到其他算子不支持，可能需要：
1. 检查模型导出时的 PyTorch 版本
2. 使用 `torch.jit.trace` 替代 `torch.jit.script` 导出
3. 在模型代码中避免使用过新的 API

## 回退方案

如 2.1.0 有问题，可降级到 2.0.0 或改造模型：

### 方案 A: 降级到 2.0.0
```gradle
implementation 'org.pytorch:pytorch_android:2.0.0'
implementation 'org.pytorch:pytorch_android_torchvision:2.0.0'
```

### 方案 B: 改造模型避免 SDPA
在 Transformer attention 层手动实现 QK^T softmax V：
```python
# 替换 F.scaled_dot_product_attention
scores = torch.matmul(q, k.transpose(-2, -1)) / math.sqrt(d_k)
if attn_mask is not None:
    scores = scores + attn_mask
attn = F.softmax(scores, dim=-1)
output = torch.matmul(attn, v)
```

重新导出 TorchScript 后可运行在 1.13.1 上。

## 参考链接

- [PyTorch Mobile 2.0 发布说明](https://pytorch.org/blog/pytorch-2.0-release/)
- [Scaled Dot-Product Attention 文档](https://pytorch.org/docs/stable/generated/torch.nn.functional.scaled_dot_product_attention.html)
- [PyTorch Android AAR 版本](https://mvnrepository.com/artifact/org.pytorch/pytorch_android)

