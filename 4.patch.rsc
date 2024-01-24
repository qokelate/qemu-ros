
#重置网卡MAC地址
/system scheduler add name=reset-mac-address policy=read,write start-time=startup on-event="/interface/ethernet/reset-mac-address [find]"

#所有网卡加入WAN桥
/system script add dont-require-permissions=no name=reset-WAN-bridge policy=read,write source="/interface/ethernet/reset-mac-address [find];\r\
    \n\r\
    \n#/interface bridge port remove [find];\r\
    \n\r\
    \n:foreach id in=[/interface ethernet find disabled=no] do={\r\
    \n    :local ifname [/interface ethernet get \$id name];\r\
    \n    /log info message=\"[INFO] found ethernet: \$ifname\";\r\
    \n    /interface bridge port add bridge=\"WAN\" interface=\"\$ifname\";\r\
    \n    /log info message=\"[INFO] added to WAN: \$ifname\";\r\
    \n}\r\
    \n"
/system scheduler add interval=30s name=reset-WAN-bridge policy=read,write start-time=startup on-event="/system/script/run reset-WAN-bridge"
