#!/bin/bash

#新建网桥
nmcli connection show br0 || \
nmcli connection add type bridge ifname br0 con-name br0

#关闭stp
nmcli connection modify br0 bridge.stp no

#设置IP
nmcli connection modify br0 ipv6.method disabled
# nmcli connection modify br0 ipv4.method auto

#获取当前数据
macaddr=`nmcli -g GENERAL.HWADDR device show eth0|tr -d '\\\\'`
gateway=`nmcli -g IP4.GATEWAY device show eth0`
address=`nmcli -g IP4.ADDRESS device show eth0`

mask0=`nmcli -g IP4.ADDRESS device show eth0|grep -oE '/.+$'`
address0=`nmcli -g IP4.ADDRESS device show eth0|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+'`
address1="$address0.2$mask0"
echo "[INFO] IP $address ==> $address1"
nmcli connection modify br0 ipv4.addresses "$address1" ipv4.gateway "$gateway" ipv4.dns "$gateway" ipv4.method manual ipv6.method disabled

#生效
# nmcli device reapply br0
nmcli connection up br0

# 查看当前连接
nmcli connection show

exit

