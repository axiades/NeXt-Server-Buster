#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

clear
echo "NeXt Server"
echo "Preparing menu..."

if [ $(dpkg-query -l | grep dialog | wc -l) -ne 3 ]; then
    apt -qq install dialog >/dev/null 2>&1
fi

exec > >(tee -a /root/NeXt-Server-Buster/logs/main.log)
exec 2> >(tee -a /root/NeXt-Server-Buster/logs/error.log)

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
GIT_LOCAL_FILES_HEAD_LAST_COMMIT=$(git log -1 --date=short --pretty=format:%cd)
source /root/NeXt-Server-Buster/configs/versions.cfg
source /root/NeXt-Server-Buster/configs/userconfig.cfg
source /root/NeXt-Server-Buster/script/functions.sh
source /root/NeXt-Server-Buster/script/logs.sh; set_logs
source /root/NeXt-Server-Buster/script/prerequisites.sh; prerequisites

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=8
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="\n Choose one of the following options: \n \n"

OPTIONS=(1 "Install NeXt Server Version: ${GIT_LOCAL_FILES_HEAD} - ${GIT_LOCAL_FILES_HEAD_LAST_COMMIT}"
         2 "After Installation configuration"
         3 "Update NeXt Server Installation"
         4 "Update NeXt Server Script Code Base"
         5 "Services Options"
         6 "Addon Installation"
         7 "Update Let's encrypt certificate"
         8 "Exit")

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
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    echo "The NeXt-Server Script is already installed!"
    source /root/NeXt-Server-Buster/script/functions.sh; continue_to_menu
else
    bash install.sh
fi
;;

2)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    source /root/NeXt-Server-Buster/menus/after_install_config_menu.sh; menu_options_after_install
else
    echo "Please install the NeXt-Server Script before starting the configuration!"
    source /root/NeXt-Server-Buster/script/functions.sh; continue_to_menu
fi
;;

3)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    source /root/NeXt-Server-Buster/updates/all-services-update.sh; update_all_services
else
    echo "You have to install the NeXt Server to run the services update!"
    source /root/NeXt-Server-Buster/script/functions.sh; continue_to_menu
fi
;;

4)
dialog_info "Updating NeXt Server Script"
source /root/NeXt-Server-Buster/update_script.sh; update_script
bash nxt.sh
;;

5)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    source /root/NeXt-Server-Buster/menus/services_menu.sh; menu_options_services
else
    echo "You have to install the NeXt Server to run the services options!"
    source /root/NeXt-Server-Buster/script/functions.sh; continue_to_menu
fi
;;

6)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
else
    echo "You have to install the NeXt Server to install addons!"
    source /root/NeXt-Server-Buster/script/functions.sh; continue_to_menu
fi
;;

7)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${NXT_IS_INSTALLED} == '1' ]] && [[ ${NXT_IS_INSTALLED_MAILSERVER} == '0' ]]; then
        source /root/NeXt-Server-Buster/script/lets_encrypt.sh; update_nginx_cert
        echo "Updated your Let's Encrypt Certificate!"
    fi
    if [[ ${NXT_IS_INSTALLED} == '1' ]] && [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
        source /root/NeXt-Server-Buster/script/lets_encrypt.sh; update_nginx_cert
        source /root/NeXt-Server-Buster/script/lets_encrypt.sh; update_mailserver_cert
        echo "Updated your Let's Encrypt Certificate!"
    fi
else
    echo "You have to install the NeXt Server to update  Let's Encrypt Certificate!"
    source /root/NeXt-Server-Buster/script/functions.sh; continue_to_menu
fi
;;

8)
echo "Exit"
exit
;;
esac