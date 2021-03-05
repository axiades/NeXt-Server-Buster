#!/bin/bash
#Please check the license provided with the script!

menu_options_addons() {

source /root/Perfectrootserver/configs/sources.cfg
set_logs

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=12
BACKTITLE="Perfectrootserver"
TITLE="Perfectrootserver"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install TS3 Server"
         2 "Deinstall TS3 Server"
         3 "Install Composer"
         4 "Install phpmyadmin"
         5 "Deinstall phpmyadmin"
         6 "Back"
         7 "Exit")

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
    if [[ ${TS3_IS_INSTALLED} == '1' ]]; then
        echo "Teamspeak 3 is already installed!"
    else
        dialog_info "Installing Teamspeak 3"
        install_teamspeak3
        dialog_msg "Finished installing Teamspeak 3! Credentials: /root/Perfectrootserver/teamspeak3_login_data.txt"
    fi
else
    echo "You have to install the Server to run this Addon!"
fi
continue_or_exit
menu_options_addons
;;

2)
if [[ ${TS3_IS_INSTALLED} == '0' ]]; then
    echo "Teamspeak 3 is already deinstalled!"
else
    dialog_info "Deinstalling Teamspeak 3"
    deinstall_teamspeak3
    dialog_msg "Finished Deinstalling Teamspeak 3.\n
    Closed Ports TCP: 2008, 10011, 30033, 41144\n
    UDP: 2010, 9987\n
    If you need them, please reopen them manually!"
fi
continue_or_exit
menu_options_addons
;;

3)
if [[ ${IS_INSTALLED} == '1' ]] || [[ ${IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${COMPOSER_IS_INSTALLED} == '1' ]]; then
        echo "Composer is already installed!"
    else
        dialog_info "Installing Composer"
        install_composer
        dialog_msg "Finished installing Composer"
    fi
else
    echo "You have to install the Server with the Webserver component to run this Addon!"
fi
continue_or_exit
menu_options_addons
;;

4)
if [[ ${IS_INSTALLED} == '1' ]] || [[ ${IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${PMA_IS_INSTALLED} == '1' ]]; then
        echo "Phpmyadmin is already installed!"
    else
        menu_options_phpmyadmin
        if [[ ${COMPOSER_IS_INSTALLED} == '0' ]]; then
            install_composer
        fi
        install_phpmyadmin
        dialog_msg "Finished installing PHPmyadmin"
    fi
else
    echo "You have to install the Server with the Webserver component to run this Addon!"
fi
continue_or_exit
menu_options_addons
;;

5)
if [[ ${PMA_IS_INSTALLED} == '0' ]]; then
    echo "Phpmyadmin is already deinstalled!"
else
    dialog_info "Deinstalling PHPmyadmin"
    deinstall_phpmyadmin
    dialog_msg "Finished Deinstalling PHPmyadmin"
fi
continue_or_exit
menu_options_addons
;;

6)
bash /root/Perfectrootserver/prs.sh
;;

7)
echo "Exit"
exit 1
;;
esac
}
