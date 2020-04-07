#!/bin/bash
#Please check the license provided with the script!

deinstall_phpmyadmin() {

trap error_exit ERR

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server-Buster/login_information.txt)
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS phpmyadmin;"

rm -rf /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}
rm /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
rm /etc/nginx/_phpmyadmin.conf

sed_replace_word "include _phpmyadmin.conf;" "#include _phpmyadmin.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl -q restart nginx.service

sed_replace_word "$PHPMYADMIN_PATH_NAME" "" "/root/NeXt-Server-Buster/configs/blocked_paths.conf"
sed_replace_word "PMA_IS_INSTALLED=\"1"\" "PMA_IS_INSTALLED=\"0"\" "/root/NeXt-Server-Buster/configs/userconfig.cfg"
}