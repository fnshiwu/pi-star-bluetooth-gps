```bash
#!/bin/bash
# Pi-Star Bluetooth GPS & APRS Auto-Installer
# Author: BA4SMQ

rpi-rw

# 1. Install dependencies
# 安装必要依赖包
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install bluetooth bluez gpsd gpsd-clients socat tcpdump -y

# 2. Configure gpsd
# 配置 gpsd 服务
echo "Configuring gpsd..."
sudo tee /etc/default/gpsd <<EOF
START_DAEMON="true"
USBAUTO="false"
DEVICES="/dev/rfcomm0"
GPSD_OPTIONS="-n -G"
EOF

# 3. Create integrated watchdog script
# 创建集成守护脚本
echo "Creating watchdog script..."
sudo cat << 'EOF' > /usr/local/bin/gps_watchdog.sh
#!/bin/bash
GPS_MAC="00:02:76:C5:36:A0"

# Step 1: Check Bluetooth Binding
if [ ! -e /dev/rfcomm0 ]; then
    rfcomm bind 0 $GPS_MAC
    sleep 2
fi

# Step 2: Check Physical Connection
if ! hcitool con | grep -q "$GPS_MAC"; then
    rfcomm connect 0 $GPS_MAC &
    sleep 5
    systemctl restart gpsd
fi

# Step 3: Check Data Bridge (socat)
if ! pgrep -f "socat - UDP-DATAGRAM:127.0.0.1:7834" > /dev/null; then
    (gpspipe -r | socat - UDP-DATAGRAM:127.0.0.1:7834) &
fi
EOF

sudo chmod +x /usr/local/bin/gps_watchdog.sh

# 4. Set Crontab (Runs every minute)
# 设置定时任务（每分钟自检）
(crontab -l 2>/dev/null | grep -v "gps_watchdog.sh"; echo "* * * * * /usr/local/bin/gps_watchdog.sh > /dev/null 2>&1") | crontab -

echo "Installation Complete! Please pair your Bluetooth GPS manually."
rpi-ro
