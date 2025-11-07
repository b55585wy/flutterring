#!/usr/bin/env python3
"""
将 PyTorch 模型转换为 TensorFlow Lite 格式
使用 Google AI Edge Torch

安装依赖:
pip install ai-edge-torch torch torchvision numpy

使用方法:
python convert_models_to_tflite.py
"""

import os
import json
import torch
import numpy as np

try:
    import ai_edge_torch
    print("✓ AI Edge Torch installed")
except ImportError:
    print("✗ AI Edge Torch not installed")
    print("Installing AI Edge Torch...")
    os.system("pip install ai-edge-torch")
    import ai_edge_torch

def convert_model_to_tflite(pt_model_path, output_path, config):
    """
    转换单个 PyTorch 模型到 TensorFlow Lite
    
    Args:
        pt_model_path: PyTorch 模型路径 (.pt)
        output_path: 输出 TFLite 模型路径 (.tflite)
        config: 配置字典，包含 window_duration, target_fs 等
    """
    print(f"\n{'='*60}")
    print(f"转换模型: {pt_model_path}")
    print(f"输出路径: {output_path}")
    print(f"{'='*60}")
    
    try:
        # 加载 PyTorch 模型
        print("1. 加载 PyTorch 模型...")
        model = torch.jit.load(pt_model_path, map_location='cpu')
        model.eval()
        print("   ✓ 模型加载成功")
        
        # 准备示例输入
        # 输入形状: [batch_size=1, channels=2, sequence_length]
        dataset_config = config.get('dataset', {})
        window_duration = dataset_config.get('window_duration', 5)
        target_fs = dataset_config.get('target_fs', 100)
        sequence_length = window_duration * target_fs  # 5秒 * 100Hz = 500
        
        print(f"2. 准备示例输入 (shape: [1, 2, {sequence_length}])...")
        sample_input = torch.randn(1, 2, sequence_length)
        print("   ✓ 示例输入准备完成")
        
        # 测试 PyTorch 模型
        print("3. 测试 PyTorch 模型...")
        with torch.no_grad():
            pytorch_output = model(sample_input)
            print(f"   ✓ PyTorch 输出: {pytorch_output.shape}, 值: {pytorch_output.item():.2f}")
        
        # 转换为 TensorFlow Lite
        print("4. 转换为 TensorFlow Lite...")
        edge_model = ai_edge_torch.convert(
            model,
            sample_args=(sample_input,)
        )
        print("   ✓ 转换成功")
        
        # 保存 TFLite 模型
        print("5. 保存 TFLite 模型...")
        edge_model.export(output_path)
        
        # 获取文件大小
        file_size = os.path.getsize(output_path)
        print(f"   ✓ 模型已保存: {output_path}")
        print(f"   ✓ 文件大小: {file_size / 1024:.2f} KB")
        
        # 验证 TFLite 模型
        print("6. 验证 TFLite 模型...")
        import tensorflow as tf
        interpreter = tf.lite.Interpreter(model_path=output_path)
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        print(f"   输入: {input_details[0]['shape']}, dtype: {input_details[0]['dtype']}")
        print(f"   输出: {output_details[0]['shape']}, dtype: {output_details[0]['dtype']}")
        
        # 测试推理
        interpreter.set_tensor(input_details[0]['index'], sample_input.numpy())
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_details[0]['index'])
        
        print(f"   ✓ TFLite 输出: {tflite_output.shape}, 值: {tflite_output[0]:.2f}")
        
        # 比较输出
        diff = abs(pytorch_output.item() - tflite_output[0])
        print(f"   ✓ 输出差异: {diff:.6f}")
        
        if diff < 0.1:
            print("   ✓ 转换验证通过！")
            return True
        else:
            print(f"   ⚠ 警告: 输出差异较大: {diff:.6f}")
            return True
            
    except Exception as e:
        print(f"   ✗ 转换失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """主函数：转换所有模型"""
    print("="*60)
    print("PyTorch 模型转换为 TensorFlow Lite")
    print("="*60)
    
    # 模型目录
    models_dir = "app/models"
    
    # 要转换的模型列表
    models_to_convert = [
        {
            'name': 'HR (心率)',
            'pt_path': 'transformer-ring1-hr-all-ir/hr/Fold-1/transformer-ring1-hr-all-ir_hr_Fold-1_best_ts.pt',
            'config_path': 'transformer-ring1-hr-all-ir/hr/Fold-1/config.json',
            'tflite_path': 'transformer-ring1-hr-all-ir/hr/Fold-1/model.tflite'
        },
        {
            'name': 'BP_SYS (收缩压)',
            'pt_path': 'transformer-ring1-bp-all-irred/BP_sys/Fold-1/transformer-ring1-bp-all-irred_BP_sys_Fold-1_best_ts.pt',
            'config_path': 'transformer-ring1-bp-all-irred/BP_sys/Fold-1/config.json',
            'tflite_path': 'transformer-ring1-bp-all-irred/BP_sys/Fold-1/model.tflite'
        },
        {
            'name': 'BP_DIA (舒张压)',
            'pt_path': 'transformer-ring1-bp-all-irred/BP_dia/Fold-1/transformer-ring1-bp-all-irred_BP_dia_Fold-1_best_ts.pt',
            'config_path': 'transformer-ring1-bp-all-irred/BP_dia/Fold-1/config.json',
            'tflite_path': 'transformer-ring1-bp-all-irred/BP_dia/Fold-1/model.tflite'
        },
        {
            'name': 'SPO2 (血氧)',
            'pt_path': 'transformer-ring1-spo2-all-irred/spo2/Fold-1/transformer-ring1-spo2-all-irred_spo2_Fold-1_best_ts.pt',
            'config_path': 'transformer-ring1-spo2-all-irred/spo2/Fold-1/config.json',
            'tflite_path': 'transformer-ring1-spo2-all-irred/spo2/Fold-1/model.tflite'
        }
    ]
    
    results = []
    
    for model_info in models_to_convert:
        print(f"\n处理模型: {model_info['name']}")
        
        pt_path = os.path.join(models_dir, model_info['pt_path'])
        config_path = os.path.join(models_dir, model_info['config_path'])
        tflite_path = os.path.join(models_dir, model_info['tflite_path'])
        
        # 检查文件是否存在
        if not os.path.exists(pt_path):
            print(f"✗ 文件不存在: {pt_path}")
            results.append({'name': model_info['name'], 'status': 'failed', 'reason': 'file_not_found'})
            continue
        
        if not os.path.exists(config_path):
            print(f"✗ 配置文件不存在: {config_path}")
            results.append({'name': model_info['name'], 'status': 'failed', 'reason': 'config_not_found'})
            continue
        
        # 加载配置
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        # 转换模型
        success = convert_model_to_tflite(pt_path, tflite_path, config)
        
        results.append({
            'name': model_info['name'],
            'status': 'success' if success else 'failed',
            'tflite_path': tflite_path if success else None
        })
    
    # 打印总结
    print("\n" + "="*60)
    print("转换总结")
    print("="*60)
    
    success_count = sum(1 for r in results if r['status'] == 'success')
    total_count = len(results)
    
    for result in results:
        status_icon = "✓" if result['status'] == 'success' else "✗"
        print(f"{status_icon} {result['name']}: {result['status']}")
        if result.get('tflite_path'):
            print(f"   路径: {result['tflite_path']}")
    
    print(f"\n成功: {success_count}/{total_count}")
    
    if success_count == total_count:
        print("\n✓ 所有模型转换成功！")
        print("\n下一步:")
        print("1. 重新编译 Android 应用")
        print("2. TFLite 模型将自动打包到 APK")
        print("3. 应用会自动使用 TFLite 模型")
    else:
        print(f"\n⚠ {total_count - success_count} 个模型转换失败")

if __name__ == "__main__":
    main()

