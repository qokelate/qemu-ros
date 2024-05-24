#!/bin/zsh

systemctl stop systemd-networkd.service
systemctl disable systemd-networkd.service
systemctl mask systemd-networkd.service
systemctl unmask NetworkManager
systemctl enable NetworkManager
systemctl restart NetworkManager

netplan apply

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
