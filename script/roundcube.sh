#!/bin/bash
#Please check the license provided with the script!

install_roundcube() {

trap error_exit ERR

ROUNDCUBE_USER=$(username)
ROUNDCUBE_DB_NAME=$(username)
ROUNDCUBE_DB_PASS=$(password)
ROUND_HTTPAUTH_USER=$(username)
ROUND_HTTPAUTH_PASS=$(password)
RANDOM_DESKEY=$(username)

cd /var/www/${MYDOMAIN}/public/
wget_tar "https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz"
tar_file "roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz"
mv /var/www/${MYDOMAIN}/public/roundcubemail-${ROUNDCUBE_VERSION} /var/www/${MYDOMAIN}/public/webmail

sudo chown -R www-data:www-data /var/www/${MYDOMAIN}/public/webmail
sudo chmod -R 775 /var/www/${MYDOMAIN}/public/webmail

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${ROUNDCUBE_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER '${ROUNDCUBE_USER}'@'localhost' IDENTIFIED BY '${ROUNDCUBE_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${ROUNDCUBE_DB_NAME}.* to '${ROUNDCUBE_USER}'@'localhost'"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /var/www/${MYDOMAIN}/public/webmail
mysql -u${ROUNDCUBE_USER} -p${ROUNDCUBE_DB_PASS} -h${MYSQL_HOSTNAME} ${ROUNDCUBE_DB_NAME} < /var/www/${MYDOMAIN}/public/webmail/SQL/mysql.initial.sql

htpasswd -b /etc/nginx/htpasswd/.htpasswd ${ROUND_HTTPAUTH_USER} ${ROUND_HTTPAUTH_PASS}

cp /root/NeXt-Server-Buster/configs/roundcube/config.inc.php /var/www/${MYDOMAIN}/public/webmail/config/config.inc.php
sed_replace_word "rcdbuser" "${ROUNDCUBE_USER}" "/var/www/${MYDOMAIN}/public/webmail/config/config.inc.php"
sed_replace_word "rcdbpassword" "${ROUNDCUBE_DB_PASS}" "/var/www/${MYDOMAIN}/public/webmail/config/config.inc.php"
sed_replace_word "rcdbname" "${ROUNDCUBE_DB_NAME}" "/var/www/${MYDOMAIN}/public/webmail/config/config.inc.php"
sed_replace_word "deskey" "${RANDOM_DESKEY}" "/var/www/${MYDOMAIN}/public/webmail/config/config.inc.php"

sudo rm -rf /var/www/nxtsrv.de/public/webmail/installer/

echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "Roundcube Webmail URL: https://${MYDOMAIN}/webmail/" >> /root/NeXt-Server-Buster/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "ROUND_HTTPAUTH_USER = ${ROUND_HTTPAUTH_USER}" >> /root/NeXt-Server-Buster/login_information.txt
echo "ROUND_HTTPAUTH_PASS = ${ROUND_HTTPAUTH_PASS}" >> /root/NeXt-Server-Buster/login_information.txt
echo "ROUNDCUBEDBUser = ${ROUNDCUBE_USER}" >> /root/NeXt-Server-Buster/login_information.txt
echo "ROUNDCUBEDBName = ${ROUNDCUBE_DB_NAME}" >> /root/NeXt-Server-Buster/login_information.txt
echo "ROUNDCUBEDBPassword = ${ROUNDCUBE_DB_PASS}" >> /root/NeXt-Server-Buster/login_information.txt
echo "DES_KEY = ${RANDOM_DESKEY}" >> /root/NeXt-Server-Buster/login_information.txt
echo "Disable the http auth?" >> /root/NeXt-Server-Buster/login_information.txt
echo "Open /etc/nginx/sites-available/${MYDOMAIN}.conf and delete the lines:" >> /root/NeXt-Server-Buster/login_information.txt
echo "location /webmail/ {" >> /root/NeXt-Server-Buster/login_information.txt
echo 'auth_basic "Restricted";' >> /root/NeXt-Server-Buster/login_information.txt
echo "}" >> /root/NeXt-Server-Buster/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "" >> /root/NeXt-Server-Buster/login_information.txt
}
