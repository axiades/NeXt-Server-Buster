#!/bin/bash
#Please check the license provided with the script!

deinstall_teamspeak3() {

trap error_exit ERR

/etc/init.d/ts3server stop
deluser ts3user
rm -rf /usr/local/ts3user
rm /root/NeXt-Server-Buster/teamspeak3_login_data.txt
rm /etc/init.d/ts3server

sed_replace_word "2008, " "" "/etc/arno-iptables-firewall/firewall.conf"
sed_replace_word "10011, " "" "/etc/arno-iptables-firewall/firewall.conf"
sed_replace_word "30033, " "" "/etc/arno-iptables-firewall/firewall.conf"
sed_replace_word "41144, " "" "/etc/arno-iptables-firewall/firewall.conf"

sed_replace_word "2010, " "" "/etc/arno-iptables-firewall/firewall.conf"
sed_replace_word "9987, " "" "/etc/arno-iptables-firewall/firewall.conf"

systemctl force-reload arno-iptables-firewall.service

sed_replace_word "TS3_IS_INSTALLED=\"1"\" "TS3_IS_INSTALLED=\"0"\" "/root/NeXt-Server-Buster/configs/userconfig.cfg"
}