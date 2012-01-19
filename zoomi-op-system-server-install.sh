#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"
CENTREON_SERVER=$(ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |awk -F : '{print $2}')

#CENTREON_VERSION="centreon-2.1.9" Change centreon version 2.1.9 to 2.1.13
CENTREON_VERSION="centreon-2.1.13"
CENTREON_TEMPLATE="unbutn-template-install"

SRC_DIR="/home/zoomi/op_system"
INIT_DIR="/etc/init.d"

NAGIOS_DIR="/usr/local/nagios"
NAGIOS_BIN_DIR="$NAGIOS_DIR/bin"
NAGIOS_CFG_DIR="$NAGIOS_DIR/etc"

NRPE_CFG_DIR="$NAGIOS_CFG_DIR/nrpe.d"
NRPE_PLUGIN_DIR="$NAGIOS_DIR/libexec"

NAGIOS_INSTALL_FILE="nagios-3.2.1"
NAGIOS_PLUGIN_FILE="nagios-plugins-1.4.15"

NRPE_INSTALL_FILE="nrpe-2.12"
NRPE_CFG_FILE="nrpe-cfg.tar.gz"
NRPE_PLUGIN_FILE="nrpe-plugin.tar.gz"

NDO_INSTALL_FILE="ndoutils-1.4b9"
NDO_PATCH_FILE="ndoutils1.4b9_light.patch"

GNOKII_CFG_FILE="gnokiirc"
GNOKII_CFG_DIR="/etc"

NAGIOS_INIT_FILE="nagios"
NRPE_INIT_FILE="nrpe"
NDO_INIT_FILE="ndoutils"

LINE="##########################################"

echo "$LINE"
echo
echo "Zoomi OP-system Server Installation Script" 
echo
echo "                              version 1.0" 
echo 
echo "$LINE"
echo

read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
echo "DOWNLOAD_SERVER IP is $DL_SERVER."
echo

echo "$LINE"
echo "Section: Installing prerequisites"
echo "$LINE"
	sudo apt-get install -y build-essential > /dev/null 2>&1 && echo "1. Complie installed. ok!"
    	sudo apt-get install -y apache2 apache2.2-common apache2-mpm-prefork > /dev/null 2>&1 && echo "2. Web sever installed. ok!"
	sudo apt-get install -y php5 php5-mysql php-pear php5-ldap php5-snmp php5-gd > /dev/null 2>&1 && echo "3. PHP installed. ok!"
	sudo apt-get install -y mysql-server libmysqlclient15-dev > /dev/null 2>&1 && echo "4. MySQL server installed. ok!"
	# 1. New password for the MySQL "root" user: -> zoomi-init
	# 2. Repeat password for the MySQL "root" user: -> zoomi-init
	sudo apt-get install -y rrdtool librrds-perl > /dev/null 2>&1 && echo "5. RRDTOOL installed. ok!"
	sudo apt-get install -y libconfig-inifiles-perl libcrypt-des-perl libdigest-hmac-perl libdigest-sha1-perl libgd-gd2-perl > /dev/null 2>&1 && echo "6. Perl installed. ok!"
	sudo apt-get install -y snmp snmpd libnet-snmp-perl libsnmp-perl > /dev/null 2>&1 && echo "7. SNMP installed. ok!"
	sudo apt-get install -y libgd2-xpm libgd2-xpm-dev libpng12-dev > /dev/null 2>&1 && echo "8. GD-library installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nagios3"
echo "$LINE"
	
	[ ! -d $SRC_DIR ] && sudo mkdir -p $SRC_DIR

	sudo userdel -r nagios > /dev/null 2>&1
	sudo groupdel nagios > /dev/null 2>&1
	sudo useradd -m nagios > /dev/null 2>&1
	sudo groupdel nagcmd > /dev/null 2>&1
	sudo groupadd nagcmd > /dev/null 2>&1 
	sudo usermod -G nagios,nagcmd nagios > /dev/null 2>&1
	sudo usermod -G nagios,nagcmd www-data > /dev/null 2>&1
	
	cd $SRC_DIR
	sudo wget http://$DL_SERVER/$NAGIOS_INSTALL_FILE.tar.gz > /dev/null 2>&1
	sudo tar xvfz $NAGIOS_INSTALL_FILE.tar.gz > /dev/null 2>&1
	cd $NAGIOS_INSTALL_FILE
	
	sudo ./configure --prefix=$NAGIOS_DIR --with-command-group=nagcmd --enable-nanosleep --enable-event-broker > /dev/null 2>&1
	sudo make all > /dev/null 2>&1
	sudo make install > /dev/null 2>&1
	sudo make install-init > /dev/null 2>&1
	sudo make install-commandmode > /dev/null 2>&1
	sudo make install-config > /dev/null 2>&1

	cd $INIT_DIR
        sudo wget http://$DL_SERVER/$NAGIOS_INIT_FILE > /dev/null 2>&1
        sudo chmod +x $INIT_DIR/$NAGIOS_INIT_FILE > /dev/null 2>&1
        sudo update-rc.d $NAGIOS_INIT_FILE defaults > /dev/null 2>&1	
	echo ". Nagios3 installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nagios-plugin"
