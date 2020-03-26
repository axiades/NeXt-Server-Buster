#!/bin/bash
#Please check the license provided with the script!

menu_options_services() {

source /root/NeXt-Server-Buster/configs/sources.cfg
set_logs

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=5
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

OPTIONS=(1 "Mailserver Options"
         2 "Openssh Options"
         3 "Firewall Options"
         4 "Back"
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
menu_options_mailserver
;;

2)
menu_options_openssh
;;

3)
menu_options_firewall
;;

4)
bash /root/NeXt-Server-Buster/nxt.sh
;;

5)
echo "Exit"
exit
;;
esac
}