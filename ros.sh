#!/bin/bash

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

#重置系统网卡名
nmcli connection modify 'System eth0' con-name eth0
nmcli connection modify 'cloud-init eth0' con-name eth0

#获取当前数据
macaddr=`nmcli -g GENERAL.HWADDR device show eth0|tr -d '\\\\'`
gateway=`nmcli -g IP4.GATEWAY device show eth0`
address=`nmcli -g IP4.ADDRESS device show eth0`
echo "[INFO] macaddr: $macaddr"
echo "[INFO] address: $address"
echo "[INFO] gateway: $gateway"
[ -z "$macaddr" ] && exit
[ -z "$gateway" ] && exit
[ -z "$address" ] && exit

gateway1=`nmcli -g IP4.ADDRESS device show eth0|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'`
mask0=`nmcli -g IP4.ADDRESS device show eth0|grep -oE '/.+$'`
address0=`nmcli -g IP4.ADDRESS device show eth0|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+'`
address1="$address0.2$mask0"
echo "[INFO] IP $address ==> $address1"

sleep 10

#移除eth0的IP(必须不能有IP!!)
nmcli connection modify --temporary eth0 -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes '' ipv4.method disabled
nmcli connection modify --temporary eth0 ipv6.method disabled
nmcli connection up eth0
nmcli device reapply eth0

#腾出MAC地址给ROS
ifconfig eth0 hw ether '00:11:22:33:44:55'
brctl addif br0 eth0
ifconfig br0 up


#更新网桥IP
nmcli connection modify br0 ipv4.addresses "$address1" ipv4.gateway "$gateway1" ipv4.dns "$gateway1" ipv4.method manual ipv6.method disabled

#生效
# nmcli device reapply br0
nmcli connection up br0

sleep 3

#设置ROS为网关
# ip route flush default
ip route add default via "$gateway1"

[ -e /dev/kvm ] && ACCEL_OPT='-enable-kvm -cpu host'

qemu-system-x86_64 \
  -m 512 \
  $ACCEL_OPT \
  -smp cores=2,threads=1 \
  -net "nic,model=virtio,macaddr=$macaddr" -net "bridge,br=br0" \
  -net "nic,model=virtio,macaddr=80:05:88:00:00:02" \
  -drive "if=none,id=disk00,format=qcow2,file=$PWD/ros.qcow2" \
  -device "ide-hd,drive=disk00,bus=ide.0,serial=00000000000000000001,model=VMware Virtual IDE Hard Drive" \
  -boot d \
  -nographic

#恢复通网
ifconfig eth0 hw ether "$macaddr"
ifconfig br0 0

exit

