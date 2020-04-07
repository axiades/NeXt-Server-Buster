#!/bin/bash
#Please check the license provided with the script!

install_teamspeak3() {

source /root/NeXt-Server-Buster/configs/sources.cfg

install_packages "sudo"

adduser ts3user --gecos "" --no-create-home --disabled-password
mkdir -p /usr/local/ts3user

cd /usr/local/ts3user
wget_tar "https://files.teamspeak-services.com/releases/server/${TEAMSPEAK_VERSION}/teamspeak3-server_linux_amd64-${TEAMSPEAK_VERSION}.tar.bz2"
tar -xjf teamspeak3-server_linux*.tar.bz2
mkdir -p /usr/local/ts3user/ts3server/
cp -r -u /usr/local/ts3user/teamspeak3-server_linux_amd64/* /usr/local/ts3user/ts3server/
rm -r /usr/local/ts3user/teamspeak3-server_linux_amd64/

touch /root/NeXt-Server-Buster/teamspeak3_login_data.txt
touch /usr/local/ts3user/ts3server/.ts3server_license_accepted
timeout 10 sudo -u  ts3user /usr/local/ts3user/ts3server/ts3server_minimal_runscript.sh > /root/NeXt-Server-Buster/teamspeak3_login_data.txt

cp /root/NeXt-Server-Buster/addons/configs/ts3server /etc/init.d/ts3server

chmod 755 /etc/init.d/ts3server
update-rc.d ts3server defaults
chown ts3user /usr/local/ts3user
chown -R ts3user /usr/local/ts3user/ts3server

/etc/init.d/ts3server start

TS3_PORTS_TCP="2008, 10011, 30033, 41144"
TS3_PORTS_UDP="2010, 9987"

sed -i "/\<$TS3_PORTS_TCP\>/ "\!"s/^OPEN_TCP=\"/&$TS3_PORTS_TCP, /" /etc/arno-iptables-firewall/firewall.conf
sed -i "/\<$TS3_PORTS_UDP\>/ "\!"s/^OPEN_UDP=\"/&$TS3_PORTS_UDP, /" /etc/arno-iptables-firewall/firewall.conf
sed -i '1171s/, "/"/' /etc/arno-iptables-firewall/firewall.conf

cat /root/NeXt-Server-Buster/addons/configs/ts3_ports.conf >> /root/NeXt-Server-Buster/configs/blocked_ports.conf

systemctl -q restart arno-iptables-firewall.service

echo "--------------------------------------------" >> /root/NeXt-Server-Buster/teamspeak3_login_data.txt
echo "Teamspeak 3" >> /root/NeXt-Server-Buster/teamspeak3_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Buster/teamspeak3_login_data.txt
echo "TS3 Server Login = Look at: ts3serverdata.txt in the NeXt-Server Folder" >> /root/NeXt-Server-Buster/teamspeak3_login_data.txt
echo "TS3 Server commands = /etc/init.d/ts3server start and /etc/init.d/ts3server stop" >> /root/NeXt-Server-Buster/teamspeak3_login_data.txt

sed_replace_word "TS3_IS_INSTALLED=\"0"\" "TS3_IS_INSTALLED=\"1"\" "/root/NeXt-Server-Buster/configs/userconfig.cfg"

dialog_msg "Please save the shown login information on next page"
cat /root/NeXt-Server-Buster/teamspeak3_login_data.txt
continue_or_exit
}