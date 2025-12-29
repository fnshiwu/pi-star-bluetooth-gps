#!/bin/bash
# Pi-Star Bluetooth GPS & APRS Auto-Installer
# Author: BA4SMQ

rpi-rw

# 1. 安装必要组件
sudo apt-get update
sudo apt-get install bluetooth bluez gpsd gpsd-clients socat tcpdump -y

# 2. 配置 gpsd
sudo tee /etc/default/gpsd <<EOF
START_DAEMON="true"
USBAUTO="false"
DEVICES="/dev/rfcomm0"
GPSD_OPTIONS="-n -G"
EOF

# 3. 创建守护脚本
sudo cat << 'EOF' > /usr/local/bin/gps_watchdog.sh
#!/bin/bash
GPS_MAC="00:02:76:C5:36:A0"

# 检查蓝牙绑定
if [ ! -e /dev/rfcomm0 ]; then
    rfcomm bind 0 $GPS_MAC
    sleep 2
fi

# 检查连接状态
if ! hcitool con | grep -q "$GPS_MAC"; then
    rfcomm connect 0 $GPS_MAC &
    sleep 5
    systemctl restart gpsd
fi

# 检查并启动 APRS 数据桥接 (7834端口)
if ! pgrep -f "socat - UDP-DATAGRAM:127.0.0.1:7834" > /dev/null; then
    (gpspipe -r | socat - UDP-DATAGRAM:127.0.0.1:7834) &
fi
EOF

sudo chmod +x /usr/local/bin/gps_watchdog.sh

# 4. 设置定时任务 (每分钟检查一次)
(crontab -l 2>/dev/null | grep -v "gps_watchdog.sh"; echo "* * * * * /usr/local/bin/gps_watchdog.sh > /dev/null 2>&1") | crontab -

echo "Installation Complete. Please configure Mobile GPS in Pi-Star Expert mode."
