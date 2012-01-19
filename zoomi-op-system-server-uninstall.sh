#!/bin/bash

SRC_DIR="/home/zoomi/op_system"
INIT_DIR="/etc/init.d"
NAGIOS_DIR="/usr/local/nagios"
CENTREON_DIR="/usr/local/centreon"
SNMP_DIR="/etc/snmp"
CRON_DIR="/etc/cron.d"

MYSQL_ROOT_USER="root"
#MYSQL_ROOT_PASSWD="zoomi-init"

NAGIOS_INIT_FILE="nagios"
NRPE_INIT_FILE="nrpe"
NDO_INIT_FILE="ndoutils"
CENTREON_INIT_FILE="centreon" 
CENTCORE_INIT_FILE="centcore"   
CENTSTATUS_INIT_FILE="centstatus"   
CENTSTORAGE_INIT_FILE="centstorage"


read -p "Please Input root passwd of Mysql Database: " MYSQL_ROOT_PASSWD
echo "Root passwd of Mysql Database is $MYSQL_ROOT_PASSWD"
echo

LINE="##########################################"

echo "$LINE"
echo "Section: Uninstalling zoomi-op-system-server"
echo "$LINE"

	sudo service $NAGIOS_INIT_FILE stop > /dev/null 2>&1
        sudo update-rc.d -f $NAGIOS_INIT_FILE remove > /dev/null 2>&1
        sudo rm -rf $INIT_DIR/$NAGIOS_INIT_FILE

	sudo service $NRPE_INIT_FILE stop > /dev/null 2>&1
        sudo update-rc.d -f $NRPE_INIT_FILE remove > /dev/null 2>&1
        sudo rm -rf $INIT_DIR/$NRPE_INIT_FILE

	sudo service $NDO_INIT_FILE stop > /dev/null 2>&1
	sudo update-rc.d -f $NDO_INIT_FILE remove > /dev/null 2>&1
	sudo rm -rf $INIT_DIR/$NDO_INIT_FILE
	
	sudo service $CENTCORE_INIT_FILE stop > /dev/null 2>&1
        sudo update-rc.d -f $CENTCORE_INIT_FILE remove > /dev/null 2>&1
        sudo rm -rf $INIT_DIR/$CENTCORE_INIT_FILE

	sudo service $CENTSTORAGE_INIT_FILE stop > /dev/null 2>&1
        sudo update-rc.d -f $CENTSTORAGE_INIT_FILE remove > /dev/null 2>&1
        sudo rm -rf $INIT_DIR/$CENTSTORAGE_INIT_FILE

	sudo rm -rf $NAGIOS_DIR
	sudo rm -rf $CENTREON_DIR
	sudo rm -rf $SNMP_DIR/*$CENTREON_INIT_FILE*
	sudo rm -rf $CRON_DIR/*$CENTREON_INIT_FILE*
	sudo rm -rf $SRC_DIR

	sudo userdel -r nagios > /dev/null 2>&1
	sudo groupdel nagcmd > /dev/null 2>&1
	sudo groupdel nagios > /dev/null 2>&1
	
	sudo mysqladmin -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -f drop $CENTREON_INIT_FILE > /dev/null 2>&1
	sudo mysqladmin -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -f drop $CENTSTATUS_INIT_FILE > /dev/null 2>&1
	sudo mysqladmin -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -f drop $CENTSTORAGE_INIT_FILE > /dev/null 2>&1
	
	echo ". zoomi-op-system-server uninstalled. ok!"
echo

exit 0
