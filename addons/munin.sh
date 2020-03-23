#!/bin/bash
#Please check the license provided with the script!

install_munin() {

trap error_exit ERR

install_packages "munin munin-node munin-plugins-extra"

MUNIN_HTTPAUTH_USER=$(username)
MUNIN_HTTPAUTH_PASS=$(password)
htpasswd -b /etc/nginx/htpasswd/.htpasswd ${MUNIN_HTTPAUTH_USER} ${MUNIN_HTTPAUTH_PASS}

cp /root/NeXt-Server-Buster/addons/vhosts/_munin.conf /etc/nginx/_munin.conf
sed -i "s/#include _munin.conf;/include _munin.conf;/g" /etc/nginx/sites-available/${MYDOMAIN}.conf

sed -i "s/localhost.localdomain/mail.${MYDOMAIN}/g" /etc/munin/munin.conf
sed -i "s/change_path/${MUNIN_PATH_NAME}/g" /etc/nginx/_munin.conf

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl -q restart munin-node 
systemctl -q restart nginx.service

touch /root/NeXt-Server-Buster/munin_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Buster/munin_login_data.txt
echo "Munin" >> /root/NeXt-Server-Buster/munin_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Buster/munin_login_data.txt
echo "Warning: It can take several minutes (or a restart), until the URL is working! (403 Error)" >> /root/NeXt-Server-Buster/munin_login_data.txt
echo "Munin Address: ${MYDOMAIN}/${MUNIN_PATH_NAME}/" >> /root/NeXt-Server-Buster/munin_login_data.txt
echo "MUNIN_HTTPAUTH_USER = ${MUNIN_HTTPAUTH_USER}" >> /root/NeXt-Server-Buster/munin_login_data.txt
echo "MUNIN_HTTPAUTH_PASS = ${MUNIN_HTTPAUTH_PASS}" >> /root/NeXt-Server-Buster/munin_login_data.txt

sed -i 's/MUNIN_IS_INSTALLED="0"/MUNIN_IS_INSTALLED="1"/' /root/NeXt-Server-Buster/configs/userconfig.cfg
echo "$MUNIN_PATH_NAME" >> /root/NeXt-Server-Buster/configs/blocked_paths.conf

dialog_msg "Please save the shown login information on next page"
cat /root/NeXt-Server-Buster/munin_login_data.txt
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
}