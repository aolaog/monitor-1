#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"

SYSLOG_NG_CFG_DIR="/etc/syslog-ng"
SYSLOG_NG_CFG_FILE="syslog-ng.conf"
SYSLOG_NG_TYPE="client"

LINE="##########################################"

echo "$LINE"
echo
echo "Zoomi Syslog-NG Client Installation Script" 
echo
echo "                              version 1.0" 
echo 
echo "$LINE"
echo

read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
echo "DOWNLOAD_SERVER IP is $DL_SERVER."
echo

read -p "Please Input CENTREON_SERVER IP or Domain Name: " CENTREON_SERVER
echo "SYSLOG_NG_SERVER IP is $CENTREON_SERVER."
echo

LINE="##########################################"

echo "$LINE"
echo "Section: Installing Syslog-ng client"
echo "$LINE"

	sudo apt-get install -y syslog-ng > /dev/null 2>&1
	cd $SYSLOG_NG_CFG_DIR

	TIME=`date +"%H%M%S"`

	sudo mv $SYSLOG_NG_CFG_FILE $SYSLOG_NG_CFG_FILE.$TIME
	sudo wget http://$DL_SERVER/$SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE syslog-ng > /dev/null 2>&1
	sudo mv $SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE $SYSLOG_NG_CFG_FILE
	sudo sed -i "s/syslog-ng-server/$CENTREON_SERVER/g" $SYSLOG_NG_CFG_FILE
	sudo service syslog-ng restart 
	echo ". Syslog-ng client installed. ok!"

exit 0
