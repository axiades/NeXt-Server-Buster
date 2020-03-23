#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

start_after_install() {

  trap error_exit ERR

  source /root/NeXt-Server-Buster/script/functions.sh

  source /root/NeXt-Server-Buster/checks/nginx-check.sh; check_nginx && continue_or_exit
  source /root/NeXt-Server-Buster/checks/php-check.sh; check_php && continue_or_exit
  source /root/NeXt-Server-Buster/checks/openssh-check.sh; check_openssh && continue_or_exit
  source /root/NeXt-Server-Buster/checks/fail2ban-check.sh; check_fail2ban && continue_or_exit
  source /root/NeXt-Server-Buster/checks/unbound-check.sh; check_unbound && continue_or_exit
  source /root/NeXt-Server-Buster/checks/dovecot-check.sh; check_dovecot && continue_or_exit
  source /root/NeXt-Server-Buster/checks/postfix-check.sh; check_postfix && continue_or_exit
  source /root/NeXt-Server-Buster/checks/rspamd-check.sh; check_rspamd && continue_or_exit
  source /root/NeXt-Server-Buster/checks/lets_encrypt-check.sh; check_lets_encrypt && continue_or_exit
  source /root/NeXt-Server-Buster/checks/firewall-check.sh; check_firewall && continue_or_exit
  source /root/NeXt-Server-Buster/checks/mailserver-check.sh; check_mailserver && continue_or_exit
  source /root/NeXt-Server-Buster/checks/system-check.sh; check_system && continue_or_exit
  source /root/NeXt-Server-Buster/script/openssh_options.sh; show_ssh_key && continue_or_exit

  dialog_msg "Please save the shown login information on next page"
  cat /root/NeXt-Server-Buster/login_information.txt && continue_or_exit

  source /root/NeXt-Server-Buster/script/openssh_options.sh; create_private_key

  if [[ ${USE_MAILSERVER} = "1" ]]; then
    dialog_msg "Please enter the shown DKIM key on next page to you DNS settings \n\n
    remove all quote signs - so it looks like that:  \n\n
    v=DKIM1; k=rsa; p=MIIBIjANBgkqh[...] "
    cat /root/NeXt-Server-Buster/DKIM_KEY_ADD_TO_DNS.txt
    continue_or_exit
  fi

  dialog_msg "Finished after installation configuration"
}