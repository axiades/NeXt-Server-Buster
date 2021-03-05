#!/bin/bash
#Please check the license provided with the script!

clear
echo "Perfectrootserver"
echo "Preparing menu..."

if [ $(dpkg-query -l | grep dialog | wc -l) -ne 3 ]; then
    apt -qq install dialog >/dev/null 2>&1
fi

source /root/Perfectrootserver/configs/sources.cfg

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=8
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="\n Choose one of the following options: \n \n"

OPTIONS=(1 "Install"
         2 "After Installation configuration"
         3 "Services Options"
         4 "Update Let's encrypt certificate"
         5 "Exit")

CHOICE=$(dialog --clear \
                --nocancel \
                --no-cancel \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
1)
if [[ ${IS_INSTALLED} == '1' ]] || [[ ${IS_INSTALLED_MAILSERVER} == '1' ]]; then
    echo "The Script is already installed!"
    continue_to_menu
else
    bash install.sh
fi
;;

2)
if [[ ${IS_INSTALLED} == '1' ]] || [[ ${IS_INSTALLED_MAILSERVER} == '1' ]]; then
    menu_options_after_install
else
    echo "Please install the Script before starting the configuration!"
    continue_to_menu
fi
;;

3)
if [[ ${IS_INSTALLED} == '1' ]] || [[ ${IS_INSTALLED_MAILSERVER} == '1' ]]; then
    menu_options_services
else
    echo "You have to install the Server to run the services options!"
    continue_to_menu
fi
;;

4)
if [[ ${IS_INSTALLED} == '1' ]] || [[ ${IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${IS_INSTALLED} == '1' ]] && [[ ${IS_INSTALLED_MAILSERVER} == '0' ]]; then
        update_nginx_cert
        echo "Updated your Let's Encrypt Certificate!"
    fi
    if [[ ${IS_INSTALLED} == '1' ]] && [[ ${IS_INSTALLED_MAILSERVER} == '1' ]]; then
        update_nginx_cert
        update_mailserver_cert
        echo "Updated your Let's Encrypt Certificate!"
    fi
else
    echo "You have to install the Server to update  Let's Encrypt Certificate!"
    continue_to_menu
fi
;;

5)
echo "Exit"
exit
;;
esac
