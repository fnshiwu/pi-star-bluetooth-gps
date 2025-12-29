Pi-Star 蓝牙 GPS (Nokia LD-3W) 自动集成与断线重连教程
本项目专门解决 Pi-Star 系统连接蓝牙 GPS 模块时遇到的三大问题：

系统不原生支持：通过 gpsd 桥接蓝牙数据。

重启失效：通过启动脚本自动绑定。

断线不重连：通过守护脚本（Watchdog）实现分钟级自动重连。

🛠️ 一键安装步骤
为了方便使用，建议直接运行自动化安装脚本。

1. 下载并运行安装脚本
在 Pi-Star 终端输入：

Bash

rpi-rw
wget https://raw.githubusercontent.com/fnshiwu/pi-star-bluetooth-gps/main/install.sh

sudo bash install.sh

2. 手动完成首次配对 (仅需一次)
脚本运行完成后，你需要手动授权蓝牙连接：

Bash

sudo bluetoothctl
# 进入蓝牙控制台后执行：
power on
scan on
# 确认找到 LD-3W 地址 (例如 00:02:xx:xx:xx:xx)
pair 00:02:xx:xx:xx:xx
trust 00:02:xx:xx:xx:xx
exit

📝 核心原理说明
如果你想手动配置或了解原理，请参考以下逻辑：

1. 自动重连守护脚本 (gps_watchdog.sh)
由于 rfcomm bind 只是逻辑绑定，一旦蓝牙模块关机或超出距离，连接就会中断。我们通过 Cron 每分钟执行一次以下脚本：

Bash

#!/bin/bash
# 检查设备节点是否存在，不存在则绑定
if [ ! -e /dev/rfcomm0 ]; then
    rfcomm bind 0 00:02:xx:xx:xx:xx
    sleep 2
fi

# 检查物理链路是否通畅
if ! hcitool con | grep -q "00:02:xx:xx:xx:xx"; then
    echo "GPS link down, reconnecting..."
    rfcomm connect 0 00:02:xx:xx:xx:xx &
    sleep 5
    systemctl restart gpsd
fi

2. 桥接服务配置 (/etc/default/gpsd)
为了防止 gpsd 干扰 MMDVM 的串口，必须禁用自动扫描：

DEVICES="/dev/rfcomm0"

GPSD_OPTIONS="-n -G"

USBAUTO="false"

📊 如何验证
验证连接状态
查看设备节点：ls -l /dev/rfcomm0

查看原始 NMEA 数据：cat /dev/rfcomm0（应看到 $GPRMC 等数据流）

查看坐标解析：cgps -s（应看到经纬度数值）

验证自动重连
运行 cgps 观察数据。

手动关闭 Nokia LD-3W 电源，数据将停止。

重新开启 LD-3W 电源。

无需操作，等待 1 分钟左右，守护脚本会自动恢复连接，cgps 重新显示数据。

⚠️ 注意事项
电源供应：蓝牙通信和 DMR 编解码对电压敏感，请务必使用 5V 3A 电源。

搜星环境：Nokia LD-3W 必须在窗边或户外才能完成定位（蓝灯/绿灯状态）。

静态坐标：由于部分 Pi-Star 内置的 MMDVMHost 未编译 GPS 插件，建议通过 cgps 获取坐标后手动填入 Pi-Star 的 Configuration 页面以实现 APRS 固定站坐标展示。

🔗 开源协议
本项目采用 MIT 协议。 BA4SMQ 整理发布。
