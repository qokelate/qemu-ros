#!/bin/zsh

dnf install -y qemu-system-x86 qemu-img bridge-utils supervisor NetworkManager-tui

echo 'allow all'>/etc/qemu/bridge.conf

nmcli connection modify 'System eth0' con-name eth0
nmcli connection modify 'cloud-init eth0' con-name eth0

cp -fv ros.ini /etc/supervisord.d/
systemctl disable supervisord

exit


