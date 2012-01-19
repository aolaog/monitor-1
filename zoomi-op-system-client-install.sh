#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"

SRC_DIR="/home/zoomi/op_system"
INIT_DIR="/etc/init.d"

NAGIOS_DIR="/usr/local/nagios"
NAGIOS_CFG_DIR="$NAGIOS_DIR/etc"
NRPE_CFG_DIR="$NAGIOS_CFG_DIR/nrpe.d"
NRPE_PLUGIN_DIR="$NAGIOS_DIR/libexec"

NRPE_INSTALL_FILE="nrpe-2.12"
NRPE_CFG_FILE="nrpe-cfg.tar.gz"
NRPE_PLUGIN_FILE="nrpe-plugin.tar.gz"
NAGIOS_PLUGIN_FILE="nagios-plugins-1.4.15"
NRPE_INIT_FILE="nrpe"

LINE="##########################################"

echo "$LINE"
echo
echo "Zoomi OP-system Client Installation Script" 
echo
echo "                              version 1.0" 
echo 
echo "$LINE"
echo

read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
echo "DOWNLOAD_SERVER IP is $DL_SERVER."
echo

read -p "Please Input CENTREON_SERVER IP or Domain Name: " CENTREON_SERVER
echo "CENTREON_SERVER IP is $CENTREON_SERVER."
echo

echo "$LINE"
echo "Section: Installing Nrpe"
echo "$LINE"

	sudo userdel -r nagios > /dev/null 2>&1
	sudo groupdel nagios > /dev/null 2>&1
	sudo useradd -m nagios > /dev/null 2>&1
	sudo groupdel nagcmd > /dev/null 2>&1
	sudo groupadd nagcmd > /dev/null 2>&1 
	sudo usermod -G nagios,nagcmd nagios > /dev/null 2>&1
	sudo usermod -G nagios,nagcmd www-data > /dev/null 2>&1
	
	sudo apt-get -y install openssl libssl-dev > /dev/null 2>&1
	
	[ ! -d $SRC_DIR ] && sudo mkdir -p $SRC_DIR
	cd $SRC_DIR

        sudo wget http://$DL_SERVER/$NRPE_INSTALL_FILE.tar.gz > /dev/null 2>&1
        sudo tar xvfz $NRPE_INSTALL_FILE.tar.gz > /dev/null 2>&1
	cd $NRPE_INSTALL_FILE
	sudo ./configure --enable-ssl --enable-command-args > /dev/null 2>&1
	sudo make all > /dev/null 2>&1
	sudo make install-plugin > /dev/null 2>&1
	sudo make install-daemon > /dev/null 2>&1
	sudo make install-daemon-config > /dev/null 2>&1

	sudo sed -i "s/127.0.0.1/127.0.0.1,$CENTREON_SERVER/g" $NAGIOS_CFG_DIR/nrpe.cfg
	sudo sed -i "s/dont_blame_nrpe=0/dont_blame_nrpe=1/g" $NAGIOS_CFG_DIR/nrpe.cfg
	sudo sed -i "s/command\[/\#command\[/g" $NAGIOS_CFG_DIR/nrpe.cfg
	echo "include_dir=$NRPE_CFG_DIR" | sudo tee -a $NAGIOS_CFG_DIR/nrpe.cfg
	echo ". Nrpe installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-cfg"
echo "$LINE"
	cd $NAGIOS_CFG_DIR
	sudo wget http://$DL_SERVER/$NRPE_CFG_FILE > /dev/null 2>&1
        sudo tar xvfz $NRPE_CFG_FILE > /dev/null 2>&1
	sudo rm -rf $NRPE_CFG_FILE
	echo ". Nrpe-cfg installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nagios-plugin"
echo "$LINE"
        cd $SRC_DIR
        sudo wget http://$DL_SERVER/$NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1 
        sudo tar xvfz $NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1
	cd $NAGIOS_PLUGIN_FILE
	sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl --enable-perl-modules > /dev/null 2>&1
	sudo make > /dev/null 2>&1
	sudo make install > /dev/null 2>&1
        sudo rm -rf $SRC_DIR
	echo ". Nagios-plugin installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-plugin"
echo "$LINE"
	cd $NRPE_PLUGIN_DIR
	sudo wget http://$DL_SERVER/$NRPE_PLUGIN_FILE > /dev/null 2>&1
	sudo tar xvfz $NRPE_PLUGIN_FILE > /dev/null 2>&1
	sudo chmod +x check*sh check*pl
	sudo rm -rf $NRPE_PLUGIN_FILE
	echo ". Nrpe-plugin installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-init"
echo "$LINE"
        cd $INIT_DIR
        sudo wget http://$DL_SERVER/$NRPE_INIT_FILE > /dev/null 2>&1
        sudo chmod +x $NRPE_INIT_FILE
	sudo update-rc.d $NRPE_INIT_FILE defaults > /dev/null 2>&1
	sudo service $NRPE_INIT_FILE restart > /dev/null 2>&1
	echo ". Nrpe-plugin installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-plugin-library"
echo "$LINE"
	sudo apt-get install -y bc dnsutils fping libssl-dev libldap2-dev libnagios-object-perl libnagios-plugin-perl libclass-dbi-mysql-perl > /dev/null 2>&1
	echo ". Nrpe-plugin-library installed. ok!"
echo

exit 0
