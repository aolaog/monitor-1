#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"
SYSLOG_NG_SERVER=$(ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |awk -F : '{print $2}')

SRC_DIR="/home/zoomi/op_system"

SYSLOG_NG_CFG_DIR="/etc/syslog-ng"
SYSLOG_NG_CFG_FILE="syslog-ng.conf"
SYSLOG_NG_TYPE="server"


CENTREON_SYSLOG_FRONTEND_VERSION="centreon-syslog-frontend-1.3.2"
CENTREON_SYSLOG_VERSION="centreon-syslog-server-1.2"

LINE="##########################################"

echo "$LINE"
echo
echo "Zoomi Syslog-NG Server Installation Script" 
echo
echo "                              version 1.0" 
echo 
echo "$LINE"
echo

read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
echo "DOWNLOAD_SERVER IP is $DL_SERVER."
echo

echo "$LINE"
echo "Section: Installing Syslog-ng server"
echo "$LINE"

	sudo apt-get install -y syslog-ng > /dev/null 2>&1
	cd $SYSLOG_NG_CFG_DIR

	TIME=`date +"%H%M%S"`

	sudo mv $SYSLOG_NG_CFG_FILE $SYSLOG_NG_CFG_FILE.$TIME
	sudo wget http://$DL_SERVER/$SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE > /dev/null 2>&1
	sudo mv $SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE $SYSLOG_NG_CFG_FILE
	sudo sed -i "s/syslog-ng-server/$SYSLOG_NG_SERVER/g" $SYSLOG_NG_CFG_FILE
	sudo service syslog-ng restart 
	echo ". Syslog-ng server installed. ok!"


echo "$LINE"
echo "Section: Installing Centreon Syslog"
echo "$LINE"
	
	[ ! -d $SRC_DIR ] && sudo mkdir -p $SRC_DIR
	cd $SRC_DIR
	sudo wget http://$DL_SERVER/$CENTREON_SYSLOG_VERSION.tar.gz > /dev/null 2>&1
	sudo tar xvfz $CENTREON_SYSLOG_VERSION.tar.gz > /dev/null 2>&1
	cd $CENTREON_SYSLOG_VERSION
	sudo ./install.sh -i
	echo ". Centreon Syslog installed. ok!"

echo "$LINE"
echo "Section: Installing Centreon Syslog Frontend"
echo "$LINE"

	sudo apt-get install libnet-ssh2-perl libssh2-1 libssh2-php > /dev/null 2>&1
	sudo service apache2 reload > /dev/null 2>&1
	
	cd /home/zoomi/op_system
	sudo wget http://$DL_SERVER/$CENTREON_SYSLOG_FRONTEND_VERSION.tar.gz > /dev/null 2>&1
	sudo tar xvfz $CENTREON_SYSLOG_FRONTEND_VERSION.tar.gz > /dev/null 2>&1
	cd $CENTREON_SYSLOG_FRONTEND_VERSION
	sudo ./install.sh -i
	echo ". Centreon Syslog Frontend installed. ok!"
	
	ipaddr=$(ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |awk -F : '{print $2}')
	echo "Please access http://$SYSLOG_NG_SERVER/centreon in Internet Explorer, next install."

echo

exit 0 
