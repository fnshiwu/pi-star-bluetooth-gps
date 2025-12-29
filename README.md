# Pi-Star Bluetooth GPS & APRS Integration
# Pi-Star 蓝牙 GPS 与 APRS 实时轨迹集成

[English Guide](#english-guide) | [中文说明](#chinese-guide)

---

<div id="english-guide"></div>

## 🇬🇧 English Guide
This project integrates Bluetooth GPS (Nokia LD-3W) with Pi-Star for real-time APRS location reporting.

### 🚀 Quick Install
```bash
rpi-rw
wget [https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh](https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh)
chmod +x install.sh && sudo ./install.sh

⚙️ Pi-Star Configuration
Expert -> MMDVMHost -> [Mobile GPS]: Enable=1, Address=127.0.0.1, Port=7834.

[APRS]: Enable=1, Callsign=YourCall-9.

<div id="chinese-guide"></div>

🇨🇳 中文教程
本项目为 Pi-Star 提供蓝牙 GPS (Nokia LD-3W) 集成方案，支持实时 APRS 轨迹上报。

🚀 核心功能
自动重连：开机自动绑定蓝牙，掉线自动找回。

实时上报：将 GPS 坐标推送至 Pi-Star 内部 7834 端口。

📦 安装方法

rpi-rw
wget [https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh](https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh)
chmod +x install.sh && sudo ./install.sh

🛠️ 首次配对

sudo bluetoothctl
# power on -> scan on -> pair [MAC] -> trust [MAC] -> exit

Author: BA4SMQ | License: MIT
