#!/bin/bash

# Pi-Star Bluetooth GPS 一键安装脚本 (Nokia LD-3W)
# Author: BA4SMQ
# Date: 2025-12-29

# 1. 确保系统处于写模式
rpi-rw

# 2. 定义变量 (请根据实际情况修改 MAC 地址)
GPS_MAC="00:02:76:C5:36:A0"
WATCHDOG_PATH="/usr/local/bin/gps_watchdog.sh"

echo "--- 开始安装 Pi-Star 蓝牙 GPS 驱动 ---"

# 3. 安装必要软件包
echo "步骤 1: 安装必要组件..."
sudo apt-get update
sudo apt-get install bluetooth bluez gpsd gpsd-clients -y

# 4. 配置 gpsd
echo "步骤 2: 配置 gpsd..."
sudo tee /etc/default/gpsd <<EOF
START_DAEMON="true"
USBAUTO="false"
DEVICES="/dev/rfcomm0"
GPSD_OPTIONS="-n -G"
EOF

# 5. 创建自动重连守护脚本
echo "步骤 3: 创建自动重连守护脚本..."
sudo tee $WATCHDOG_PATH <<EOF
#!/bin/bash
# 检查 rfcomm0 设备节点
if [ ! -e /dev/rfcomm0 ]; then
    rfcomm bind 0 $GPS_MAC
    sleep 2
fi

# 检查物理连接，若断开则尝试重连
if ! hcitool con | grep -q "$GPS_MAC"; then
    echo "GPS 断开，正在尝试重连..."
    rfcomm connect 0 $GPS_MAC &
    sleep 5
    systemctl restart gpsd
fi
EOF

# 赋予执行权限
sudo chmod +x $WATCHDOG_PATH

# 6. 设置定时任务 (每分钟检查一次)
echo "步骤 4: 设置定时任务..."
# 防止重复写入 cron
(crontab -l 2>/dev/null | grep -v "$WATCHDOG_PATH"; echo "* * * * * $WATCHDOG_PATH > /dev/null 2>&1") | crontab -

# 7. 引导用户进行首次配对
echo "------------------------------------------------"
echo "--- 核心环境安装完成！ ---"
echo "请按照以下步骤手动完成首次配对 (仅需一次):"
echo "1. 执行: sudo bluetoothctl"
echo "2. 在蓝牙提示符下输入:"
echo "   power on"
echo "   scan on"
echo "   (找到 LD-3W 地址后)"
echo "   pair $GPS_MAC"
echo "   trust $GPS_MAC"
echo "   exit"
echo "------------------------------------------------"
echo "配对完成后，守护脚本将在 1 分钟内自动建立连接。"

rpi-ro
