#!/bin/bash


SHOREWALLDIR="/etc/shorewall"
SHOREWALLFILE="shorewall-cfg.tar.gz"
PAMDIR="/etc/pam.d"
SECURITYDIR="/etc/security"
SSHFILE="sshd"
SUFILE="su"
ACCESSFILE="access.conf"
SSHDFILE="/etc/ssh/sshd_config"
SSHDSERVICE="/etc/init.d/ssh"

LINE="##########################################"

echo "$LINE"
echo
echo "         Zoomi Tuning Deployment Script   " 
echo
echo "                   for ubuntu version 1.0 " 
echo 
echo "$LINE"
echo

#read -p "Please Input DOWNLOAD_SERVER IP or Domain Name: " DL_SERVER
#echo "DOWNLOAD_SERVER IP is $DL_SERVER."
#echo

#echo "$LINE"
#echo "Section: ShoreWall Firewall Deployment"
#echo "$LINE"
#	sudo apt-get install shorewall-common shorewall-doc shorewall-perl > /dev/null 2>&1
#	cd $SHOREWALLDIR
#	sudo wget http://$DL_SERVER/$SHOREWALLFILE > /dev/null 2>&1
#	sudo tar xvfz $SHOREWALLFILE > /dev/null 2>&1
#	sudo shorewall start > /dev/null 2>&1
#	echo


echo "$LINE"
echo "Section: Disable IPV6"
echo "$LINE"
	sudo sed -i "s|quiet splash|ipv6.disable=1 quiet splash|g" /etc/default/grub
	sudo update-grub2 > /dev/null 2>&1
echo

echo "$LINE"
echo "Section: TCP/IP Tuning"
echo "$LINE"
cat << EOF | sudo tee -a /etc/sysctl.conf
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 2
net.ipv4.tcp_keepalive_intvl = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
EOF

	sudo sysctl -p > /dev/null 2>&1

cat << EOF | sudo tee -a /etc/security/limits.conf
* soft nofile 65535
* hard nofile 65535
EOF

echo

#echo "$LINE"
#echo "Section: SSH Secure Deployment"
#echo "$LINE"
#	cd $SECURITYDIR
#	sudo mv $ACCESSFILE $ACCESSFILE.bak
#	sudo wget http://$DL_SERVER/$ACCESSFILE > /dev/null 2>&1
#
#	cd $PAMDIR
#	sudo mv $SSHFILE $SSHFILE.bak
#	sudo mv $SUFILE $SUFILE.bak
#	
 #       sudo wget http://$DL_SERVER/$SSHFILE > /dev/null 2>&1
#        sudo wget http://$DL_SERVER/$SUFILE > /dev/null 2>&1
#	
#	sudo sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" $SSHDFILE
#	sudo sed -i "s/Port 22/Port 2299/g" $SSHDFILE
#	sudo $SSHDSERVICE restart 
#echo
