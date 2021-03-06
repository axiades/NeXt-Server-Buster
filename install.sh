#!/bin/bash
#Please check the license provided with the script!

source /root/Perfectrootserver/configs/sources.cfg

dev_mode=/root/Perfectrootserver/dev.conf
if [ -f "$dev_mode" ]; then
    sed_replace_word "ec-384" "ec-384 --staging" "/root/Perfectrootserver/script/lets_encrypt.sh"
    sed_replace_word "4096" "4096 --staging" "/root/Perfectrootserver/script/mailserver.sh"
    set -x
fi

install_start=`date +%s`

progress_gauge "0" "Checking your system..."
set_logs
prerequisites
setipaddrvars
check_system_before_start

confighelper_userconfig

mkdir /root/Perfectrootserver/sources
progress_gauge "0" "Installing System..."
install_system

progress_gauge "1" "Installing OpenSSL..."
install_openssl

progress_gauge "31" "Installing OpenSSH..."
install_openssh

progress_gauge "32" "Installing fail2ban..."
install_fail2ban

progress_gauge "33" "Installing MariaDB..."
install_mariadb

progress_gauge "34" "Installing Nginx Addons..."
install_nginx_addons

progress_gauge "40" "Installing Nginx..."
install_nginx

progress_gauge "65" "Installing Let's Encrypt..."
install_lets_encrypt

progress_gauge "68" "Creating Let's Encrypt Certificate..."
create_nginx_cert

progress_gauge "74" "Installing PHP..."
install_php_7_4

progress_gauge "75" "Installing Mailserver..."
if [[ ${USE_MAILSERVER} = "1" ]]; then
    install_unbound
    install_mailserver
    install_dovecot
    install_postfix
    install_rspamd
    install_roundcube
    install_managevmail
fi

progress_gauge "96" "Installing Firewall..."
install_firewall

install_end=`date +%s`
runtime=$((install_end-install_start))

if [[ ${USE_MAILSERVER} = "1" ]]; then
    sed -i 's/IS_INSTALLED_MAILSERVER="0"/IS_INSTALLED_MAILSERVER="1"/' /root/Perfectrootserver/configs/userconfig.cfg
else
    sed -i 's/IS_INSTALLED="0"/IS_INSTALLED="1"/' /root/Perfectrootserver/configs/userconfig.cfg
fi

date=$(date +"%d-%m-%Y")
sed -i 's/INSTALL_DATE="0"/INSTALL_DATE="'${date}'"/' /root/Perfectrootserver/configs/userconfig.cfg
sed -i 's/INSTALL_TIME_SECONDS="0"/INSTALL_TIME_SECONDS="'${runtime}'"/' /root/Perfectrootserver/configs/userconfig.cfg

start_after_install
