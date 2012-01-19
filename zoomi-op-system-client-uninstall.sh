#!/bin/bash

NAGIOS_DIR="/usr/local/nagios"
NRPE_INIT_FILE="nrpe"
INIT_DIR="/etc/init.d"

LINE="##########################################"

echo "$LINE"
echo "Section: Uninstall zoomi-op-system-client"
echo "$LINE"
	sudo userdel -r nagios
	sudo groupdel nagios
	sudo groupdel nagcmd
     	
	sudo rm -rf $NAGIOS_DIR	
	
	sudo service $NRPE_INIT_FILE stop > /dev/null 2>&1
	sudo update-rc.d -f $NRPE_INIT_FILE remove > /dev/null 2>&1
	sudo rm -rf $INIT_DIR/$NRPE_INIT_FILE
	
	echo ". zoomi-op-system-client uninstalled. ok!"
echo

exit 0
