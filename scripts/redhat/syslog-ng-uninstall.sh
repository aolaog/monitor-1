#!/bin/bash


rpm -e syslog-ng-2.0.9-1.x86_64
rm -rf /etc/syslog-ng

SRC_DIR="/home/op_system"

SYSLOG_NG_INSTALL_FILE="syslog-ng-2.0.9-1.x86_64"
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
	
        service syslog-ng stop > /dev/null 2>&1
	rpm -e $SYSLOG_NG_INSTALL_FILE > /dev/null 2>&1
	rm -rf $SYSLOG_NG_CFG_DIR
	rm -rf $SYSLOG_NG_DIR
	rm -rf $CRON_CFG_DIR/$CRON_CFG_FILE
	rm -rf $SRC_DIR

	mysqladmin -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -f drop $SYSLOG_NG_DBNAME > /dev/null 2>&1
	mysql -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -e "delete from user where User='$SYSLOG_NG_USER'" mysql > /dev/null 2>&1
	mysql -u $MYSQL_ROOT_USER --password=$MYSQL_ROOT_PASSWD -e "delete from db where User='$SYSLOG_NG_USER'" mysql > /dev/null 2>&1
	
	echo ". Syslog-ng server uninstalled. ok!"
echo

exit 0
