#!/bin/bash
#Please check the license provided with the script!

install_phpmyadmin() {

trap error_exit ERR

source /root/NeXt-Server-Buster/configs/sources.cfg

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server-Buster/login_information.txt)

PMA_HTTPAUTH_USER=$(username)
MYSQL_PMADB_USER=$(username)
MYSQL_PMADB_NAME=$(username)
PMA_HTTPAUTH_PASS=$(password)
PMADB_PASS=$(password)
PMA_BFSECURE_PASS=$(password)

cd /var/www/${MYDOMAIN}/public/

wget_tar "https://github.com/phpmyadmin/phpmyadmin/archive/RELEASE_${PMA_VERSION}.zip"
unzip RELEASE_${PMA_VERSION}.zip -d /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}
rm RELEASE_${PMA_VERSION}.zip
cd /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}
mv phpmyadmin-RELEASE_${PMA_VERSION}/* .
composer update --no-dev

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${PMA_HTTPAUTH_USER} ${PMA_HTTPAUTH_PASS}

mkdir -p /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/{save,upload}
chmod 0700 /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/save
chmod g-s /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/save
chmod 0700 /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/upload
chmod g-s /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/upload
mysql -u root -p${MYSQL_ROOT_PASS} mysql < /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/sql/create_tables.sql

cp /root/NeXt-Server-Buster/configs/pma/config.inc.php /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/config.inc.php
sed_replace_word "PMA_BFSECURE_PASS" "${PMA_BFSECURE_PASS}" "/var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/config.inc.php"

cp /root/NeXt-Server-Buster/addons/vhosts/_phpmyadmin.conf /etc/nginx/_phpmyadmin.conf
sed_replace_word "#include _phpmyadmin.conf;" "include _phpmyadmin.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
sed_replace_word "change_path" "${PHPMYADMIN_PATH_NAME}" "/etc/nginx/_phpmyadmin.conf"
sed_replace_word "MYDOMAIN" "${MYDOMAIN}" "/etc/nginx/_phpmyadmin.conf"

chown -R www-data:www-data /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}/

systemctl -q restart php$PHPVERSION7-fpm.service
systemctl -q reload nginx.service

touch /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "phpmyadmin" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "PMA_HTTPAUTH_USER = ${PMA_HTTPAUTH_USER}" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "PMA_HTTPAUTH_PASS = ${PMA_HTTPAUTH_PASS}" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "MYSQL_USERNAME: root" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "MYSQL_ROOT_PASS: $MYSQL_ROOT_PASS" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "MYSQL_PMADB_USER = ${MYSQL_PMADB_USER}" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "MYSQL_PMADB_NAME = ${MYSQL_PMADB_NAME}" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "PMADB_PASS = ${PMADB_PASS}" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
echo "blowfish_secret = ${PMA_BFSECURE_PASS}" >> /root/NeXt-Server-Buster/phpmyadmin_login_data.txt

sed_replace_word "PMA_IS_INSTALLED="0"" "PMA_IS_INSTALLED="1"" "/root/NeXt-Server-Buster/configs/userconfig.cfg"
echo "${PHPMYADMIN_PATH_NAME}" >> /root/NeXt-Server-Buster/configs/blocked_paths.conf

dialog_msg "Please save the shown login information on next page"
cat /root/NeXt-Server-Buster/phpmyadmin_login_data.txt
continue_or_exit
}