#!/bin/bash
#Please check the license provided with the script!

install_managevmail() {

trap error_exit ERR

install_packages "python3 libprotobuf17 python3-protobuf"

wget http://ftp.de.debian.org/debian/pool/main/m/mysql-connector-python/python3-mysql.connector_${MYSQL_CONNECTOR}_all.deb
if [[ $? -ne 0 ]]; then
    CON_DL_FAILED="1"
else
	CON_DL_FAILED="0"
fi

if [[ ${CON_DL_FAILED} = "1" ]]; then
	dpkg -i /root/NeXt-Server-Buster/includes/python3-mysql.connector_${MYSQL_CONNECTOR_LOCAL}_all.deb
else
	dpkg -i python3-mysql.connector_${MYSQL_CONNECTOR}_all.deb
fi

mkdir -p /etc/managevmail/
wget https://codeload.github.com/mhthies/managevmail/zip/master 
unzip master -d /etc/managevmail/ 
mv /etc/managevmail/managevmail-master/* /etc/managevmail/
rm -R /etc/managevmail/managevmail-master

MAILSERVER_MANAGEVMAIL_PASS=$(password)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER managevmail@localhost IDENTIFIED BY '${MAILSERVER_MANAGEVMAIL_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT SELECT, UPDATE, INSERT, DELETE ON vmail.* TO managevmail@localhost;"

sed_replace_word "?" "${MAILSERVER_MANAGEVMAIL_PASS}" "/etc/managevmail/config.ini"

echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "MAILSERVER_MANAGEVMAIL_PASS: $MAILSERVER_MANAGEVMAIL_PASS" >> /root/NeXt-Server-Buster/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "" >> /root/NeXt-Server-Buster/login_information.txt
}
