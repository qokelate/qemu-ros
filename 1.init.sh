#!/bin/bash

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

which apt && \
apt install -y qemu-system-x86 qemu-utils bridge-utils ethtool network-manager unzip net-tools && \
apt install -y supervisor

which dnf && \
dnf install -y qemu-system-x86 qemu-img bridge-utils supervisor NetworkManager-tui ethtool unzip

mkdir -pv '/etc/qemu'
echo 'allow all'>/etc/qemu/bridge.conf

cp -fv misc/ros.ini /etc/supervisord.d/
systemctl disable supervisord

[ '/data1/ros' = "$PWD" ] || ln -sfv "$PWD" '/data1/ros'

exit


