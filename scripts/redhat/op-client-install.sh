#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"

SRC_DIR="/tmp/op_system"
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
echo "OP-system Client Installation Script" 
echo
echo "                      for RHEL version 1.0" 
echo 
echo "$LINE"
echo

read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
echo "DOWNLOAD_SERVER IP is $DL_SERVER."
echo

#read -p "Please Input CENTREON_SERVER IP or Domain Name: " CENTREON_SERVER
#echo "CENTREON_SERVER IP is $CENTREON_SERVER."
#echo

echo "$LINE"
echo "Section: Installing Nrpe"
echo "$LINE"

	userdel -r nagios > /dev/null 2>&1
	groupdel nagios > /dev/null 2>&1
	useradd -m nagios > /dev/null 2>&1
	groupdel nagcmd > /dev/null 2>&1
	groupadd nagcmd > /dev/null 2>&1 
	usermod -G nagios,nagcmd nagios > /dev/null 2>&1
	usermod -G nagios,nagcmd apache > /dev/null 2>&1
	
	#sudo apt-get -y install openssl libssl-dev > /dev/null 2>&1
	yum -y install openssl openssl-devel > /dev/null 2>&1
		
	[ ! -d $SRC_DIR ] && sudo mkdir -p $SRC_DIR
	cd $SRC_DIR

    	wget http://$DL_SERVER/download/$NRPE_INSTALL_FILE.tar.gz > /dev/null 2>&1
    	tar xvfz $NRPE_INSTALL_FILE.tar.gz > /dev/null 2>&1
	cd $NRPE_INSTALL_FILE
	./configure --enable-ssl --enable-command-args > /dev/null 2>&1
	make all > /dev/null 2>&1
	make install-plugin > /dev/null 2>&1
	make install-daemon > /dev/null 2>&1
	make install-daemon-config > /dev/null 2>&1
	
	cp init-script $INIT_DIR/$NRPE_INIT_FILE
	chmod +x $INIT_DIR/$NRPE_INIT_FILE
	#sed -i "s/127.0.0.1/127.0.0.1,$CENTREON_SERVER/g" $NAGIOS_CFG_DIR/nrpe.cfg
	sed -i "s/127.0.0.1/127.0.0.1,10.0.20.222,10.10.51.22,10.0.152.254,centreon.tvmining.com/g" $NAGIOS_CFG_DIR/nrpe.cfg
	sed -i "s/dont_blame_nrpe=0/dont_blame_nrpe=1/g" $NAGIOS_CFG_DIR/nrpe.cfg
	sed -i "s/command\[/\#command\[/g" $NAGIOS_CFG_DIR/nrpe.cfg
	echo "include_dir=$NRPE_CFG_DIR" >> $NAGIOS_CFG_DIR/nrpe.cfg
	echo ". Nrpe installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-cfg"
echo "$LINE"
	cd $NAGIOS_CFG_DIR
	wget http://$DL_SERVER/download/$NRPE_CFG_FILE > /dev/null 2>&1
    	tar xvfz $NRPE_CFG_FILE > /dev/null 2>&1
	rm -rf $NRPE_CFG_FILE
	echo ". Nrpe-cfg installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nagios-plugin"
echo "$LINE"
    	cd $SRC_DIR
    	wget http://$DL_SERVER/download/$NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1 
    	tar xvfz $NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1
	cd $NAGIOS_PLUGIN_FILE
	./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl --enable-perl-modules > /dev/null 2>&1
	make > /dev/null 2>&1
	make install > /dev/null 2>&1
    	rm -rf $SRC_DIR
	echo ". Nagios-plugin installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-plugin"
echo "$LINE"
	cd $NRPE_PLUGIN_DIR
	wget http://$DL_SERVER/download/$NRPE_PLUGIN_FILE > /dev/null 2>&1
	tar xvfz $NRPE_PLUGIN_FILE > /dev/null 2>&1
	chmod +x check*sh check*pl check_mysql*
	rm -rf $NRPE_PLUGIN_FILE
	echo ". Nrpe-plugin installed. ok!"
echo

echo "$LINE"
echo "Section: Install Nrpe Service"
echo "$LINE"
   	chkconfig --add $NRPE_INIT_FILE > /dev/null 2>&1
	service $NRPE_INIT_FILE start > /dev/null 2>&1
	echo ". Nrpe Service installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-plugin-library"
echo "$LINE"
	#rpm -Uhv http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm > /dev/null 2>&1
	yum -y install perl-Nagios-Plugin.noarch perl-version.x86_64 perl-DBD-MySQL.x86_64 perl-DBI.x86_64 > /dev/null 2>&1
	yum -y install perl-DBD-MySQL.x86_64 perl-DBI.x86_64 > /dev/null 2>&1
	echo ". Nrpe-plugin-library installed. ok!"
echo

exit 0
