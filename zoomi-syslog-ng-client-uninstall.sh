#!/bin/bash

SYSLOG_NG_CFG_DIR="/etc/syslog-ng"
LINE="##########################################"

echo "$LINE"
echo "Section: Uninstalling Syslog-ng client"
echo "$LINE"
	
	sudo apt-get autoremove -y --purge syslog-ng > /dev/null 2>&1
	sudo rm -rf $SYSLOG_NG_CFG_DIR
	echo ". Syslog-ng client uninstalled. ok!"
echo

exit 0
