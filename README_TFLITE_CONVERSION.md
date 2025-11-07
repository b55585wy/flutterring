# PyTorch 模型转换为 TensorFlow Lite 指南

## 问题说明

当前模型使用了 `torch.scaled_dot_product_attention`（PyTorch 2.0+ 特性），但 PyTorch Android 最新版本仍是 1.13.1（不支持该特性）。

**解决方案**: 使用 Google AI Edge Torch 将模型转换为 TensorFlow Lite

## 步骤1：安装依赖

```bash
# 在 Python 环境中安装（需要 Python 3.8+）
pip install ai-edge-torch torch torchvision numpy tensorflow
```

## 步骤2：转换模型

```bash
cd /Users/wangyi/StudioProjects/OpenRing
python convert_models_to_tflite.py
```

转换脚本会：
1. 读取所有 PyTorch 模型（.pt 文件）
2. 转换为 TensorFlow Lite 格式（.tflite 文件）
3. 验证转换后的模型输出
4. 保存在相同目录下

## 步骤3：编译 Android 应用

```bash
./gradlew assembleDebug
```

应用会自动：
1. 打包 TFLite 模型到 APK
2. 使用 TensorFlow Lite 运行推理
3. 支持 GPU 加速（如果设备支持）

## 文件变更说明

### 新增文件
- `convert_models_to_tflite.py` - 模型转换脚本
- `app/models/*/model.tflite` - 转换后的 TFLite 模型（4个）
- `ModelInferenceManager.java.pytorch_backup` - 原 PyTorch 版本备份

### 修改文件
- `app/build.gradle` - 替换 PyTorch 为 TensorFlow Lite
- `app/src/main/java/com/tsinghua/openring/inference/ModelInferenceManager.java` - 使用 TFLite API

### 删除依赖
- ~~PyTorch Android 1.13.1~~
- ~~AssetsUtils.java~~ (TFLite 不需要)

## 模型文件结构

```
app/models/
├── transformer-ring1-hr-all-ir/hr/Fold-1/
│   ├── config.json
│   ├── transformer-ring1-hr-all-ir_hr_Fold-1_best_ts.pt  (原始)
│   └── model.tflite  (新增 - 转换后)
├── transformer-ring1-bp-all-irred/BP_sys/Fold-1/
│   ├── config.json
│   ├── transformer-ring1-bp-all-irred_BP_sys_Fold-1_best_ts.pt
│   └── model.tflite
├── transformer-ring1-bp-all-irred/BP_dia/Fold-1/
│   ├── config.json
│   ├── transformer-ring1-bp-all-irred_BP_dia_Fold-1_best_ts.pt
│   └── model.tflite
└── transformer-ring1-spo2-all-irred/spo2/Fold-1/
    ├── config.json
    ├── transformer-ring1-spo2-all-irred_spo2_Fold-1_best_ts.pt
    └── model.tflite
```

## TensorFlow Lite 优势

1. ✅ 支持 PyTorch 2.0+ 特性（通过 AI Edge Torch）
2. ✅ 更好的移动端优化
3. ✅ GPU 加速支持
4. ✅ 更小的二进制文件
5. ✅ Google 官方支持

## 故障排除

### 转换失败
如果转换失败，检查：
1. Python 版本 >= 3.8
2. 已安装所有依赖
3. PyTorch 模型文件完整

### Android 编译失败
如果编译失败，检查：
1. 已运行模型转换脚本
2. TFLite 文件存在
3. Gradle 同步完成

### 推理结果不正确
如果结果异常，检查：
1. 查看日志文件（使用 `./pull_logs.sh`）
2. 检查输入数据形状
3. 验证转换脚本的输出差异

## 下一步

1. 运行转换脚本
2. 编译 Android 应用
3. 测试推理结果
4. 如有问题，查看日志文件

