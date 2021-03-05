#!/bin/bash
#Please check the license provided with the script!

install_openssh() {

trap error_exit ERR

mkdir -p /etc/ssh
install_packages "libpam-dev openssh-server"

cp /root/Perfectrootserver/configs/sshd_config /etc/ssh/sshd_config
cp /root/Perfectrootserver/includes/issue /etc/issue
cp /root/Perfectrootserver/includes/issue.net /etc/issue.net

array=($(cat "/root/Perfectrootserver/configs/blocked_ports.conf"))
printf -v array_str -- ',,%q' "${array[@]}"
while true
do
RANDOM_SSH_PORT="$(($RANDOM % 1023))"
   if [[ "${array_str},," =~ ,,${RANDOM_SSH_PORT},, ]]; then
      echo "Random Openssh Port is used by the system, creating new one"
   else
      SSH_PORT="$RANDOM_SSH_PORT"
      break
   fi
done

sed_replace_word "^Port 22" "Port $SSH_PORT" "/etc/ssh/sshd_config"
echo "$SSH_PORT" >> /root/Perfectrootserver/configs/blocked_ports.conf

echo "#------------------------------------------------------------------------------#" >> /root/Perfectrootserver/login_information.txt
echo "#SSH_PORT: ${SSH_PORT}" >> /root/Perfectrootserver/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/Perfectrootserver/login_information.txt
echo "" >> /root/Perfectrootserver/login_information.txt

SSH_PASS=$(password)

echo "#------------------------------------------------------------------------------#" >> /root/Perfectrootserver/login_information.txt
echo "#SSH_PASS: ${SSH_PASS}" >> /root/Perfectrootserver/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/Perfectrootserver/login_information.txt
echo "" >> /root/Perfectrootserver/login_information.txt

ssh-keygen -f ~/ssh.key -t ed25519 -N ${SSH_PASS} 
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key /root/Perfectrootserver/ssh_privatekey.txt

groupadd ssh-user
usermod -a -G ssh-user root

truncate -s 0 /var/log/daemon.log
truncate -s 0 /var/log/syslog

systemctl -q restart ssh
}
