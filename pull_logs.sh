#!/bin/bash

# OpenRing 日志拉取脚本
# 使用方法: ./pull_logs.sh
# 如果连接了多个设备，脚本会自动提示选择

echo "=========================================="
echo "OpenRing 日志拉取工具"
echo "=========================================="
echo ""

# 检查adb是否可用
if ! command -v adb &> /dev/null; then
    echo "错误: 未找到 adb 命令"
    echo "请确保 Android SDK Platform Tools 已安装并在 PATH 中"
    exit 1
fi

# 检查设备是否连接
DEVICES=$(adb devices | grep "device$" | wc -l | tr -d ' ')
if [ "$DEVICES" -eq 0 ]; then
    echo "错误: 未检测到已连接的Android设备"
    echo "请确保:"
    echo "  1. 设备已通过USB连接"
    echo "  2. 已启用USB调试"
    echo "  3. 已授权此电脑进行调试"
    exit 1
fi

# 处理多个设备的情况
if [ "$DEVICES" -gt 1 ]; then
    echo "检测到多个设备连接:"
    echo ""
    DEVICE_ARRAY=($(adb devices | grep "device$" | awk '{print $1}'))
    INDEX=1
    for dev in "${DEVICE_ARRAY[@]}"; do
        echo "  [$INDEX] $dev"
        INDEX=$((INDEX + 1))
    done
    echo ""
    echo -n "请选择设备编号 (1-$DEVICES): "
    read SELECTION
    if [ -z "$SELECTION" ] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "$DEVICES" ]; then
        echo "无效选择，使用第一个设备"
        DEVICE="${DEVICE_ARRAY[0]}"
    else
        DEVICE="${DEVICE_ARRAY[$((SELECTION - 1))]}"
    fi
    ADB_CMD="adb -s $DEVICE"
    echo "使用设备: $DEVICE"
else
    DEVICE=$(adb devices | grep "device$" | awk '{print $1}')
    ADB_CMD="adb"
    echo "✓ 设备已连接: $DEVICE"
fi
echo ""

# 创建本地日志目录
LOCAL_LOG_DIR="./logs"
mkdir -p "$LOCAL_LOG_DIR"

# 设备上的日志目录
DEVICE_LOG_DIR="/storage/emulated/0/Documents/OpenRingLogs"

echo "正在检查设备上的日志文件..."
echo "设备路径: $DEVICE_LOG_DIR"
echo ""

# 列出设备上的日志文件
LOG_FILES=$($ADB_CMD shell "ls $DEVICE_LOG_DIR/*.txt 2>/dev/null" | tr -d '\r')

if [ -z "$LOG_FILES" ]; then
    echo "未找到日志文件"
    echo "可能原因:"
    echo "  1. 应用尚未运行过"
    echo "  2. 日志目录不存在"
    echo ""
    echo "尝试创建日志目录..."
    $ADB_CMD shell "mkdir -p $DEVICE_LOG_DIR"
    echo "请运行应用后再试"
    exit 0
fi

echo "找到以下日志文件:"
echo "$LOG_FILES" | while read -r file; do
    if [ -n "$file" ]; then
        filename=$(basename "$file")
        echo "  - $filename"
    fi
done
echo ""

# 拉取所有日志文件
echo "正在拉取日志文件..."
echo "$LOG_FILES" | while read -r file; do
    if [ -n "$file" ]; then
        filename=$(basename "$file")
        echo "拉取: $filename"
        $ADB_CMD pull "$file" "$LOCAL_LOG_DIR/$filename" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "  ✓ 成功: $LOCAL_LOG_DIR/$filename"
        else
            echo "  ✗ 失败: $filename"
        fi
    fi
done

echo ""
echo "=========================================="
echo "日志文件已保存到: $LOCAL_LOG_DIR/"
echo "=========================================="
echo ""
echo "最新日志文件:"
ls -lt "$LOCAL_LOG_DIR"/*.txt 2>/dev/null | head -5 | awk '{print "  " $9 " (" $6 " " $7 " " $8 ")"}'
echo ""
echo "查看最新日志:"
LATEST_LOG=$(ls -t "$LOCAL_LOG_DIR"/*.txt 2>/dev/null | head -1)
if [ -n "$LATEST_LOG" ]; then
    echo "  tail -f \"$LATEST_LOG\""
    echo ""
    echo "或者直接打开:"
    echo "  open \"$LATEST_LOG\""
fi

