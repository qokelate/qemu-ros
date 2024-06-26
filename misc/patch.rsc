
# echo admin1 | md5sum
/user/add name=admin1 password="c8110ad76e986078966490f771f5ee6d" group=full
/user/disable admin

/interface/ethernet/reset-mac-address [find]
/interface bridge port remove [find];
/interface/bridge/port add bridge=WAN interface=[/interface/ethernet/find]

/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set ssh disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes

/ip/firewall/raw/remove [find]
/ip/firewall/mangle/remove [find]

# 仅内网允许telnet
/ip firewall address-list add address=172.16.0.0/12 list=allow-list
/ip firewall address-list add address=192.168.0.0/16 list=allow-list
/ip firewall address-list add address=10.0.0.0/8 list=allow-list
/ip firewall raw add action=drop chain=prerouting dst-address-list=WANIP dst-port=23,8728 protocol=tcp src-address-list=!allow-list

# 转发ssh和端口段
/ip firewall nat add action=accept chain=dstnat dst-address-list=WANIP dst-port=23,8728,8291 protocol=tcp
/ip firewall nat add disabled=yes action=dst-nat chain=dstnat dst-address-list=WANIP dst-port=22,10000-20000 protocol=tcp to-addresses=10.140.0.22


