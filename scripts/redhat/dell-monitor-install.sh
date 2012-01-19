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
	#wget -q -O - http://linux.dell.com/repo/community/bootstrap.cgi | bash
	yum install srvadmin-base
	yum install srvadmin-storageservices	
        echo ". Dell Openmanage Server Administrator installed. ok!"
echo	
