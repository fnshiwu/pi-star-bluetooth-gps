# Pi-Star 蓝牙 GPS 自动集成工具 (Nokia LD-3W)

本项目专为 Pi-Star 平台设计，用于解决 **Nokia LD-3W** 等蓝牙 GPS 模块在热点板上的三大痛点：
1. **系统不原生支持**：通过 `gpsd` 自动桥接蓝牙数据。
2. **重启失效**：开机自动执行设备绑定。
3. **断线不重连**：内置监控守护脚本，实现分钟级断线重连。

---

## 🚀 快速安装 (Quick Start)

请确保你的 Pi-Star 已经联网。在终端中依次执行以下三行命令：

```bash
rpi-rw
wget [https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh](https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh)
chmod +x install.sh && sudo ./install.sh
🛠️ 首次使用指南
1. 蓝牙配对 (仅需一次)
脚本运行完毕后，你需要手动授权蓝牙连接。请执行以下命令：

Bash

sudo bluetoothctl
进入蓝牙控制台后，依次输入：

power on

scan on

(找到 LD-3W 地址后，假设为 00:02:76:C5:36:A0)

pair 00:02:76:C5:36:A0 (提示 PIN 请输入 0000)

trust 00:02:76:C5:36:A0

exit

2. 验证数据
配对完成后，等待约 1 分钟，守护脚本会自动建立链路。你可以通过以下命令检查数据：

检查原始数据流：cat /dev/rfcomm0 (应看到 $GPRMC 报文滚动)

查看解析坐标：cgps -s (应看到 Latitude/Longitude 坐标信息)

📡 核心功能
自动重连 (Watchdog)：系统每分钟会检查一次蓝牙物理链路。如果 GPS 模块因为距离过远或临时关机导致断开，系统会在模块重新开启后 60 秒内自动恢复连接。

硬件保护：自动配置 gpsd，禁用 USB 自动扫描，防止干扰 MMDVM 热点板所使用的 /dev/ttyAMA0 串口。

卫星授时：即使在没有网络的环境下，系统也能通过蓝牙 GPS 模块获取精确的卫星时间。

⚠️ 注意事项
MAC 地址修改：若你的 GPS 模块地址不是 00:02:76:C5:36:A0，请修改 install.sh 中的 GPS_MAC 变量。

APRS 设置：由于 MMDVMHost 版本限制，建议通过 cgps 获取坐标后，手动填入 Pi-Star 的 Configuration 页面，以确保 APRS.fi 地图显示准确。

电源建议：开启蓝牙和 DMR 模式后功耗增加，建议使用至少 5V 3A 的优质电源。

📜 开源协议
MIT License - BA4SMQ 整理发布
