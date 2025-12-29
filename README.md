# Pi-Star Bluetooth GPS Integration Guide (Nokia LD-3W)
# Pi-Star 蓝牙 GPS 自动集成工具 (Nokia LD-3W)

[English Guide](#english-guide) | [中文说明](#中文教程)

---

## English Guide

This project is designed for Pi-Star platforms to solve the pain points of using Bluetooth GPS modules (like Nokia LD-3W):
1. **No Native Support**: Bridging Bluetooth data via `gpsd`.
2. **Reset on Reboot**: Auto-binding RFCOMM device at boot.
3. **Connection Drops**: Built-in Watchdog script for auto-reconnection.

### 🚀 Quick Install

Ensure your Pi-Star is connected to the internet. Run these commands in your terminal:

```bash
rpi-rw
wget [https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh](https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh)
chmod +x install.sh && sudo ./install.sh
🛠️ First-Time Usage
1. Bluetooth Pairing
You need to manually authorize the device once. Run:

Bash

sudo bluetoothctl
# Inside the prompt:
power on
scan on
# Find your LD-3W MAC (e.g., 00:02:76:C5:36:A0)
pair 00:02:76:C5:36:A0
trust 00:02:76:C5:36:A0
exit
2. Verify Data
Wait about 1 minute for the watchdog to trigger.

Check raw data: cat /dev/rfcomm0

Check GPS fix: cgps -s

中文教程
本项目专为 Pi-Star 平台设计，用于解决 Nokia LD-3W 等蓝牙 GPS 模块在热点板上的三大痛点：

系统不原生支持：通过 gpsd 自动桥接蓝牙数据。

重启失效：开机自动执行设备绑定。

断线不重连：内置监控守护脚本，实现分钟级断线重连。

🚀 快速安装
请确保你的 Pi-Star 已经联网。在终端中依次执行以下三行命令：

Bash

rpi-rw
wget [https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh](https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh)
chmod +x install.sh && sudo ./install.sh
🛠️ 首次使用指南
1. 蓝牙配对 (仅需一次)
脚本运行完毕后，你需要手动授权蓝牙连接。请执行以下命令：

Bash

sudo bluetoothctl
# 进入交互模式后输入：
power on
scan on
# 找到 LD-3W 地址后进行配对 (例如 00:02:76:C5:36:A0)
pair 00:02:76:C5:36:A0
trust 00:02:76:C5:36:A0
exit
2. 验证数据
配对完成后，等待约 1 分钟，守护脚本（Watchdog）会自动建立链路。

检查原始数据流：cat /dev/rfcomm0 (应看到 $GPRMC 报文滚动)

查看解析坐标：cgps -s (应看到经纬度数值)

📡 Features / 核心功能
Auto-Reconnect (Watchdog): System checks the Bluetooth link every minute. If the GPS is turned off or out of range, it will reconnect automatically within 60 seconds of being back online.

Hardware Protection: Automatically configures gpsd to disable USB auto-scanning, preventing interference with the MMDVM modem on /dev/ttyAMA0.

Satellite Timing: Synchronizes Pi-Star system time via GPS even without an internet connection.

自动重连 (Watchdog)：系统每分钟检查一次链路。如果 GPS 掉线，系统会在其恢复后 60 秒内自动重连。

硬件保护：自动配置 gpsd 并禁用 USB 自动扫描，防止干扰热点板串口。

卫星授时：即使在无网环境下，系统也能通过 GPS 获取精确时间。

⚠️ Notes / 注意事项
MAC Address: If your MAC is not 00:02:76:C5:36:A0, edit GPS_MAC in install.sh.

APRS Setting: Due to MMDVMHost limitations, manual entry of coordinates in the Pi-Star Config page is recommended after obtaining them via cgps.

MAC 地址修改：若你的 MAC 地址不同，请修改 install.sh 中的 GPS_MAC 变量。

📜 License
MIT License - BA4SMQ ```
