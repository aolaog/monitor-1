#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"

SRC_DIR="/home/op_system"
SYSLOG_NG_INSTALL_FILE="syslog-ng-2.0.9-1.x86_64.rpm"
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

        [ ! -d $SRC_DIR ] && mkdir -p $SRC_DIR
	cd $SRC_DIR

	wget http://$SYSLOG_NG_CFG_DIR/$SYSLOG_NG_INSTALL_FILE > /dev/null 2>&1
        rpm -Uhv $SYSLOG_NG_INSTALL_FILE
	
	cd $SYSLOG_NG_CFG_DIR

	TIME=`date +"%H%M%S"`

	sudo mv $SYSLOG_NG_CFG_FILE $SYSLOG_NG_CFG_FILE.$TIME
	wget http://$DL_SERVER/$SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE syslog-ng > /dev/null 2>&1
	mv $SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE $SYSLOG_NG_CFG_FILE
	sed -i "s/syslog-ng-server/$CENTREON_SERVER/g" $SYSLOG_NG_CFG_FILE
	
	#sudo service syslog-ng restart 
	echo ". Syslog-ng client installed. ok!"

exit 0
