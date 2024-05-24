#!/bin/bash

set -ex

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

# ifname="ens32"
ifname=`nmcli device | awk '$2=="ethernet" {print $1}'`
conname=`nmcli device | awk '$2=="ethernet" {print $4}'`

#重置系统网卡名
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

sleep 10

[ -e /dev/kvm ] && ACCEL_OPT='-enable-kvm -cpu host'
qemu-system-x86_64 $ACCEL_OPT \
  -m 512 \
  -smp cores=2,threads=1 \
  -net "nic,model=virtio,macaddr=$macaddr" -net "bridge,br=br0" \
  -drive "if=none,id=disk00,format=qcow2,file=$PWD/ros.qcow2" \
  -device "ide-hd,drive=disk00,bus=ide.0,serial=00000000000000000001,model=VMware Virtual IDE Hard Drive" \
  -boot d \
  -nographic

exit

