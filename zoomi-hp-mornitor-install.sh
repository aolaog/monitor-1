#!/bin/bash

LINE="##########################################"

echo "$LINE"
echo
echo "Zoomi HP Server Monitor Installation Script" 
echo
echo "                              version 1.0" 
echo 
echo "$LINE"
echo

echo "$LINE"
echo "Section: Installing HP Proliant Support Pack"
echo "$LINE"
        wget http://downloads.linux.hp.com/SDR/psp/GPG-KEY-ProLiantSupportPack -O - | sudo apt-key add - > /dev/null 2>&1
	echo "deb http://downloads.linux.hp.com/SDR/psp/ stable/current non-free" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1
	sudo apt-get update > /dev/null 2>&1
	sudo apt-get -y install hp-health hpacucli > /dev/null 2>&1
	echo 'nagios ALL=NOPASSWD: /sbin/hpasmcli' | sudo tee -a /etc/sudoers > /dev/null 2>&1
        echo 'nagios ALL=NOPASSWD: /usr/sbin/hpacucli' | sudo tee -a /etc/sudoers >/dev/null 2>&1
        echo ". HP Proliant Support Pack installed. ok!"
echo	
