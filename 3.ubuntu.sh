#!/bin/bash

apt install -y network-manager || exit

rm -rf /etc/netplan
mkdir -pv /etc/netplan
cat <<EOF >/etc/netplan/99-netcfg.yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    alleths:
      dhcp4: true
      dhcp6: false
EOF

systemctl stop systemd-networkd.service
systemctl disable systemd-networkd.service
systemctl mask systemd-networkd.service
systemctl unmask NetworkManager
systemctl enable NetworkManager
systemctl restart NetworkManager

# 删除无效连接
nmcli -t -f uuid,device con | grep -E ':$' | while read line; do
  nmcli con delete "${line:0:36}"
done

#生效
# nmcli device reapply br0
nmcli connection up br0
# ifconfig br0 up

# 查看当前连接
nmcli connection show

exit


https://github.com/cockpit-project/cockpit/issues/15972

I solved this by using this configuration of my /etc/netplan/*.yaml file:

# This is the network config written by 'subiquity'
# Added NetworkManager renderer to allow for cockpit network management.
network:
  renderer: NetworkManager
  ethernets:
    eno1:
      dhcp4: true
    eno2:
      dhcp4: true
    ens6:
      dhcp4: true
    ens6d1:
      dhcp4: true
  version: 2
