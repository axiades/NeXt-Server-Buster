#!/bin/bash
#Please check the license provided with the script!

install_postfix() {

trap error_exit ERR

install_packages "postfix postfix-mysql"

systemctl stop postfix

cd /etc/postfix
rm -r sasl
rm master.cf main.cf.proto master.cf.proto

cp /root/NeXt-Server-Buster/configs/postfix/main.cf /etc/postfix/main.cf
sed_replace_word "domain.tld" "${MYDOMAIN}" "/etc/postfix/main.cf"
IPADR=$(ip route get 1.1.1.1 | awk '/1.1.1.1/ {print $(NF-2)}')
sed_replace_word "changeme" "${IPADR}" "/etc/postfix/main.cf"

cp /root/NeXt-Server-Buster/configs/postfix/master.cf /etc/postfix/master.cf
cp /root/NeXt-Server-Buster/configs/postfix/submission_header_cleanup /etc/postfix/submission_header_cleanup

mkdir /etc/postfix/sql
cp -R /root/NeXt-Server-Buster/configs/postfix/sql/* /etc/postfix/sql/
sed_replace_word "placeholder" "${MAILSERVER_DB_PASS}" "/etc/postfix/sql/accounts.cf"
sed_replace_word "placeholder" "${MAILSERVER_DB_PASS}" "/etc/postfix/sql/aliases.cf"
sed_replace_word "placeholder" "${MAILSERVER_DB_PASS}" "/etc/postfix/sql/domains.cf"
sed_replace_word "placeholder" "${MAILSERVER_DB_PASS}" "/etc/postfix/sql/recipient-access.cf"
sed_replace_word "placeholder" "${MAILSERVER_DB_PASS}" "/etc/postfix/sql/sender-login-maps.cf"
sed_replace_word "placeholder" "${MAILSERVER_DB_PASS}" "/etc/postfix/sql/tls-policy.cf"
chmod -R 640 /etc/postfix/sql

touch /etc/postfix/without_ptr
touch /etc/postfix/postscreen_access

postmap /etc/postfix/without_ptr
newaliases
}
