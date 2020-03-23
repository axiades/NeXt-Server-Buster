#!/bin/bash
#Please check the license provided with the script!

install_fail2ban() {

trap error_exit ERR

install_packages "python"

mkdir -p /root/NeXt-Server-Buster/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"
cd /root/NeXt-Server-Buster/sources/${FAIL2BAN_VERSION}/ >>"${main_log}" 2>>"${err_log}"

wget_tar "https://codeload.github.com/fail2ban/fail2ban/tar.gz/${FAIL2BAN_VERSION}"
tar_file "${FAIL2BAN_VERSION}"
cd fail2ban-${FAIL2BAN_VERSION}

python setup.py -q install >>"${main_log}" 2>>"${err_log}"

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local >>"${main_log}" 2>>"${err_log}"
cp /root/NeXt-Server-Buster/configs/fail2ban/jail.local /etc/fail2ban/jail.local

cp files/debian-initd /etc/init.d/fail2ban >>"${main_log}" 2>>"${err_log}"
update-rc.d fail2ban defaults >>"${main_log}" 2>>"${err_log}"
systemctl -q start fail2ban

rm -R /root/NeXt-Server-Buster/sources/${FAIL2BAN_VERSION}
}