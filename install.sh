#!/bin/bash
# Pi-Star Bluetooth GPS & APRS Auto-Installer
# Author: BA4SMQ

rpi-rw

# --- 配置区 ---
GPS_MAC="00:02:76:C5:36:A0"
WATCHDOG_PATH="/usr/local/bin/gps_watchdog.sh"

echo "正在安装必要组件 (bluetooth, gpsd, socat)..."
sudo apt-get update
sudo apt-get install bluetooth bluez gpsd gpsd-clients socat -y

# --- 配置 gpsd ---
sudo tee /etc/default/gpsd <<EOF
START_DAEMON="true"
USBAUTO="false"
DEVICES="/dev/rfcomm0"
GPSD_OPTIONS="-n -G"
EOF

# --- 创建集成守护脚本 ---
echo "创建守护脚本..."
sudo tee $WATCHDOG_PATH <<EOF
#!/bin/bash
# 1. 检查并绑定蓝牙节点
if [ ! -e /dev/rfcomm0 ]; then
    rfcomm bind 0 $GPS_MAC
    sleep 2
fi

# 2. 检查物理连接，断开则重连
if ! hcitool con | grep -q "$GPS_MAC"; then
    rfcomm connect 0 $GPS_MAC &
    sleep 5
    systemctl restart gpsd
fi

# 3. 检查并启动 APRS 数据桥接 (7834端口)
if ! pgrep -f "socat - UDP-DATAGRAM:127.0.0.1:7834" > /dev/null; then
    (gpspipe -r | socat - UDP-DATAGRAM:127.0.0.1:7834) &
fi
EOF

sudo chmod +x $WATCHDOG_PATH

# --- 设置定时任务 ---
(crontab -l 2>/dev/null | grep -v "$WATCHDOG_PATH"; echo "* * * * * $WATCHDOG_PATH > /dev/null 2>&1") | crontab -

echo "安装完成！请记得在 Pi-Star 专家设置里开启 Mobile GPS (127.0.0.1:7834)。"
rpi-ro
