#!/bin/bash

SRC_DIR="/home/zoomi/op_system"

SYSLOG_NG_DIR="/usr/bin/syslog"
SYSLOG_NG_CFG_DIR="/etc/syslog-ng"
SYSLOG_NG_DBNAME="syslog"
SYSLOG_NG_USER="syslogadmin"

CRON_CFG_DIR="/etc/cron.d"
CRON_CFG_FILE="centreon-syslog"

MYSQL_ROOT_USER="root"
#MYSQL_ROOT_PASSWD="zoomi-init"

read -p "Please Input root passwd of Mysql Database: " MYSQL_ROOT_PASSWD
echo "Root passwd of Mysql Database is $MYSQL_ROOT_PASSWD"
echo

LINE="##########################################"

echo "$LINE"
echo "Section: Uninstalling Syslog-ng server"
echo "$LINE"
	
	sudo apt-get autoremove -y --purge syslog-ng > /dev/null 2>&1
	sudo rm -rf $SYSLOG_NG_CFG_DIR
	sudo rm -rf $SYSLOG_NG_DIR
	sudo rm -rf $CRON_CFG_DIR/$CRON_CFG_FILE
	sudo rm -rf $SRC_DIR

	sudo mysqladmin -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -f drop $SYSLOG_NG_DBNAME > /dev/null 2>&1
	sudo mysql -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -e "delete from user where User='$SYSLOG_NG_USER'" mysql > /dev/null 2>&1
	sudo mysql -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -e "delete from db where User='$SYSLOG_NG_USER'" mysql > /dev/null 2>&1
	
	echo ". Syslog-ng server uninstalled. ok!"
echo

exit 0
