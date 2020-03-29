#!/bin/bash
#Please check the license provided with the script!

install_rspamd() {

trap error_exit ERR

install_packages "rspamd"
systemctl stop rspamd

cp /root/NeXt-Server-Buster/configs/rspamd/options.inc /etc/rspamd/local.d/options.inc
cp /root/NeXt-Server-Buster/configs/rspamd/worker-normal.inc /etc/rspamd/local.d/worker-normal.inc
cp /root/NeXt-Server-Buster/configs/rspamd/classifier-bayes.conf /etc/rspamd/local.d/classifier-bayes.conf

RSPAMADM_PASSWORT=$(password)

echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "RSPAMADM URL: https://${MYDOMAIN}/rspamd/" >> /root/NeXt-Server-Buster/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "" >> /root/NeXt-Server-Buster/login_information.txt

echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "RSPAMADM_PASSWORT: $RSPAMADM_PASSWORT" >> /root/NeXt-Server-Buster/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "" >> /root/NeXt-Server-Buster/login_information.txt

RSPAMADM_PASSWORT_HASH=$(rspamadm pw -p ${RSPAMADM_PASSWORT})

grep 'sse3\|pni' /proc/cpuinfo > /dev/null
if [ $? -eq 0 ];  then
cat > /etc/rspamd/local.d/worker-controller.inc <<END
password = "${RSPAMADM_PASSWORT_HASH}";
END

else

cat > /etc/rspamd/local.d/worker-controller.inc <<END
password = "${RSPAMADM_PASSWORT_HASH}";
END

sed -i '1d' /etc/rspamd/local.d/worker-controller.inc
hash_temp=$(</etc/rspamd/local.d/worker-controller.inc)

new_file='password = "'
rm /etc/rspamd/local.d/worker-controller.inc

cat > /etc/rspamd/local.d/worker-controller.inc <<END
$new_file$hash_temp
END
fi

cp /root/NeXt-Server-Buster/configs/rspamd/worker-proxy.inc /etc/rspamd/local.d/worker-proxy.inc
cp /root/NeXt-Server-Buster/configs/rspamd/logging.inc /etc/rspamd/local.d/logging.inc
cp /root/NeXt-Server-Buster/configs/rspamd/milter_headers.conf /etc/rspamd/local.d/milter_headers.conf

CURRENT_YEAR=$(date +'%Y')

mkdir /var/lib/rspamd/dkim/
rspamadm dkim_keygen -b 2048 -s ${CURRENT_YEAR} -k /var/lib/rspamd/dkim/${CURRENT_YEAR}.key > /var/lib/rspamd/dkim/${CURRENT_YEAR}.txt
chown -R _rspamd:_rspamd /var/lib/rspamd/dkim
chmod 440 /var/lib/rspamd/dkim/*
cp /var/lib/rspamd/dkim/${CURRENT_YEAR}.txt /root/NeXt-Server-Buster/DKIM_KEY_ADD_TO_DNS.txt

cp /root/NeXt-Server-Buster/configs/rspamd/dkim_signing.conf /etc/rspamd/local.d/dkim_signing.conf
sed_replace_word "placeholder" "${CURRENT_YEAR}" "/etc/rspamd/local.d/dkim_signing.conf"

cp -R /etc/rspamd/local.d/dkim_signing.conf /etc/rspamd/local.d/arc.conf

install_packages "redis-server"

cp /root/NeXt-Server-Buster/configs/rspamd/redis.conf /etc/rspamd/local.d/redis.conf

REDIS_PASSWORT=$(password)
sed_replace_word "# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52" "rename-command CONFIG ${REDIS_PASSWORT}" "/etc/redis/redis.conf"

echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "Redis Password: ${REDIS_PASSWORT}" >> /root/NeXt-Server-Buster/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Buster/login_information.txt
echo "" >> /root/NeXt-Server-Buster/login_information.txt

cp /root/NeXt-Server-Buster/configs/mailserver/_rspamd.conf /etc/nginx/_rspamd.conf
sed_replace_word "#include _rspamd.conf;" "include _rspamd.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"

systemctl restart redis-server
systemctl restart nginx
systemctl start rspamd
systemctl start dovecot
systemctl start postfix
}