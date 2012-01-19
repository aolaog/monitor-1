#!/bin/bash

#DL_SERVER="centreon.zoomi.com.cn"
CENTREON_SERVER=$(ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |awk -F : '{print $2}')

CENTREON_VERSION='centreon-2.2.2'
CENTREON_TEMPLATE='redhat-template-install'

SRC_DIR="/home/op_system"
INIT_DIR="/etc/init.d"

NAGIOS_DIR="/usr/local/nagios"
NAGIOS_BIN_DIR="$NAGIOS_DIR/bin"
NAGIOS_CFG_DIR="$NAGIOS_DIR/etc"

NRPE_CFG_DIR="$NAGIOS_CFG_DIR/nrpe.d"
NRPE_PLUGIN_DIR="$NAGIOS_DIR/libexec"

NAGIOS_INSTALL_FILE="nagios-3.3.1"
NAGIOS_PLUGIN_FILE="nagios-plugins-1.4.15"

NRPE_INSTALL_FILE="nrpe-2.12"
NRPE_CFG_FILE="nrpe-cfg.tar.gz"
NRPE_PLUGIN_FILE="nrpe-plugin.tar.gz"
NRPE_INIT_FILE="nrpe"

NDO_INIT_FILE="ndoutils"
NDO_INSTALL_FILE="ndoutils-1.4b9"
NDO_PATCH_FILE="ndoutils1.4b9_light.patch"

SENDEMAIL_INSTALL_FILE='sendEmail'
GNOKII_CFG_FILE="gnokiirc"
GNOKII_CFG_DIR="/etc"

LINE="######################################################"

echo "$LINE"
echo
echo "     Zoomi OP-system Server Installation Script       " 
echo
echo "                          for RHEL version 1.0        " 
echo 
echo "$LINE"
echo

read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
echo "DOWNLOAD_SERVER IP is $DL_SERVER."
echo

echo "$LINE"
echo "Section: Installing prerequisites"
echo "$LINE"

	rpm -ihv http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm > /dev/null 2>&1
	
	yum -y install httpd && usermod -U apache > /dev/null 2>&1
	echo "1. Installing Apache -----------------------> ok"
	
	yum -y install gd fontconfig-devel libjpeg-devel libpng-devel gd-devel perl-GD > /dev/null 2>&1
	echo "2. Installing GD modules -------------------> ok"
	
	yum -y install openssl-devel perl-DBD-MySQL mysql-server mysql-devel > /dev/null 2>&1
	service mysqld start > /dev/null 2>&1
	mysqladmin -u root password 'zoomi-init'
	echo "3. Installing MySQL ------------------------> ok"
	
	yum -y install php php-mysql php-gd php-ldap php-xml php-mbstring > /dev/null 2>&1
	echo "4. Installing PHP --------------------------> ok"

	yum -y install perl-Config-IniFiles perl-DBI perl-DBD-MySQL perl-Crypt-DES perl-Digest-SHA1 perl-Digest-HMAC perl-Socket6 perl-IO-Socket-INET6 > /dev/null 2>&1
	echo "5. Installing PERL modules -----------------> ok"
	
	yum -y install rrdtool perl-rrdtool > /dev/null 2>&1
	echo "6. Installing RRDTools ---------------------> ok"
	
	yum -y install net-snmp-utils net-snmp net-snmp-libs php-snmp dmidecode lm_sensors perl-Net-SNMP net-snmp-perl > /dev/null 2>&1
	echo "7. Installing SNMP -------------------------> ok"
	
	yum -y install fping cpp gcc gcc-c++ libstdc++ glib2-devel > /dev/null 2>&1
	echo "8. Installing Compiler Tools ---------------> ok"

	yum -y install php-pear > /dev/null 2>&1
	pear upgrade-all --force > /dev/null 2>&1
	echo "9. Installing Pear -------------------------> ok"
	
echo

