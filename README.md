# Pi-Star Bluetooth GPS & APRS Integration
# Pi-Star 蓝牙 GPS 与 APRS 集成方案

[English Guide](#english-guide) | [中文说明](#chinese-guide)

---

<a name="english-guide"></a>
## 🇬🇧 English Guide

This project enables **Nokia LD-3W** Bluetooth GPS modules to provide real-time location data for Pi-Star hotspots via APRS.

### 🚀 Quick Installation
1. **Switch Pi-Star to Read-Write mode:**
   ```bash
   rpi-rw

```

2. **Download and run the script:**
```bash
wget https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh
chmod +x install.sh && sudo ./install.sh

```



### 🛠️ Manual Pairing (First time only)

```bash
sudo bluetoothctl
# Commands: power on -> scan on -> pair [MAC] -> trust [MAC] -> exit

```

### ⚙️ Pi-Star Expert Settings

* **MMDVMHost -> [Mobile GPS]**: Enable=1, Address=127.0.0.1, Port=7834
* **MMDVMHost -> [APRS]**: Enable=1, Callsign=YourCall-9

---

<a name="chinese-guide"></a>

## 🇨🇳 中文说明

本项目支持将 **Nokia LD-3W** 蓝牙 GPS 模块集成到 Pi-Star，实现实时 APRS 位置上报。

### 🚀 快速安装

1. **切换至读写模式：**
```bash
rpi-rw

```


2. **执行安装脚本：**
```bash
wget https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh
chmod +x install.sh && sudo ./install.sh

```



### 🛠️ 手动配对（仅限首次）

```bash
sudo bluetoothctl
# 依次输入: power on -> scan on -> pair [MAC地址] -> trust [MAC地址] -> exit

```

### ⚙️ Pi-Star 专家设置

* **MMDVMHost -> [Mobile GPS]**: Enable=1, Address=127.0.0.1, Port=7834
* **MMDVMHost -> [APRS]**: Enable=1, 设置呼号-9

### 📡 调试与验证

* **查看坐标**: `cgps -s`
* **监听数据流**: `sudo tcpdump -i lo udp port 7834 -X`

---

**Author / 作者**: BA4SMQ | **License / 授权**: MIT

```

---

### 2. 自动化脚本：`install.sh` (保持逻辑一致)

确保 `install.sh` 包含以下核心逻辑，特别是最后的 `socat` 转发部分：

```bash
#!/bin/bash
# Pi-Star Bluetooth GPS Auto-Installer by BA4SMQ
rpi-rw
sudo apt-get update
sudo apt-get install bluetooth bluez gpsd gpsd-clients socat tcpdump -y

# 写入守护脚本
sudo cat << 'EOF' > /usr/local/bin/gps_watchdog.sh
#!/bin/bash
GPS_MAC="00:02:76:C5:36:A0"
if [ ! -e /dev/rfcomm0 ]; then
    rfcomm bind 0 $GPS_MAC
    sleep 2
fi
if ! hcitool con | grep -q "$GPS_MAC"; then
    rfcomm connect 0 $GPS_MAC &
    sleep 5
    systemctl restart gpsd
fi
if ! pgrep -f "socat - UDP-DATAGRAM:127.0.0.1:7834" > /dev/null; then
    (gpspipe -r | socat - UDP-DATAGRAM:127.0.0.1:7834) &
fi
EOF

sudo chmod +x /usr/local/bin/gps_watchdog.sh
(crontab -l 2>/dev/null | grep -v "gps_watchdog.sh"; echo "* * * * * /usr/local/bin/gps_watchdog.sh > /dev/null 2>&1") | crontab -
echo "Installation Finished!"
rpi-ro

```

---

