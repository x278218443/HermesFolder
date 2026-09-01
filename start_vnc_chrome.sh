#!/bin/bash
# 启动 VNC + Chrome 环境（用于抖音发布）
# 用法: bash ~/start_vnc_chrome.sh

set -e

echo "=== 启动 VNC + Chrome ==="

# 清理旧进程
pkill -f "Xvfb :99" 2>/dev/null || true
pkill -f fluxbox 2>/dev/null || true
pkill -f x11vnc 2>/dev/null || true
sleep 1

# 1. Xvfb
echo "[1/4] Xvfb..."
Xvfb :99 -screen 0 1280x800x24 -ac &
sleep 1
export DISPLAY=:99

# 2. fluxbox
echo "[2/4] fluxbox..."
fluxbox &
sleep 1

# 3. Chrome (CDP:9222)
echo "[3/4] Chrome (CDP:9222)..."
cd /home/ubuntu/ClawFolder/ai-video-pipeline
/home/ubuntu/.cache/ms-playwright/chromium-1234/chrome-linux64/chrome \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --remote-debugging-port=9222 \
    --disable-blink-features=AutomationControlled \
    --window-size=1280,800 \
    "https://creator.douyin.com/creator-micro/home" &
sleep 5

# 4. x11vnc
echo "[4/4] x11vnc (端口 5900)..."
x11vnc -display :99 -forever -shared -rfbport 5900 -nopw -xdamage &
sleep 2

echo ""
echo "=== 全部就绪 ==="
echo "Chrome CDP: localhost:9222"
echo "VNC:       $(curl -s ifconfig.me):5900"
echo "VNC 客户端连接即可看到 Chrome 浏览器"
echo ""
