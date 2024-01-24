
#重置网卡MAC地址
/system scheduler add name=reset-mac-address policy=read,write start-time=startup on-event="/interface/ethernet/reset-mac-address [find]"

#所有网卡加入WAN桥
/system scheduler add name=reset-WAN-bridge policy=read,write start-time=startup on-event="/interface bridge port remove [find];\r\
    \n:foreach id in=[/interface ethernet find] do={\r\
    \n    :local ifname [/interface ethernet get \$id default-name];\r\
    \n    /log info message=\"[INFO] found ethernet: \$ifname\";\r\
    \n    /interface bridge port add bridge=WAN interface=\"\$ifname\";\r\
    \n}"
