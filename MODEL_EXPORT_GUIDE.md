# 模型导出指南 - 兼容PyTorch Android 1.13.1

## 问题总结

当前模型使用了PyTorch 2.0+的特性 (`aten::scaled_dot_product_attention`)，但PyTorch Android 1.13.1不支持这个算子。

## 解决方案

在训练代码中重新导出模型，使其兼容PyTorch 1.13.1。

## 修改步骤

### 1. 在模型定义中避免使用PyTorch 2.0+特性

**问题代码** (使用了 `scaled_dot_product_attention`):
```python
# 在 Transformer Attention 中
out = torch.scaled_dot_product_attention(q, k, v, attn_mask, dropout_p=0., is_causal=False, scale=...)
```

**修复代码** (使用兼容的实现):
```python
# 替换为显式的attention计算
def scaled_dot_product_attention_compatible(q, k, v, attn_mask=None, dropout_p=0.0, scale=None):
    """
    兼容PyTorch 1.x的scaled dot product attention实现
    """
    B, H, L, D = q.shape
    if scale is None:
        scale = 1.0 / math.sqrt(D)
    
    # Q @ K^T
    attn = torch.matmul(q, k.transpose(-2, -1)) * scale  # [B, H, L, L]
    
    # 应用mask
    if attn_mask is not None:
        attn = attn + attn_mask
    
    # Softmax
    attn = torch.softmax(attn, dim=-1)
    
    # Dropout (导出时通常设为0)
    if dropout_p > 0.0:
        attn = torch.nn.functional.dropout(attn, p=dropout_p)
    
    # Attention @ V
    out = torch.matmul(attn, v)  # [B, H, L, D]
    
    return out

# 在 Transformer 模块中使用
out = scaled_dot_product_attention_compatible(q, k, v, attn_mask, dropout_p=0., scale=0.17677669529663689)
```

### 2. 导出模型时使用 TorchScript

在您的训练/导出脚本中:

```python
import torch
import torch.nn as nn

# 1. 加载模型
model = YourModel()  # 您的模型类
checkpoint = torch.load('transformer-ring1-hr-all-ir_hr_Fold-1_best.pt')
model.load_state_dict(checkpoint)
model.eval()

# 2. 创建示例输入 (根据config.json中的参数)
# window_duration=5, target_fs=100, input_channels=2
# 所以输入shape应该是 [batch_size, seq_len, input_channels]
# seq_len = window_duration * target_fs = 5 * 100 = 500
example_input = torch.randn(1, 500, 2)

# 3. 使用 torch.jit.trace 导出 (推荐)
with torch.no_grad():
    traced_model = torch.jit.trace(model, example_input)
    
# 4. 保存为 TorchScript 格式
traced_model.save('transformer-ring1-hr-all-ir_hr_Fold-1_best_ts.pt')

print("✓ 模型导出成功！")

# 5. 验证导出的模型
loaded_model = torch.jit.load('transformer-ring1-hr-all-ir_hr_Fold-1_best_ts.pt')
test_input = torch.randn(1, 500, 2)
with torch.no_grad():
    output = loaded_model(test_input)
    print(f"输出shape: {output.shape}")
    print(f"输出值示例: {output[0, -1].item()}")
```

### 3. 确保使用兼容的PyTorch版本进行导出

```bash
# 推荐使用PyTorch 1.13.x进行导出
pip install torch==1.13.1 torchvision==0.14.1
```

### 4. 导出所有4个模型

需要导出以下模型：

1. **HR模型**: `transformer-ring1-hr-all-ir/hr/Fold-1/...`
   - Input: `[1, 500, 2]` (5秒 × 100Hz, 2通道: green+ir)
   - Output: `[1, 1]` (心率值)

2. **BP_sys模型**: `transformer-ring1-bp-all-irred/BP_sys/Fold-1/...`
   - Input: `[1, 500, 3]` (5秒 × 100Hz, 3通道: ir+red+acc)
   - Output: `[1, 1]` (收缩压)

3. **BP_dia模型**: `transformer-ring1-bp-all-irred/BP_dia/Fold-1/...`
   - Input: `[1, 500, 3]` (5秒 × 100Hz, 3通道: ir+red+acc)
   - Output: `[1, 1]` (舒张压)

4. **SPO2模型**: `transformer-ring1-spo2-all-irred/spo2/Fold-1/...`
   - Input: `[1, 500, 3]` (5秒 × 100Hz, 3通道: ir+red+acc)
   - Output: `[1, 1]` (血氧饱和度)

### 5. 验证导出的模型

创建一个简单的测试脚本:

```python
import torch

def test_exported_model(model_path, input_shape):
    try:
        # 加载模型
        model = torch.jit.load(model_path)
        model.eval()
        
        # 创建测试输入
        test_input = torch.randn(*input_shape)
        
        # 运行推理
        with torch.no_grad():
            output = model(test_input)
        
        print(f"✓ {model_path}")
        print(f"  Input shape: {input_shape}")
        print(f"  Output shape: {output.shape}")
        print(f"  Output value: {output.item():.2f}")
        print()
        
        return True
    except Exception as e:
        print(f"✗ {model_path}")
        print(f"  Error: {e}")
        print()
        return False

# 测试所有模型
test_exported_model('transformer-ring1-hr-all-ir_hr_Fold-1_best_ts.pt', [1, 500, 2])
test_exported_model('transformer-ring1-bp-all-irred_BP_sys_Fold-1_best_ts.pt', [1, 500, 3])
test_exported_model('transformer-ring1-bp-all-irred_BP_dia_Fold-1_best_ts.pt', [1, 500, 3])
test_exported_model('transformer-ring1-spo2-all-irred_spo2_Fold-1_best_ts.pt', [1, 500, 3])
```

### 6. 部署到Android项目

将新导出的 `.pt` 文件替换到对应目录：
- `app/models/transformer-ring1-hr-all-ir/hr/Fold-1/`
- `app/models/transformer-ring1-bp-all-irred/BP_sys/Fold-1/`
- `app/models/transformer-ring1-bp-all-irred/BP_dia/Fold-1/`
- `app/models/transformer-ring1-spo2-all-irred/spo2/Fold-1/`

### 7. 重新编译并测试

```bash
./gradlew assembleDebug
# 安装并运行
./pull_logs.sh  # 查看日志
```

## 注意事项

1. **输入shape必须匹配**: 确保导出时的example_input shape与Android代码中的shape一致
2. **使用eval模式**: 导出前必须调用 `model.eval()`
3. **禁用Dropout**: 推理时dropout应该为0
4. **测试输出范围**: 确保输出值在合理范围内 (HR: 40-200, BP: 80-180, SpO2: 90-100)
5. **检查config.json**: 确保配置文件中的参数与实际模型匹配

## 常见问题

**Q: 为什么不能直接使用现有的.pt文件？**  
A: 现有文件使用了PyTorch 2.0+的`scaled_dot_product_attention`算子，PyTorch Android 1.13.1不支持。

**Q: 可以升级PyTorch Android版本吗？**  
A: PyTorch Android目前最新稳定版本仍是1.13.1，官方尚未发布2.x版本。

**Q: 如何知道模型是否使用了不兼容的算子？**  
A: 在Android Logcat中会看到 "Unknown builtin op: aten::..." 错误。

## 参考资料

- [PyTorch Mobile Documentation](https://pytorch.org/mobile/android/)
- [TorchScript Documentation](https://pytorch.org/docs/stable/jit.html)
- [PyTorch Android GitHub](https://github.com/pytorch/pytorch/tree/main/android)

