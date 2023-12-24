#!/bin/zsh

dnf install -y qemu-system-x86 qemu-img bridge-utils supervisor NetworkManager-tui

echo 'allow all'>/etc/qemu/bridge.conf

"$PWD/br0.sh"

cp -fv ros.ini /etc/supervisord.d/
systemctl enable supervisord

nmcli connection modify 'cloud-init eth0' con-name eth0

exit


