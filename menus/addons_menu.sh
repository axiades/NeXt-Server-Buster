#!/bin/bash
#Please check the license provided with the script!
#-------------------------------------------------------------------------------------------------------------

menu_options_addons() {

source /root/NeXt-Server-Buster/configs/versions.cfg
source /root/NeXt-Server-Buster/script/functions.sh
source /root/NeXt-Server-Buster/script/logs.sh; set_logs
source /root/NeXt-Server-Buster/configs/userconfig.cfg

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=12
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install TS3 Server"
         2 "Deinstall TS3 Server"
         3 "Install Composer"
         4 "Install Nextcloud"
         5 "Deinstall Nextcloud"
         6 "Install phpmyadmin"
         7 "Deinstall phpmyadmin"
         8 "Install Munin"
         9 "Install Wordpress"
         10 "Deinstall Wordpress"
         11 "Back"
         12 "Exit")

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
    if [[ ${TS3_IS_INSTALLED} == '1' ]]; then
        echo "Teamspeak 3 is already installed!"
    else
        dialog_info "Installing Teamspeak 3"
        source /root/NeXt-Server-Buster/addons/teamspeak3.sh; install_teamspeak3
        dialog_msg "Finished installing Teamspeak 3! Credentials: /root/NeXt-Server-Buster/teamspeak3_login_data.txt"
    fi
else
    echo "You have to install the NeXt Server to run this Addon!"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

2)
if [[ ${TS3_IS_INSTALLED} == '0' ]]; then
    echo "Teamspeak 3 is already deinstalled!"
else
    dialog_info "Deinstalling Teamspeak 3"
    source /root/NeXt-Server-Buster/addons/teamspeak3_deinstall.sh; deinstall_teamspeak3
    dialog_msg "Finished Deinstalling Teamspeak 3.\n
    Closed Ports TCP: 2008, 10011, 30033, 41144\n
    UDP: 2010, 9987\n
    If you need them, please reopen them manually!"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

3)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${COMPOSER_IS_INSTALLED} == '1' ]]; then
        echo "Composer is already installed!"
    else
        dialog_info "Installing Composer"
        source /root/NeXt-Server-Buster/addons/composer.sh; install_composer
        dialog_msg "Finished installing Composer"
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

4)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${NEXTCLOUD_IS_INSTALLED} == '1' ]]; then
        echo "Nextcloud is already installed!"
    else
        source /root/NeXt-Server-Buster/menus/nextcloud_menu.sh; menu_options_nextcloud
        source /root/NeXt-Server-Buster/addons/nextcloud.sh; install_nextcloud
        dialog --title "Your Nextcloud logininformations" --tab-correct --exit-label "ok" --textbox /root/NeXt-Server-Buster/nextcloud_login_data.txt 50 200
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

5)
if [[ ${NEXTCLOUD_IS_INSTALLED} == '0' ]]; then
    echo "Nextcloud is already deinstalled!"
else
    dialog_info "Deinstalling Nextcloud"
    source /root/NeXt-Server-Buster/addons/nextcloud_deinstall.sh; deinstall_nextcloud
    dialog_msg "Finished Deinstalling Nextcloud"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

6)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${PMA_IS_INSTALLED} == '1' ]]; then
        echo "Phpmyadmin is already installed!"
    else
        source /root/NeXt-Server-Buster/menus/phpmyadmin_menu.sh; menu_options_phpmyadmin
        if [[ ${COMPOSER_IS_INSTALLED} == '0' ]]; then
            source /root/NeXt-Server-Buster/addons/composer.sh; install_composer
        fi
        source /root/NeXt-Server-Buster/addons/phpmyadmin.sh; install_phpmyadmin
        dialog_msg "Finished installing PHPmyadmin"
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

7)
if [[ ${PMA_IS_INSTALLED} == '0' ]]; then
    echo "Phpmyadmin is already deinstalled!"
else
    dialog_info "Deinstalling PHPmyadmin"
    source /root/NeXt-Server-Buster/addons/phpmyadmin_deinstall.sh; deinstall_phpmyadmin
    dialog_msg "Finished Deinstalling PHPmyadmin"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

8)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${MUNIN_IS_INSTALLED} == '1' ]]; then
        echo "Munin is already installed!"
    else
        dialog_info "Installing Munin"
        source /root/NeXt-Server-Buster/menus/munin_menu.sh; menu_options_munin
        source /root/NeXt-Server-Buster/addons/munin.sh; install_munin
        dialog_msg "Finished installing Munin"
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

9)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${WORDPRESS_IS_INSTALLED} == '1' ]]; then
        echo "Wordpress is already installed!"
    else
        source /root/NeXt-Server-Buster/menus/wordpress_menu.sh; menu_options_wordpress
        source /root/NeXt-Server-Buster/addons/wordpress.sh; install_wordpress
        if [ "${WORDPRESS_PATH_NAME}" != "root" ]; then
           dialog_msg "Visit ${MYDOMAIN}/${WORDPRESS_PATH_NAME} to finish the installation"
        else
           dialog_msg "Visit ${MYDOMAIN}/ to finish the installation"
        fi
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

10)
if [[ ${WORDPRESS_IS_INSTALLED} == '0' ]]; then
    echo "Wordpress is already deinstalled!"
else
    dialog_info "Deinstalling Wordpress"
    source /root/NeXt-Server-Buster/addons/wordpress_deinstall.sh; deinstall_wordpress
    dialog_msg "Finished Deinstalling Wordpress"
fi
source /root/NeXt-Server-Buster/script/functions.sh; continue_or_exit
source /root/NeXt-Server-Buster/menus/addons_menu.sh; menu_options_addons
;;

11)
bash /root/NeXt-Server-Buster/nxt.sh
;;

12)
echo "Exit"
exit 1
;;
esac
}