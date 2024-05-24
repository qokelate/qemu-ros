#!/bin/bash

#新建网桥
nmcli -g GENERAL.HWADDR device show br0 || \
nmcli connection add type bridge ifname br0 con-name br0

#关闭stp
nmcli connection modify br0 bridge.stp no

#设置IP
nmcli connection modify br0 ipv6.method disabled
nmcli connection modify br0 ipv4.method disabled

#生效
# nmcli device reapply br0
nmcli connection up br0
# ifconfig br0 up

# 查看当前连接
nmcli connection show

exit

