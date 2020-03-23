#!/bin/bash
#Please check the license provided with the script!

dev_mode=/root/NeXt-Server-Buster/dev.conf
if [ -f "$dev_mode" ]; then
    sed -i "s/ec-384/ec-384 --staging/g" /root/NeXt-Server-Buster/script/lets_encrypt.sh
    sed -i "s/4096/4096 --staging/g" /root/NeXt-Server-Buster/script/mailserver.sh
    set -x
fi

source /root/NeXt-Server-Buster/configs/sources.cfg

install_start=`date +%s`

progress_gauge "0" "Checking your system..."
prerequisites
set_logs
setipaddrvars
check_system

confighelper_userconfig

mkdir /root/NeXt-Server-Buster/sources
progress_gauge "0" "Installing System..."
source /root/NeXt-Server-Buster/script/system.sh; install_system

progress_gauge "1" "Installing OpenSSL..."
source /root/NeXt-Server-Buster/script/openssl.sh; install_openssl

progress_gauge "31" "Installing OpenSSH..."
source /root/NeXt-Server-Buster/script/openssh.sh; install_openssh

progress_gauge "32" "Installing fail2ban..."
source /root/NeXt-Server-Buster/script/fail2ban.sh; install_fail2ban

progress_gauge "33" "Installing MariaDB..."
source /root/NeXt-Server-Buster/script/mariadb.sh; install_mariadb

progress_gauge "65" "Installing Let's Encrypt..."
source /root/NeXt-Server-Buster/script/lets_encrypt.sh; install_lets_encrypt
progress_gauge "75" "Installing Mailserver..."
source /root/NeXt-Server-Buster/script/unbound.sh; install_unbound
source /root/NeXt-Server-Buster/script/mailserver.sh; install_mailserver
source /root/NeXt-Server-Buster/script/dovecot.sh; install_dovecot
source /root/NeXt-Server-Buster/script/postfix.sh; install_postfix
source /root/NeXt-Server-Buster/script/rspamd.sh; install_rspamd
source /root/NeXt-Server-Buster/script/roundcube.sh; install_roundcube
source /root/NeXt-Server-Buster/script/managevmail.sh; install_managevmail
progress_gauge "96" "Installing Firewall..."
source /root/NeXt-Server-Buster/script/firewall.sh; install_firewall
install_end=`date +%s`
runtime=$((install_end-install_start))
sed -i 's/NXT_IS_INSTALLED_MAILSERVER="0"/NXT_IS_INSTALLED_MAILSERVER="1"/' /root/NeXt-Server-Buster/configs/userconfig.cfg
date=$(date +"%d-%m-%Y")
sed -i 's/NXT_INSTALL_DATE="0"/NXT_INSTALL_DATE="'${date}'"/' /root/NeXt-Server-Buster/configs/userconfig.cfg
sed -i 's/NXT_INSTALL_TIME_SECONDS="0"/NXT_INSTALL_TIME_SECONDS="'${runtime}'"/' /root/NeXt-Server-Buster/configs/userconfig.cfg
source /root/NeXt-Server-Buster/script/configuration.sh; start_after_install

progress_gauge "34" "Installing Nginx Addons..."
source /root/NeXt-Server-Buster/script/nginx_addons.sh; install_nginx_addons

progress_gauge "40" "Installing Nginx..."
source /root/NeXt-Server-Buster/script/nginx.sh; install_nginx

progress_gauge "65" "Installing Let's Encrypt..."
source /root/NeXt-Server-Buster/script/lets_encrypt.sh; install_lets_encrypt

progress_gauge "68" "Creating Let's Encrypt Certificate..."
source /root/NeXt-Server-Buster/script/lets_encrypt.sh; create_nginx_cert

progress_gauge "74" "Installing PHP..."
source /root/NeXt-Server-Buster/script/php7_3.sh; install_php_7_3

progress_gauge "75" "Installing Mailserver..."
if [[ ${USE_MAILSERVER} = "1" ]]; then
    source /root/NeXt-Server-Buster/script/unbound.sh; install_unbound
    source /root/NeXt-Server-Buster/script/mailserver.sh; install_mailserver
    source /root/NeXt-Server-Buster/script/dovecot.sh; install_dovecot
    source /root/NeXt-Server-Buster/script/postfix.sh; install_postfix
    source /root/NeXt-Server-Buster/script/rspamd.sh; install_rspamd
    source /root/NeXt-Server-Buster/script/roundcube.sh; install_roundcube
    source /root/NeXt-Server-Buster/script/managevmail.sh; install_managevmail
fi

progress_gauge "96" "Installing Firewall..."
source /root/NeXt-Server-Buster/script/firewall.sh; install_firewall
install_end=`date +%s`
runtime=$((install_end-install_start))

if [[ ${USE_MAILSERVER} = "1" ]]; then
    sed -i 's/NXT_IS_INSTALLED_MAILSERVER="0"/NXT_IS_INSTALLED_MAILSERVER="1"/' /root/NeXt-Server-Buster/configs/userconfig.cfg
else
    sed -i 's/NXT_IS_INSTALLED="0"/NXT_IS_INSTALLED="1"/' /root/NeXt-Server-Buster/configs/userconfig.cfg
fi

date=$(date +"%d-%m-%Y")
sed -i 's/NXT_INSTALL_DATE="0"/NXT_INSTALL_DATE="'${date}'"/' /root/NeXt-Server-Buster/configs/userconfig.cfg
sed -i 's/NXT_INSTALL_TIME_SECONDS="0"/NXT_INSTALL_TIME_SECONDS="'${runtime}'"/' /root/NeXt-Server-Buster/configs/userconfig.cfg

# Start Full Config after installation
source /root/NeXt-Server-Buster/script/configuration.sh; start_after_install