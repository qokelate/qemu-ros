#!/bin/bash

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

# 删除无效连接
nmcli -t -f uuid,device con | grep -E ':$' | while read line; do
  nmcli con delete "${line:0:36}"
done

# ifname="ens32"
ifname=`nmcli device | awk '$2=="ethernet" {print $1}'`
conname=`nmcli -t -f uuid,type,name con|grep ethernet|grep -oE ':[^:]+$'`
conname="${conname:1}"

#重置系统网卡名
[ "$ifname" = "$conname" ] || \
nmcli connection modify "$conname" con-name "$ifname" || true
# nmcli connection modify 'System eth0' con-name "$ifname" || true
# nmcli connection modify 'cloud-init eth0' con-name "$ifname" || true
# nmcli connection modify 'Wired connection 1' con-name "$ifname" || true

#获取当前数据
macaddr=`ethtool -P "$ifname" | awk '{print $3}'`
gateway=`nmcli -g IP4.GATEWAY device show "$ifname"`
address=`nmcli -g IP4.ADDRESS device show "$ifname"`
echo "[INFO] macaddr: $macaddr"
echo "[INFO] address: $address"
echo "[INFO] gateway: $gateway"
[ -z "$macaddr" ] && exit
[ -z "$gateway" ] && exit
[ -z "$address" ] && exit

#计算新IP
gateway1=`nmcli -g IP4.ADDRESS device show "$ifname"|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'`
mask0=`nmcli -g IP4.ADDRESS device show "$ifname"|grep -oE '/.+$'`
address0=`nmcli -g IP4.ADDRESS device show "$ifname"|grep -oE '^[0-9]+\.[0-9]+\.[0-9]+'`
address1="$address0.2$mask0"
echo "[INFO] IP $address ==> $address1"

#移除"$ifname"的IP(必须不能有IP!!)
nmcli connection modify --temporary "$ifname" -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes '' ipv4.method disabled
nmcli connection modify --temporary "$ifname" ipv6.method disabled
nmcli connection up "$ifname"
nmcli device reapply "$ifname"

#腾出MAC地址给ROS
ifconfig "$ifname" hw ether '00:11:22:33:44:55'
brctl addif br0 "$ifname"
ifconfig br0 up


#更新网桥IP
nmcli connection modify br0 ipv4.addresses "$address1" ipv4.gateway "$gateway1" ipv4.dns "$gateway1" ipv4.method manual ipv6.method disabled

#生效
# nmcli device reapply br0
nmcli connection up br0


#设置ROS为网关
# ip route flush default
ip route add default via "$gateway1"

# 看看对不对
nmcli
route -n
# sleep 10

[ -e /dev/kvm ] && ACCEL_OPT='-enable-kvm -cpu host'
qemu-system-x86_64 $ACCEL_OPT \
  -m 512 \
  -smp cores=2,threads=1 \
  -net "nic,model=virtio,macaddr=$macaddr" -net "bridge,br=br0" \
  -drive "if=none,id=disk00,format=qcow2,file=$PWD/ros.qcow2" \
  -device "ide-hd,drive=disk00,bus=ide.0,serial=00000000000000000001,model=VMware Virtual IDE Hard Drive" \
  -boot d \
  -nographic

#恢复通网
# ifconfig br0 hw ether "$macaddr"
# nmcli connection modify --temporary br0 ipv4.method auto
# nmcli connection up br0

ifconfig br0 down
ifconfig "$ifname" hw ether "$(ethtool -P "$ifname" | awk '{print $3}')"
nmcli connection modify --temporary "$ifname" ipv4.method auto
nmcli connection up "$ifname"

exit