echo "$LINE"
        sudo apt-get install -y openssl libssl-dev > /dev/null 2>&1
        cd $SRC_DIR
        sudo wget http://$DL_SERVER/$NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1 
        sudo tar xvfz $NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1
	cd $NAGIOS_PLUGIN_FILE
	sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl --enable-perl-modules > /dev/null 2>&1
	sudo make > /dev/null 2>&1
	sudo make install > /dev/null 2>&1
	echo ". Nagios-plugin installed. ok!"
echo
		
echo "$LINE"
echo "Section: Installing Ndoutils"
echo "$LINE"
	cd $SRC_DIR
	sudo wget http://$DL_SERVER/$NDO_INSTALL_FILE.tar.gz > /dev/null 2>&1
	sudo tar xvfz $NDO_INSTALL_FILE.tar.gz > /dev/null 2>&1
	cd $NDO_INSTALL_FILE

	sudo wget http://$DL_SERVER/$NDO_PATCH_FILE > /dev/null 2>&1
	sudo patch -p1 -N < $NDO_PATCH_FILE > /dev/null 2>&1
	sudo ./configure --prefix=$NAGIOS_DIR --enable-mysql --disable-pgsql --with-ndo2db-user=nagios --with-ndo2db-group=nagios > /dev/null 2>&1
	sudo make > /dev/null 2>&1

	sudo cp ./src/ndomod-3x.o $NAGIOS_BIN_DIR/ndomod.o 
	sudo cp ./src/ndo2db-3x $NAGIOS_BIN_DIR/ndo2db
	sudo cp ./config/ndo2db.cfg-sample $NAGIOS_CFG_DIR/ndo2db.cfg
	sudo cp ./config/ndomod.cfg-sample $NAGIOS_CFG_DIR/ndomod.cfg
	sudo chmod 774 $NAGIOS_BIN_DIR/ndo*
	sudo chown nagios:nagios $NAGIOS_BIN_DIR/ndo*

	cd $INIT_DIR
	sudo wget http://$DL_SERVER/$NDO_INIT_FILE > /dev/null 2>&1
	sudo chmod +x $INIT_DIR/$NDO_INIT_FILE > /dev/null 2>&1
	sudo update-rc.d $NDO_INIT_FILE defaults > /dev/null 2>&1	
	echo ". Ndoutil installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe"
echo "$LINE"

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
        sudo chmod +x $NRPE_INIT_FILE > /dev/null 2>&1
        sudo update-rc.d $NRPE_INIT_FILE defaults > /dev/null 2>&1
        sudo service $NRPE_INIT_FILE restart
        echo ". Nrpe-plugin installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-plugin-library"
echo "$LINE"
        sudo apt-get install -y bc dnsutils fping libssl-dev libldap2-dev libnagios-object-perl libnagios-plugin-perl libclass-dbi-mysql-perl > /dev/null 2>&1
        echo ". Nrpe-plugin-library installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Notification Tools"
echo "$LINE"
	sudo apt-get install -y sendemail > /dev/null 2>&1 && echo ". sendEmail installed. ok!"
	sudo apt-get install -y minicom gnokii-cli gnokii-common > /dev/null 2>&1 && echo ". gnokii installed. ok!"
	cd $GNOKII_CFG_DIR
	sudo mv $GNOKII_CFG_FILE $GNOKII_CFG_FILE.bak
	sudo wget http://$DL_SERVER/$GNOKII_CFG_FILE > /dev/null 2>&1
	sudo usermod -G dialout nagios > /dev/null 2>&1
	sudo usermod -G dialout www-data > /dev/null 2>&1
echo
	
echo "$LINE"
echo "Section: Installation of Centreon"
echo "$LINE"

	cd $SRC_DIR
	sudo wget http://$DL_SERVER/$CENTREON_VERSION.tar.gz > /dev/null 2>&1
	sudo tar xvfz $CENTREON_VERSION.tar.gz > /dev/null 2>&1 
	cd $CENTREON_VERSION 

	sudo wget http://$DL_SERVER/conf/$CENTREON_TEMPLATE > /dev/null 2>&1
	sudo ./install.sh -f $CENTREON_TEMPLATE

	sudo rm -rf $SRC_DIR
	echo ". Centreon CLI installed. ok!"
echo

	echo "Please access http://$CENTREON_SERVER/centreon in Internet Explorer, next install."
echo  
