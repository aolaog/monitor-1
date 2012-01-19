#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"

SRC_DIR="/home/zoomi/op_system"
INSTALL_DIR="/usr/local"
INIT_DIR="/etc/init.d"

DBORACLE_FILE="DBD-Oracle-1.27"
ORACLE_CLIENT_FILE="instantclient_11_2"
TNSNAME_FILE="tnsnames.ora"
NRPE_INIT_FILE="nrpe"

ORACLE_SERVER="127.0.0.1"
ORACLE_SID="orcl"

LINE="##########################################"

echo "$LINE"
echo
echo "Zoomi Oracle Client Installation Script" 
echo
echo "                              version 1.0" 
echo 
echo "$LINE"
echo

read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
echo "DOWNLOAD_SERVER IP is $DL_SERVER."
echo

echo "$LINE"
echo "Section: Installing Oracle Client"
echo "$LINE"
        [ ! -d $SRC_DIR ] && mkdir -p $SRC_DIR
        cd $SRC_DIR
        wget http://$DL_SERVER/$ORACLE_CLIENT_FILE.tar.gz
        tar xvfz $ORACLE_CLIENT_FILE.tar.gz > /dev/null 2>&1
	sudo mv $ORACLE_CLIENT_FILE $INSTALL_DIR
	sudo chown -R zoomi:zoomi $INSTALL_DIR/$ORACLE_CLIENT_FILE

	read -p "Please Input ORACLE SERVER IP Address: " ORAClE_SERVER
	echo "ORACLE_SERVER IP is $ORACLE_SERVER."
	
	read -p "Please Input ORACLE_SID Name: " ORACLE_SID
	echo "ORACLE_SID Name is $ORACLE_SID."
	
	sed -i "s/127.0.0.1/$ORACLE_SERVER/g" $INSTALL_DIR/$ORACLE_CLIENT_FILE/$TNSNAME_FILE
	sed -i "s/orcl/$ORACLE_SID/g" $INSTALL_DIR/$ORACLE_CLIENT_FILE/$TNSNAME_FILE

        echo ". Oracle Cliient installed. ok!"
echo

echo "$LINE"
echo "Section: Installing perl module DB-ORACLE"
echo "$LINE"
	sudo apt-get -y install perl-doc libdbi-perl libaio1 libaio-dev > /dev/null 2>&1
        sudo wget http://$DL_SERVER/$DBORACLE_FILE.tar.gz > /dev/null 2>&1
        tar xvfz $DBORACLE_FILE.tar.gz > /dev/null 2>&1
	cd $DBORACLE_FILE

	export ORACLE_HOME=/usr/local/$ORACLE_CLIENT_FILE
	export PATH=$PATH:$ORACLE_HOME
	export LD_LIBRARY_PATH=$ORACLE_HOME
	export SQLPATH=$ORACLE_HOME
	export TNS_ADMIN=$ORACLE_HOME
	export ORACLE_SID=orcl

	perl Makefile.PL > /dev/null 2>&1
	make > /dev/null 2>&1
	sudo make install > /dev/null 2>&1

	cd $INIT_DIR
	sudo mv $NRPE_INIT_FILE $NRPE_INIT_FILE.bak
	sudo wget http://$DL_SERVER/$NRPE_INIT_FILE > /dev/null 2>&1
	sudo chmod 755 $NRPE_INIT_FILE > /dev/null 2>&1
	sudo $INIT_DIR/$NRPE_INIT_FILE restart > /dev/null 2>&1

	echo ". Nrpe installed. ok!"
	
	sudo rm -rf $SRC_DIR > /dev/null 2>&1
echo

exit 0