echo "$LINE"
echo "Section: Installing Nagios3"
echo "$LINE"
	
	[ ! -d $SRC_DIR ] && mkdir -p $SRC_DIR

	userdel -r nagios > /dev/null 2>&1
	groupdel nagios > /dev/null 2>&1
	groupdel nagcmd > /dev/null 2>&1 

	useradd -m nagios > /dev/null 2>&1
	groupadd nagcmd > /dev/null 2>&1 

	usermod -G nagios,nagcmd nagios > /dev/null 2>&1
	usermod -G nagios,nagcmd apache > /dev/null 2>&1
	
	cd $SRC_DIR
	wget http://$DL_SERVER/$NAGIOS_INSTALL_FILE.tar.gz > /dev/null 2>&1
	tar xvfz $NAGIOS_INSTALL_FILE.tar.gz > /dev/null 2>&1
	
	cd $NAGIOS_INSTALL_FILE
	
	./configure --with-command-group=nagcmd --enable-nanosleep --enable-event-broker > /dev/null 2>&1
	make all > /dev/null 2>&1
	make install > /dev/null 2>&1
	make install-init > /dev/null 2>&1
	make install-commandmode > /dev/null 2>&1
	make install-config > /dev/null 2>&1

	echo ". Nagios3 installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nagios-plugin"
echo "$LINE"
        yum -y install fping openssl-devel openldap-devel postgresql-devel radiusclient-ng-devel samba-client libsmbclient perl-Nagios-Plugin.noarch perl-version.x86_64 > /dev/null 2>&1

        cd $SRC_DIR
        wget http://$DL_SERVER/$NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1 
        tar xvfz $NAGIOS_PLUGIN_FILE.tar.gz > /dev/null 2>&1
	cd $NAGIOS_PLUGIN_FILE
	./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl --enable-perl-modules > /dev/null 2>&1
	make > /dev/null 2>&1
	make install > /dev/null 2>&1
	echo ". Nagios-plugin installed. ok!"
echo
		
echo "$LINE"
echo "Section: Installing Ndoutils"
echo "$LINE"
	cd $SRC_DIR
	wget http://$DL_SERVER/$NDO_INSTALL_FILE.tar.gz > /dev/null 2>&1
	tar xvfz $NDO_INSTALL_FILE.tar.gz > /dev/null 2>&1
	cd $NDO_INSTALL_FILE

	wget http://$DL_SERVER/$NDO_PATCH_FILE > /dev/null 2>&1
	patch -p1 -N < $NDO_PATCH_FILE > /dev/null 2>&1
	
	./configure --enable-mysql --disable-pgsql --with-ndo2db-user=nagios --with-ndo2db-group=nagios > /dev/null 2>&1
	make > /dev/null 2>&1

	cp ./src/ndomod-3x.o $NAGIOS_BIN_DIR/ndomod.o 
	cp ./src/ndo2db-3x $NAGIOS_BIN_DIR/ndo2db
	cp ./config/ndo2db.cfg-sample $NAGIOS_CFG_DIR/ndo2db.cfg
	cp ./config/ndomod.cfg-sample $NAGIOS_CFG_DIR/ndomod.cfg
	
	chmod 774 $NAGIOS_BIN_DIR/ndo*
	chmod 664 $NAGIOS_CFG_DIR/ndo*

	chown nagios:nagios $NAGIOS_BIN_DIR/ndo*
	chown nagios:nagios $NAGIOS_CFG_DIR/ndo*

	cp ./daemon-init /etc/init.d/$NDO_INIT_FILE
 	chmod +x /etc/init.d/$NDO_INIT_FILE
 	chkconfig --add $NDO_INIT_FILE

	echo ". Ndoutil installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe"
