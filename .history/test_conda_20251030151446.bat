@echo off
echo ========================================
echo 测试 Conda 配置
echo ========================================
echo.

echo 1. 检查 Conda 版本：
call conda --version
echo.

echo 2. 列出 Conda 环境：
call conda env list
echo.

echo 3. 显示 Conda 信息：
call conda info --envs
echo.

echo ========================================
echo 测试完成！
echo ========================================
pause

