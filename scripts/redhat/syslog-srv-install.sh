#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"
SYSLOG_NG_SERVER=$(ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |awk -F : '{print $2}')

SRC_DIR="/home/op_system"

SYSLOG_NG_INSTALL_FILE="syslog-ng-2.0.9-1.x86_64.rpm"
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

	[ ! -d $SRC_DIR ] && mkdir -p $SRC_DIR
	cd $SRC_DIR

	wget http://$DL_SERVER/$SYSLOG_NG_INSTALL_FILE > /dev/null 2>&1
        rpm -Uhv $SYSLOG_NG_INSTALL_FILE
	
	cd $SYSLOG_NG_CFG_DIR
	TIME=`date +"%H%M%S"`

	mv $SYSLOG_NG_CFG_FILE $SYSLOG_NG_CFG_FILE.$TIME
	wget http://$DL_SERVER/$SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE > /dev/null 2>&1
	mv $SYSLOG_NG_CFG_FILE.$SYSLOG_NG_TYPE $SYSLOG_NG_CFG_FILE
	sed -i "s/syslog-ng-server/$SYSLOG_NG_SERVER/g" $SYSLOG_NG_CFG_FILE
	service syslog-ng restart 
	echo ". Syslog-ng server installed. ok!"

echo "$LINE"
echo "Section: Installing Centreon Syslog"
echo "$LINE"
	
	[ ! -d $SRC_DIR ] && sudo mkdir -p $SRC_DIR
	cd $SRC_DIR
	wget http://$DL_SERVER/$CENTREON_SYSLOG_VERSION.tar.gz > /dev/null 2>&1
	tar xvfz $CENTREON_SYSLOG_VERSION.tar.gz > /dev/null 2>&1
	cd $CENTREON_SYSLOG_VERSION
	./install.sh -i
	". Centreon Syslog installed. ok!"

echo "$LINE"
echo "Section: Installing Centreon Syslog Frontend"
echo "$LINE"

	yum -y install libssh2.x86_64 libssh2-devel.x86_64 php-pecl-ssh2.x86_64 > /dev/null 2>&1
	service httpd reload > /dev/null 2>&1
	
	cd $SRC_DIR
	wget http://$DL_SERVER/$CENTREON_SYSLOG_FRONTEND_VERSION.tar.gz > /dev/null 2>&1
	tar xvfz $CENTREON_SYSLOG_FRONTEND_VERSION.tar.gz > /dev/null 2>&1
	cd $CENTREON_SYSLOG_FRONTEND_VERSION
	./install.sh -i
	rm -rf $SRC_DIR

	echo ". Centreon Syslog Frontend installed. ok!"
	echo "Please access http://$SYSLOG_NG_SERVER/centreon in Internet Explorer, next install."
echo

exit 0 
