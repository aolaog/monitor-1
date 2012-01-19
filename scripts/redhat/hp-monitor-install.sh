#!/bin/bash

SRC_DIR="/home/op_system"
SUDO_FILE="/etc/sudoers"

LINE="############################################"

echo "$LINE"
echo
echo "Zoomi HP Server Monitor Installation Script" 
echo
echo "                       for RHEL version 1.0" 
echo 
echo "$LINE"
echo

echo "$LINE"
echo "Section: Installing HP Proliant Support Pack"
echo "$LINE"

	[ ! -d $SRC_DIR ] && sudo mkdir -p $SRC_DIR
	cd $SRC_DIR
	
    	wget http://downloads.linux.hp.com/SDR/downloads/bootstrap.sh > /dev/null 2>&1
    	sh bootstrap.sh ProLiantSupportPack -r 5Server -y hp-psp-repository.repo
    
    	yum -y install hp-health hpacucli > /dev/null 2>&1
	
	sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' $SUDO_FILE > /dev/null 2>&1
	echo 'nagios ALL=NOPASSWD: /sbin/hpasmcli' | tee -a $SUDO_FILE > /dev/null 2>&1
    	echo 'nagios ALL=NOPASSWD: /usr/sbin/hpacucli' | tee -a $SUDO_FILE >/dev/null 2>&1
    
	service hp-health start > /dev/null 2>&1
    	service hp-asrd start > /dev/null 2>&1
        
	rm -rf $SRC_DIR
	echo ". HP Proliant Support Pack installed. ok!"
	
echo	
