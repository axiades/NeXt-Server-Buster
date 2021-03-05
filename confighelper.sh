#!/bin/bash
#Please check the license provided with the script!

confighelper_userconfig() {

# --- GLOBAL MENU VARIABLES ---
BACKTITLE="Perfectrootserver Installation"
TITLE="Perfectrootserver Installation"
HEIGHT=40
WIDTH=80

# --- MYDOMAIN ---
source /root/Perfectrootserver/configs/sources.cfg
get_domain
CHECK_DOMAIN_LENGTH=`echo -n ${DETECTED_DOMAIN} | wc -m`

if [[ $CHECK_DOMAIN_LENGTH > 1 ]]; then
CHOICE_HEIGHT=2
MENU="Is this the domain, you want to use? ${DETECTED_DOMAIN}:"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
1)
   MYDOMAIN=${DETECTED_DOMAIN}
;;
2)
while true
do
    MYDOMAIN=$(dialog --clear \
                      --backtitle "$BACKTITLE" \
                      --inputbox "Enter your Domain without http:// (exmaple.org):" \
                      $HEIGHT $WIDTH \
                      3>&1 1>&2 2>&3 3>&- \
                      )
    if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
        break
    else
        dialog_msg "[ERROR] Should we again practice how a Domain address looks?"
        dialog --clear
    fi
done
;;
esac
else
    dialog_msg "The Script wasn't able to recognize your Domain! \n \nHave you set the right DNS settings, or multiple Domains directing to the server IP? \n \nPlease enter it manually!"
    while true
    do
        MYDOMAIN=$(dialog --clear \
                          --backtitle "$BACKTITLE" \
                          --inputbox "Enter your Domain without http:// (exmaple.org):" \
                          $HEIGHT $WIDTH \
                          3>&1 1>&2 2>&3 3>&- \
                          )
        if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
            break
        else
            dialog_msg "[ERROR] Should we again practice how a Domain address looks?"
            dialog --clear
        fi
    done
fi

# --- DNS Check ---
server_ip=$(ip route get 1.1.1.1 | awk '/1.1.1.1/ {print $(NF-2)}')
sed_replace_word "server_ip" "$server_ip" "/root/Perfectrootserver/dns_settings.txt"
sed_replace_word "yourdomain.com" "$MYDOMAIN" "/root/Perfectrootserver/dns_settings.txt"
dialog --title "DNS Settings" --tab-correct --exit-label "ok" --textbox /root/Perfectrootserver/dns_settings.txt 50 200

BACKTITLE="Perfectrootserver Installation"
TITLE="Perfectrootserver Installation"
HEIGHT=15
WIDTH=70

CHOICE_HEIGHT=2
MENU="Have you set the DNS Settings 24-48 hours before running this Script?:"
OPTIONS=(1 "Yes"
         2 "No")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
1)
    ;;
2)
    dialog_msg "Sorry, you have to wait 24 - 48 hours, until the DNS system knows your settings!"
    exit
    ;;
esac

setipaddrvars
if [[ ${FQDNIP} != ${IPADR} ]]; then
    echo "${MYDOMAIN} (${FQDNIP}) does not resolve to the IP address of your server (${IPADR})"
    exit
fi

if [ ${CHECKRDNS} != mail.${MYDOMAIN} ] | [ ${CHECKRDNS} != mail.${MYDOMAIN}. ]; then
    echo "Your reverse DNS (${CHECKRDNS}) does not match the SMTP Banner. Please set your Reverse DNS to mail.$MYDOMAIN"
    exit
fi

# --- Mailserver ---
CHOICE_HEIGHT=2
MENU="Do you want to use the Mailserver?:"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
1)
    USE_MAILSERVER="1"
;;
2)
    USE_MAILSERVER="0"
    dialog_msg "If you don't install the Mailserver, we can't inform you, if your Let's Encrypt Certificate is expiring! \n\n
You have to renew it every 90 days by yourself! \n\n
You can change your choice at the end of the confighelper, if you select no restart the confighelper!"
;;
esac

PHPVERSION7="7.3"
NXT_SYSTEM_EMAIL="admin@${MYDOMAIN}"
CONFIG_COMPLETED="1"

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
rm -rf /root/Perfectrootserver/configs/userconfig.cfg
cat >> /root/Perfectrootserver/configs/userconfig.cfg <<END
#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
# This file was created on ${CURRENT_DATE} with NeXt Server Version ${GIT_LOCAL_FILES_HEAD}

CONFIG_COMPLETED="${CONFIG_COMPLETED}"
MYDOMAIN="${MYDOMAIN}"
USE_MAILSERVER="${USE_MAILSERVER}"
PHPVERSION7="${PHPVERSION7}"
HPKP1="1"
HPKP2="2"

SYSTEM_EMAIL="${NXT_SYSTEM_EMAIL}"
IS_INSTALLED="0"
IS_INSTALLED_MAILSERVER="0"
INSTALL_DATE="0"
INSTALL_TIME_SECONDS="0"

PMA_IS_INSTALLED="0"
COMPOSER_IS_INSTALLED="0"

PHPMYADMIN_PATH_NAME="0"
MYSQL_HOSTNAME="localhost"
TIMEZONE="EMPTY_TIMEZONE"

#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
END

dialog --title "Userconfig" --exit-label "ok" --textbox /root/Perfectrootserver/configs/userconfig.cfg 50 250
clear

CHOICE_HEIGHT=2
MENU="Settings correct?"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
1)
    #continue
;;
2)
    confighelper_userconfig
;;
esac
}
