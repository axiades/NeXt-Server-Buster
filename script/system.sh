#!/bin/bash
#Please check the license provided with the script!

install_system() {

trap error_exit ERR

source /root/Perfectrootserver/configs/sources.cfg

hostnamectl set-hostname --static mail

rm /etc/hosts
cat > /etc/hosts <<END
127.0.0.1   localhost
127.0.1.1   mail.domain.tld  mail

::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
END
sed_replace_word "domain.tld" "${MYDOMAIN}" "/etc/hosts"

echo $(hostname -f) > /etc/mailname

TIMEZONE_DETECTED=$(wget http://ip-api.com/line/${IPADR}?fields=timezone -q -O -)
timedatectl set-timezone ${TIMEZONE_DETECTED}

sed_replace_word "EMPTY_TIMEZONE" "${TIMEZONE_DETECTED}" "/root/Perfectrootserver/configs/userconfig.cfg"

rm /etc/apt/sources.list
cat > /etc/apt/sources.list <<END
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#

###### Ubuntu Main Repos
deb http://de.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse 
deb-src http://de.archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse 

###### Ubuntu Update Repos
deb http://de.archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse 
deb http://de.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse 
deb http://de.archive.ubuntu.com/ubuntu/ focal-proposed main restricted universe multiverse 
deb http://de.archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse 
deb-src http://de.archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse 
deb-src http://de.archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse 
deb-src http://de.archive.ubuntu.com/ubuntu/ focal-proposed main restricted universe multiverse 
deb-src http://de.archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse 
END

apt update -y >/dev/null 2>&1
apt -y upgrade >/dev/null 2>&1

install_packages "dirmngr software-properties-common sudo rkhunter debsecan debsums passwdqc unattended-upgrades needrestart apt-listchanges apache2-utils"
cp -f /root/Perfectrootserver/configs/needrestart.conf /etc/needrestart/needrestart.conf
cp -f /root/Perfectrootserver/configs/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
cp -f /root/Perfectrootserver/configs/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
sed_replace_word "email_address=root" "email_address=${NXT_SYSTEM_EMAIL}" "/etc/apt/listchanges.conf"
sed_replace_word "changeme" "${NXT_SYSTEM_EMAIL}" "/etc/apt/apt.conf.d/50unattended-upgrades"

#thanks to https://linuxacademy.com/howtoguides/posts/show/topic/19700-linux-security-and-server-hardening-part1
cat > /etc/sysctl.conf <<END
# Avoid a smurf attack
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Turn on protection for bad icmp error messages
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Turn on syncookies for SYN flood attack protection
net.ipv4.tcp_syncookies = 1

# Turn on and log spoofed, source routed, and redirect packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# No source routed packets here
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Turn on reverse path filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Make sure no one can alter the routing tables
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# Don't act as a router
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Turn on execshield for reducing worm or other automated remote attacks
kernel.randomize_va_space = 2

# Increase system file descriptor limit
fs.file-max = 65535

# Allow for more PIDs (Prevention of fork() failure error message)
kernel.pid_max = 65536

# Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000

# Tuning Linux network stack to increase TCP buffer size. Set the max OS send buffer size (wmem) and receive buffer size (rmem) to 12 MB for queues on all protocols.
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608

# set minimum size, initial size and max size
net.ipv4.tcp_rmem = 10240 87380 12582912
net.ipv4.tcp_wmem = 10240 87380 12582912

# Value to set for queue on the INPUT side when incoming packets are faster then the kernel process on them.
net.core.netdev_max_backlog = 5000

# For increasing transfer window, enable window scaling
net.ipv4.tcp_window_scaling = 1

###
kernel.core_uses_pid = 1
kernel.kptr_restrict = 2
kernel.sysrq = 0
net.ipv4.tcp_timestamps = 0
kernel.yama.ptrace_scope = 1
END

sysctl -p

cp -f /root/Perfectrootserver/cronjobs/webserver_backup /etc/cron.daily/
chmod +x /etc/cron.daily/webserver_backup

cp -f /root/Perfectrootserver/cronjobs/le_cert_alert /etc/cron.d/
sed_replace_word "changeme" "${NXT_SYSTEM_EMAIL}" "/etc/cron.d/le_cert_alert"

cp -f /root/Perfectrootserver/cronjobs/free_disk_space /etc/cron.daily/
sed_replace_word "changeme" "${NXT_SYSTEM_EMAIL}" "/etc/cron.daily/free_disk_space"
chmod +x /etc/cron.daily/free_disk_space
}
