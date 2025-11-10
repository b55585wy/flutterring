# Tensor Shape 修复说明

## 问题描述

升级到 PyTorch Android 2.1.0 后，模型加载成功，但推理时出现 `RuntimeError`：

```
RuntimeError: Given input with spatial size (2, 2), kernel_size=(5, 1), 
dilation=(1, 1), padding=(0, 0), calculated shape of the array of sliding 
blocks as (0, 1), but its components must be at least one.
```

## 根本原因

**输入 Tensor 格式不匹配**：

### 模型期望的输入格式（训练 + 导出）
- Shape: `(batch, length, channels)` = `[1, 3000, 2]`
- 布局: `[t0_c0, t0_c1, t1_c0, t1_c1, ...]` (时间步交错)
- 说明: HR 模型 `C=1`（仅 IR）, BP/SpO2 模型 `C=2`（IR+RED）

### Android 原实现传入的格式（错误）
- Shape: `(batch, channels, length)` = `[1, 2, 500]`
- 布局: `[c0_t0, c0_t1, ..., c0_t499, c1_t0, c1_t1, ..., c1_t499]` (通道连续)

### 为什么会出错
模型内部在 `transformer.py` 的 `forward` 中：
```python
input = torch.unsqueeze(torch.permute(x, [0, 2, 1]), -1)
# 期望 x: [1, 3000, 2] -> permute -> [1, 2, 3000] -> unsqueeze -> [1, 2, 3000, 1]
# 实际传入 [1, 2, 500] -> permute -> [1, 500, 2] -> unsqueeze -> [1, 500, 2, 1]
# 导致 spatial size=(2, 1) 无法用 kernel_size=(5, 1) 卷积
```

## 修复内容

### 1. 修改 Tensor 构造逻辑

**文件**: `app/src/main/java/com/tsinghua/openring/inference/ModelInferenceManager.java`

**修改前** (行 445-454):
```java
float[] input = new float[targetLength * 2];
for (int i = 0; i < targetLength; i++) {
    input[i] = resampledGreen[i]; // channel 0
    input[targetLength + i] = resampledIr[i]; // channel 1
}
normalizeInPlace(input, targetLength);
long[] shape = new long[]{1, 2, targetLength};  // ❌ 错误: [B, C, T]
Tensor tensor = Tensor.fromBlob(input, shape);
```

**修改后**:
```java
// Interleave channels: [t0_green, t0_ir, t1_green, t1_ir, ...]
// to match (batch=1, length=T, channels=2) layout
float[] input = new float[targetLength * 2];
for (int i = 0; i < targetLength; i++) {
    input[i * 2] = resampledGreen[i];     // time step i, channel 0
    input[i * 2 + 1] = resampledIr[i];    // time step i, channel 1
}
normalizeInPlace(input, targetLength);
long[] shape = new long[]{1, targetLength, 2};  // ✅ 正确: [B, T, C]
Tensor tensor = Tensor.fromBlob(input, shape);
```

### 2. 修改归一化函数

**修改前** (行 572-592):
```java
private void normalizeInPlace(float[] data, int lengthPerChannel) {
    int channels = 2;
    for (int c = 0; c < channels; c++) {
        int offset = c * lengthPerChannel;  // ❌ 假设通道连续存储
        // ... 计算 mean/std
        for (int t = 0; t < lengthPerChannel; t++) {
            data[offset + t] = normalized_value;
        }
    }
}
```

**修改后**:
```java
private void normalizeInPlace(float[] data, int lengthPerChannel) {
    int channels = 2;
    // Data is interleaved: [t0_c0, t0_c1, t1_c0, t1_c1, ...]
    for (int c = 0; c < channels; c++) {
        double mean = 0;
        for (int t = 0; t < lengthPerChannel; t++) {
            mean += data[t * channels + c];  // ✅ 按交错格式访问
        }
        mean /= lengthPerChannel;
        // ... 计算方差并归一化
        for (int t = 0; t < lengthPerChannel; t++) {
            int idx = t * channels + c;
            data[idx] = (float) ((data[idx] - mean) / std);
        }
    }
}
```

## 验证方法

### 1. 重新安装 APK
```bash
./gradlew assembleDebug
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### 2. 运行应用并连接设备

### 3. 查看推理日志
```bash
# 实时查看
adb logcat | grep -E "ModelInference|HR=|BP_|SpO2"

# 或拉取日志文件
adb pull /storage/emulated/0/Documents/OpenRingLogs/ModelInference_*.txt ./
```

### 4. 期望结果
✅ **成功标志**:
```
[Model] HR=75 bpm (15ms)
[Model] BP_SYS=120 mmHg (12ms)
[Model] BP_DIA=80 mmHg (11ms)
[Model] SpO2=98% (13ms)
Total inference time: 55ms
```

❌ **失败标志**:
```
Forward failed: RuntimeError: Given input with spatial size...
```

## 技术细节

### Tensor Memory Layout

**交错布局 (Interleaved)** - 现在使用:
```
内存: [t0_c0, t0_c1, t1_c0, t1_c1, t2_c0, t2_c1, ...]
索引: data[time * channels + channel]
优点: 符合模型训练时的输入格式
```

**连续布局 (Contiguous)** - 之前错误使用:
```
内存: [t0_c0, t1_c0, t2_c0, ..., t0_c1, t1_c1, t2_c1, ...]
索引: data[channel * length + time]
优点: 某些卷积操作更快（但不适用于我们的模型）
```

### 为什么之前能编译但不能运行

- **编译时**: Java 编译器和 PyTorch JNI 只检查 API 调用正确性，不验证 Tensor shape 语义
- **加载时**: TorchScript 模型加载时只验证算子存在性，不执行前向传播
- **运行时**: 第一次 `Module.forward()` 时才会发现 shape 不匹配导致卷积/unfold 失败

## 相关文件

- 主修改: `app/src/main/java/com/tsinghua/openring/inference/ModelInferenceManager.java`
- 导出参考: `export_torchscript.py` (行 165-179)
- 模型结构: `nets/transformer.py` (forward 方法中的 permute 操作)

## 后续优化建议

### 1. 窗口长度调整
当前 Android 端使用 `windowSeconds=5`, `targetFs=100` → `targetLength=500`  
模型训练用的是 `length=3000`

**建议**:
- 如果推理结果不稳定，考虑增加 `windowSeconds` 到 30 秒（匹配 3000 样本 @ 100Hz）
- 或调整 `targetFs` 与训练时的采样率一致

### 2. HR 模型单通道支持
HR 模型只需要 IR 通道 (`C=1`)，当前仍传入 2 通道可能浪费计算。

**可选优化**:
```java
// 针对 HR 任务单独构造单通道 tensor
if (mission == Mission.HR) {
    float[] inputHR = resampledIr; // 只用 IR 通道
    normalizeInPlace(inputHR, targetLength);
    long[] shape = new long[]{1, targetLength, 1};
    Tensor tensorHR = Tensor.fromBlob(inputHR, shape);
}
```

### 3. Batch Inference
如果需要同时处理多个窗口，可以扩展 batch 维度：
```java
long[] shape = new long[]{batchSize, targetLength, channels};
```

## 总结

此次修复解决了 Tensor shape 从 `[B, C, T]` 到 `[B, T, C]` 的格式转换问题，确保 Android 端输入与模型训练时的格式完全一致。修复后模型应能正常推理并输出生理指标。

