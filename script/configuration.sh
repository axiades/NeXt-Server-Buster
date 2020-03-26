#!/bin/bash
#Please check the license provided with the script!

start_after_install() {

  trap error_exit ERR

  source /root/NeXt-Server-Buster/configs/sources.cfg

  check_nginx && continue_or_exit
  check_php && continue_or_exit
  check_openssh && continue_or_exit
  check_fail2ban && continue_or_exit
  check_unbound && continue_or_exit
  check_dovecot && continue_or_exit
  check_postfix && continue_or_exit
  check_rspamd && continue_or_exit
  check_lets_encrypt && continue_or_exit
  check_firewall && continue_or_exit
  check_mailserver && continue_or_exit
  check_system && continue_or_exit
  show_ssh_key && continue_or_exit

  dialog_msg "Please save the shown login information on next page"
  cat /root/NeXt-Server-Buster/login_information.txt && continue_or_exit

  create_private_key

  if [[ ${USE_MAILSERVER} = "1" ]]; then
    dialog_msg "Please enter the shown DKIM key on next page to you DNS settings \n\n
    remove all quote signs - so it looks like that:  \n\n
    v=DKIM1; k=rsa; p=MIIBIjANBgkqh[...] "
    cat /root/NeXt-Server-Buster/DKIM_KEY_ADD_TO_DNS.txt
    continue_or_exit
  fi

  dialog_msg "Finished after installation configuration"
}