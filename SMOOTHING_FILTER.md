# 平滑滤波功能说明

## 功能概述

为了减少生理指标（HR、BP、SpO2）的显示跳变，添加了**加权移动平均滤波器**，让数值变化更平滑、更符合生理规律。

## 实现原理

### 1. 历史缓冲区
为每个指标维护一个历史记录队列：
```java
private final ArrayDeque<Integer> hrHistory = new ArrayDeque<>();
private final ArrayDeque<Integer> bpSysHistory = new ArrayDeque<>();
private final ArrayDeque<Integer> bpDiaHistory = new ArrayDeque<>();
private final ArrayDeque<Integer> spo2History = new ArrayDeque<>();
```

### 2. 窗口大小
```java
private static final int SMOOTHING_WINDOW_SIZE = 5; // 使用最近5次结果
```
- 保留最近 **5 次**推理结果
- 每 2 秒推理一次 → 覆盖最近 **10 秒**的数据
- 窗口越大越平滑，但响应越慢

### 3. 加权平均算法

**线性加权**：最新值权重最大，历史值权重递减
```
权重分配: [1, 2, 3, 4, 5]
         旧←----------→新

计算公式:
smoothed = (v1×1 + v2×2 + v3×3 + v4×4 + v5×5) / (1+2+3+4+5)
```

**示例**：
```
原始值序列: [70, 85, 75, 80, 78]
加权计算: (70×1 + 85×2 + 75×3 + 80×4 + 78×5) / 15
       = (70 + 170 + 225 + 320 + 390) / 15
       = 1175 / 15
       ≈ 78.3 → 78

直接平均: (70+85+75+80+78) / 5 = 77.6 → 78
```

## 效果对比

### 原始输出（无滤波）
```
Time    Raw HR
0s      72
2s      85  ← 跳变 +13
4s      68  ← 跳变 -17
6s      82  ← 跳变 +14
8s      75  ← 跳变 -7
```

### 平滑后输出
```
Time    Raw HR  Smoothed HR
0s      72      72         (仅1个值)
2s      85      81         (72×1 + 85×2) / 3
4s      68      74         (72×1 + 85×2 + 68×3) / 6
6s      82      77         (72×1 + 85×2 + 68×3 + 82×4) / 10
8s      75      77         (72×1 + 85×2 + 68×3 + 82×4 + 75×5) / 15
10s     78      78         (85×1 + 68×2 + 82×3 + 75×4 + 78×5) / 15
```

**观察**：
- 平滑值变化幅度明显减小（±2-5 vs ±7-17）
- 保持趋势（上升/下降）但消除了尖峰
- 前几次测量逐步收敛到稳定值

## 日志输出

每次推理会同时输出原始值和平滑值：
```
[Model] HR=78 bpm (raw=75, 8ms)
[Model] BP_SYS=118 mmHg (raw=122, 10ms)
[Model] BP_DIA=78 mmHg (raw=81, 5ms)
[Model] SPO2=96% (raw=94, 6ms)
```

## 参数调优

### 增加平滑度（更稳定，但响应慢）
```java
private static final int SMOOTHING_WINDOW_SIZE = 10; // 改为 10
```
- 覆盖 20 秒历史
- 适合静息状态测量
- 运动状态可能滞后

### 减少平滑度（快速响应，但跳变多）
```java
private static final int SMOOTHING_WINDOW_SIZE = 3; // 改为 3
```
- 覆盖 6 秒历史
- 适合运动状态或快速变化
- 可能仍有明显跳变

### 改用简单平均（均等权重）
```java
private int smoothValue(ArrayDeque<Integer> history, int newValue) {
    history.addLast(newValue);
    while (history.size() > SMOOTHING_WINDOW_SIZE) {
        history.removeFirst();
    }
    
    // 简单算术平均
    int sum = 0;
    for (Integer value : history) {
        sum += value;
    }
    return Math.round((float) sum / history.size());
}
```

## 生理合理性

### 心率（HR）
- 正常范围：60-100 bpm
- 变化速度：每秒 ±1-2 bpm（平缓）
- **平滑必要性**：高，避免突变

### 血压（BP）
- 正常范围：收缩压 90-140 mmHg，舒张压 60-90 mmHg
- 变化速度：每分钟 ±5 mmHg
- **平滑必要性**：中，保持稳定趋势

### 血氧（SpO2）
- 正常范围：95-100%
- 变化速度：极慢（健康人）
- **平滑必要性**：高，通常保持恒定

## 特殊情况处理

### 1. 冷启动（前5次测量）
- 历史记录不足，权重自动调整
- 第1次：直接显示原始值
- 第2次：(v1×1 + v2×2) / 3
- ...逐步增加到完整窗口

### 2. 异常值检测（可选扩展）
如需过滤极端异常值，可添加：
```java
// 检测是否为异常值（超过历史均值±30%）
if (history.size() >= 3) {
    int avg = history.stream().mapToInt(Integer::intValue).sum() / history.size();
    if (Math.abs(newValue - avg) > avg * 0.3) {
        // 异常值：用历史均值替代
        newValue = avg;
    }
}
```

### 3. 测量中断后重启
- 停止测量时可调用 `clearHistory()` 清空历史
- 重新开始时从干净状态开始

## 代码位置

**文件**: `app/src/main/java/com/tsinghua/openring/inference/ModelInferenceManager.java`

**关键方法**:
- `smoothValue()`: 行 635-651（平滑算法实现）
- HR 应用平滑: 行 500-503
- BP_SYS 应用平滑: 行 514-517
- BP_DIA 应用平滑: 行 528-531
- SpO2 应用平滑: 行 542-545

## 性能影响

- **计算开销**：O(N)，N=5，可忽略（< 0.1ms）
- **内存开销**：4个队列 × 5个整数 × 4字节 = 80字节
- **总体影响**：对推理性能无影响

## 测试建议

1. **静息状态**：数值应平稳，变化<±3
2. **运动后恢复**：能跟踪下降趋势，不会卡在高位
3. **快速变化**：5-10秒内反映变化（取决于窗口大小）
4. **对比原始值**：查看日志中的 `raw=XX` 验证滤波效果

