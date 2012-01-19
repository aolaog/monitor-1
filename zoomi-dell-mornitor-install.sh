#!/bin/bash

LINE="##########################################"

echo "$LINE"
echo
echo "Zoomi Dell Server Monitor Installation Script" 
echo
echo "                              version 1.0" 
echo 
echo "$LINE"
echo

echo "$LINE"
echo "Section: Installing Dell Openmanage Server Administrator"
echo "$LINE"
	echo 'deb http://linux.dell.com/repo/community/deb/OMSA_6.3 /' | sudo tee -a /etc/apt/sources.list.d/linux.dell.com.sources.list > /dev/null 2>&1
	sudo apt-get update > /dev/null 2>&1
	sudo apt-get install srvadmin-base srvadmin-storageservices
	sudo service dataeng start > /dev/null 2>&1
	sudo chown -R nagios:root /opt/dell
        echo ". Dell Openmanage Server Administrator installed. ok!"
echo	
