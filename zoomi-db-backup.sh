#!/bin/bash

DB_DIR="/home/zoomi/mysql-db"
WEB_DIR="/var/www"
TAR="/bin/tar"
MYSQL_DIR="/usr/bin"

MYSQL_ROOT_PASSWD="zoomi-init"
DBNAME1="centreon"
DBNAME2="centstatus"
DBNAME3="centstorage"
DBNAME4="syslog"
DBNAME5="om_db"
DBNAME6="zm_db"
DBNAME7="rsync"

KEEP_DAYS="5"
TODAY=$(date +%Y%m%d)
OLD_DAY=$(date -d "$KEEP_DAYS days ago" +%Y%m%d)

sudo mkdir -p $DB_DIR/$TODAY
sudo $MYSQL_DIR/mysqldump -B --add-drop-database --add-drop-table -u root --password=$MYSQL_ROOT_PASSWD $DBNAME1 > $DB_DIR/$TODAY/$DBNAME1.sql
sudo $MYSQL_DIR/mysqldump -B --add-drop-database --add-drop-table -u root --password=$MYSQL_ROOT_PASSWD $DBNAME2 > $DB_DIR/$TODAY/$DBNAME2.sql
sudo $MYSQL_DIR/mysqldump -B --add-drop-database --add-drop-table -u root --password=$MYSQL_ROOT_PASSWD $DBNAME3 > $DB_DIR/$TODAY/$DBNAME3.sql
sudo $MYSQL_DIR/mysqldump -B --add-drop-database --add-drop-table -u root --password=$MYSQL_ROOT_PASSWD $DBNAME4 > $DB_DIR/$TODAY/$DBNAME4.sql
sudo $MYSQL_DIR/mysqldump -B --add-drop-database --add-drop-table -u root --password=$MYSQL_ROOT_PASSWD $DBNAME5 > $DB_DIR/$TODAY/$DBNAME5.sql
sudo $MYSQL_DIR/mysqldump -B --add-drop-database --add-drop-table -u root --password=$MYSQL_ROOT_PASSWD $DBNAME6 > $DB_DIR/$TODAY/$DBNAME6.sql
sudo $MYSQL_DIR/mysqldump -B --add-drop-database --add-drop-table -u root --password=$MYSQL_ROOT_PASSWD $DBNAME7 > $DB_DIR/$TODAY/$DBNAME7.sql

CUR_DIR=$(/bin/pwd)
cd $DB_DIR
sudo $TAR cjvf $WEB_DIR/db_backup_$TODAY.tar.bz2 $TODAY
cd $CUR_DIR

sudo rm -rf $DB_DIR/$OLD_DAY
if [ -f "$WEB_DIR/db_backup_$OLD_DAY.tar.bz2" ]; then
	sudo rm -rf "$WEB_DIR/db_backup_$OLD_DAY.tar.bz2"
fi

exit 0
