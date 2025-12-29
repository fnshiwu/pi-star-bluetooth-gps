# Pi-Star Bluetooth GPS & APRS Integration Guide
# Pi-Star 蓝牙 GPS 与 APRS 集成指南

### 📝 Project Overview / 项目概述
This project enables **Nokia LD-3W** Bluetooth GPS modules to work with Pi-Star for real-time APRS location reporting.  
本项目使 **Nokia LD-3W** 蓝牙 GPS 模块能够与 Pi-Star 配合使用，实现实时 APRS 位置上报。

---

### 🚀 Quick Installation / 快速安装

**1. Switch Pi-Star to Read-Write mode:** **1. 将 Pi-Star 切换至读写模式：**
```bash
rpi-rw
2. Download and run the install script: 2. 下载并运行安装脚本：

wget https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh
chmod +x install.sh && sudo ./install.sh
🛠️ Manual Bluetooth Pairing / 手动蓝牙配对
After installation, you must pair your device once: 安装完成后，您必须进行一次手动配对（仅限首次）：

sudo bluetoothctl
# Inside the prompt, type these commands:
# 在提示符下，输入以下命令：
power on
scan on
# Find your MAC (e.g., 00:02:76:C5:36:A0) and pair:
# 找到您的 MAC 地址并配对：
pair 00:02:76:C5:36:A0
trust 00:02:76:C5:36:A0
exit
⚙️ Pi-Star Configuration / Pi-Star 配置步骤
1. Open Pi-Star Web Dashboard and go to "Expert" -> "MMDVMHost". 1. 打开 Pi-Star 控制面板，进入“Expert” -> “MMDVMHost”。

2. Configure [Mobile GPS] section: 2. 配置 [Mobile GPS] 部分：

Enable: 1

Address: 127.0.0.1

Port: 7834

3. Configure [APRS] section: 3. 配置 [APRS] 部分：

Enable: 1

Callsign: YourCallsign-9 (e.g., BA4SMQ-9)

Interval: 60

4. Click "Apply Changes". 4. 点击“应用设置”。

📡 Verification & Debugging / 验证与调试
Check if coordinates are received: 检查是否收到坐标：
cgps -s

Monitor the data stream (Look for hex data): 监听数据流（观察是否有十六进制数据跳动）：
sudo tcpdump -i lo udp port 7834 -X
