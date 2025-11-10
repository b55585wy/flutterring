#!/bin/bash

echo "================================"
echo "PyTorch 模型转换为 TensorFlow Lite"
echo "================================"
echo ""

# 设置虚拟环境目录
VENV_DIR="./venv_model_conversion"

# 检查是否已有虚拟环境
if [ ! -d "$VENV_DIR" ]; then
    echo "创建虚拟环境..."
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo "✗ 无法创建虚拟环境"
        exit 1
    fi
    echo "✓ 虚拟环境创建成功"
else
    echo "✓ 使用已有虚拟环境: $VENV_DIR"
fi
echo ""

# 激活虚拟环境
echo "激活虚拟环境..."
source "$VENV_DIR/bin/activate"

# 显示Python版本
echo "Python 版本: $(python --version)"
echo ""

# 升级pip
echo "升级 pip..."
pip install --upgrade pip > /dev/null 2>&1
echo "✓ pip 已升级"
echo ""

# 安装依赖（指定兼容的版本）
echo "安装依赖包（这可能需要几分钟）..."

echo "  [1/5] 安装 numpy..."
pip install "numpy<2.0" > /dev/null 2>&1
if [ $? -eq 0 ]; then echo "    ✓ numpy 安装成功"; else echo "    ✗ numpy 安装失败"; fi

echo "  [2/5] 安装 torch & torchvision..."
pip install torch torchvision > /dev/null 2>&1
if [ $? -eq 0 ]; then echo "    ✓ torch 安装成功"; else echo "    ✗ torch 安装失败"; fi

echo "  [3/5] 安装 tensorflow..."
pip install "tensorflow>=2.14.0,<2.21" > /dev/null 2>&1
if [ $? -eq 0 ]; then echo "    ✓ tensorflow 安装成功"; else echo "    ✗ tensorflow 安装失败"; fi

echo "  [4/5] 安装 h5py（兼容版本）..."
pip install "h5py>=3.8.0" --no-build-isolation > /dev/null 2>&1
if [ $? -eq 0 ]; then echo "    ✓ h5py 安装成功"; else echo "    ✗ h5py 安装失败"; fi

echo "  [5/5] 安装 ai-edge-torch..."
pip install ai-edge-torch > /dev/null 2>&1
if [ $? -eq 0 ]; then echo "    ✓ ai-edge-torch 安装成功"; else echo "    ✗ ai-edge-torch 安装失败"; fi

echo ""
echo "✓ 所有依赖安装完成"
echo ""

# 运行转换脚本
echo "开始转换模型..."
echo "================================"
python convert_models_to_tflite.py
CONVERSION_STATUS=$?
echo "================================"

# 停用虚拟环境
deactivate

echo ""
if [ $CONVERSION_STATUS -eq 0 ]; then
    echo "✓ 转换成功完成！"
    echo ""
    echo "转换后的 .tflite 文件已保存在各模型目录的 Fold-1 文件夹中"
    echo ""
    echo "📋 下一步："
    echo "  1. 查看 app/models/ 目录下的 .tflite 文件"
    echo "  2. 修改 ModelInferenceManager.java 使用 TFLite Interpreter"
    echo "  3. 更新 app/build.gradle 切换到 TFLite 依赖"
    echo "  4. 重新编译并测试应用"
    echo ""
else
    echo "✗ 转换失败 (退出代码: $CONVERSION_STATUS)"
    echo ""
    echo "请检查上面的错误信息，或尝试："
    echo "  - 删除虚拟环境: rm -rf $VENV_DIR"
    echo "  - 重新运行脚本: ./run_conversion.sh"
fi

echo "================================"
