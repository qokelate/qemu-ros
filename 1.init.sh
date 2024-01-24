#!/bin/zsh

cd "$(dirname "$0")"
cd "$(realpath "$PWD")"

dnf install -y qemu-system-x86 qemu-img bridge-utils supervisor NetworkManager-tui

echo 'allow all'>/etc/qemu/bridge.conf

cp -fv ros.ini /etc/supervisord.d/
systemctl disable supervisord

[ '/data1/ros' = "$PWD" ] || ln -sfv "$PWD" '/data1/ros'

exit


