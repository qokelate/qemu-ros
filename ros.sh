#!/bin/bash

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

sleep 10

#移除eth0的IP(必须不能有IP!!)
nmcli connection modify --temporary eth0 -ipv4.dns '' -ipv4.gateway '' -ipv4.addresses '' -ipv4.routes '' ipv4.method disabled
nmcli connection modify --temporary eth0 ipv6.method disabled
#nmcli connection up eth0
nmcli device reapply eth0

#腾出MAC地址给ROS
ifconfig eth0 hw ether 00:11:22:33:44:55
brctl addif br0 eth0
ifconfig br0 up

sleep 3

#设置ROS为网关
ip route flush default
ip route add default via 172.29.227.173

ACCEL_OPT='-enable-kvm -cpu host'

qemu-system-x86_64 \
  -m 512 \
  $ACCEL_OPT \
  -smp cores=2,threads=1 \
  -net nic,model=virtio,macaddr=00:16:3e:16:61:86 -net bridge,br=br0 \
  -net nic,model=virtio,macaddr=80:05:88:00:00:02 \
  -drive "if=none,id=disk00,format=qcow2,file=$PWD/ros.qcow2" \
  -device "ide-hd,drive=disk00,bus=ide.0,serial=00000000000000000001,model=VMware Virtual IDE Hard Drive" \
  -boot d \
  -nographic

exit