echo "$LINE"
        cd $SRC_DIR

        wget http://$DL_SERVER/$NRPE_INSTALL_FILE.tar.gz > /dev/null 2>&1
        tar xvfz $NRPE_INSTALL_FILE.tar.gz > /dev/null 2>&1
        cd $NRPE_INSTALL_FILE
        ./configure --enable-ssl --enable-command-args > /dev/null 2>&1
        make all > /dev/null 2>&1
        make install-plugin > /dev/null 2>&1
        make install-daemon > /dev/null 2>&1
        make install-daemon-config > /dev/null 2>&1

        sed -i "s/127.0.0.1/127.0.0.1,$CENTREON_SERVER/g" $NAGIOS_CFG_DIR/nrpe.cfg
        sed -i "s/dont_blame_nrpe=0/dont_blame_nrpe=1/g" $NAGIOS_CFG_DIR/nrpe.cfg
        sed -i "s/command\[/\#command\[/g" $NAGIOS_CFG_DIR/nrpe.cfg
        echo "include_dir=$NRPE_CFG_DIR" | tee -a $NAGIOS_CFG_DIR/nrpe.cfg

	cp ./init-script /etc/init.d/$NRPE_INIT_FILE
	chmod +x /etc/init.d/$NRPE_INIT_FILE
        chkconfig --add $NRPE_INIT_FILE

        echo ". Nrpe installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-plugin"
echo "$LINE"
        cd $NRPE_PLUGIN_DIR
        wget http://$DL_SERVER/$NRPE_PLUGIN_FILE > /dev/null 2>&1 
        tar xvfz $NRPE_PLUGIN_FILE > /dev/null 2>&1 
        chmod +x check*sh check*pl check*jar
        chown nagios:nagios check*sh check*pl check*jar
        rm -rf $NRPE_PLUGIN_FILE

        echo ". Nrpe-plugin installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Nrpe-cfg"
echo "$LINE"

        cd $NAGIOS_CFG_DIR
        wget http://$DL_SERVER/$NRPE_CFG_FILE > /dev/null 2>&1
        tar xvfz $NRPE_CFG_FILE > /dev/null 2>&1
	chown -R nagios:nagios $NAGIOS_CFG_DIR
        rm -rf $NRPE_CFG_FILE
	
	service $NRPE_INIT_FILE start > /dev/null 2>&1

        echo ". Nrpe-cfg installed. ok!"
echo

echo "$LINE"
echo "Section: Installing Notification Tools"
echo "$LINE"
	
	cd $SRC_DIR

        wget http://$DL_SERVER/$SENDEMAIL_INSTALL_FILE > /dev/null 2>&1
       	cp $SENDEMAIL_INSTALL_FILE /usr/bin
	chmod 755 /usr/bin/$SENDEMAIL_INSTALL_FILE
	echo ". sendEmail installed. ok!"
	
	yum -y install minicom gnokii > /dev/null 2>&1 
	echo ". gnokii installed. ok!"
	
	cd $GNOKII_CFG_DIR
	mv $GNOKII_CFG_FILE $GNOKII_CFG_FILE.bak
	wget http://$DL_SERVER/$GNOKII_CFG_FILE > /dev/null 2>&1
	usermod -G dialout nagios > /dev/null 2>&1
	usermod -G dialout apache > /dev/null 2>&1
echo
	
echo "$LINE"
echo "Section: Installation of Centreon"
echo "$LINE"

	cd $SRC_DIR
	wget http://$DL_SERVER/$CENTREON_VERSION.tar.gz > /dev/null 2>&1
	tar xvfz $CENTREON_VERSION.tar.gz > /dev/null 2>&1 
	cd $CENTREON_VERSION 

	wget http://$DL_SERVER/conf/$CENTREON_TEMPLATE > /dev/null 2>&1
	./install.sh -f $CENTREON_TEMPLATE

	rm -rf $SRC_DIR
	
	echo ". Centreon CLI installed. ok!"
echo

	echo "Please access http://$CENTREON_SERVER/centreon in Internet Explorer, next install."
echo  
