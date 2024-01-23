#!/bin/bash

set -ex

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

#获取当前数据
macaddr=`nmcli -g GENERAL.HWADDR device show eth0|tr -d '\\'`
gateway=`nmcli -g IP4.GATEWAY device show eth0`
address=`nmcli -g IP4.ADDRESS device show eth0`

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

exit

