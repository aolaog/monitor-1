#!/bin/bash

ipaddr=$(/sbin/ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |awk -F : '{print $2}')
sms_time=$(date +%Y\/%m\/%d-%H:%M)
sms_hour=$(date +%H)

nagios_stat="OK"
ndo2db_stat="OK"
centcore_stat="OK"
centstorage_stat="OK"
mysql_stat="OK"

command_dir="/usr/local/nagios/libexec"
sms_list="13910514434 13911407568 13955103805"
email_list="liujitao@zoomi.com.cn,chenggong@zoomi.com.cn,weirui@zoomi.com.cn"

sms_bin="/usr/bin/gnokii --sendsms"
email_bin="/usr/bin/sendemail -f centreon@zoomi.com.cn -s mail.zoomi.com.cn -xu centreon -xp P##,,e8 -t $email_list -u 'Centreon Server Status' -m"

if [ `$command_dir/check_ps.sh -p nagios | awk '{print $1}'` = "CRITICAL" ]; then
    nagios_stat="CRITICAL"
fi

if [ `$command_dir/check_ps.sh -p ndo2db | awk '{print $1}'` = "CRITICAL" ]; then
    ndo2db_stat="CRITICAL"
fi

if [ `$command_dir/check_ps.sh -p centcore | awk '{print $1}'` = "CRITICAL" ]; then
    centcore_stat="CRITICAL"
fi

if [ `$command_dir/check_ps.sh -p centstorage | awk '{print $1}'` = "CRITICAL" ]; then
    centstorage_stat="CRITICAL"
fi

if [ `$command_dir/check_ps.sh -p mysqld | awk '{print $1}'` = "CRITICAL" ]; then
    mysql_stat="CRITICAL"
fi

$email_bin "$sms_time $ipaddr Nagios -> $nagios_stat, Ndo2db -> $ndo2db_stat, Centcore -> $centcore_stat, Centstorage -> $centstorage_stat, Mysql -> $mysql_stat."

#case "$sms_hour" in
#9|11|16|19|21)
for i in $sms_list
do
    echo "$sms_time $ipaddr Nagios -> $nagios_stat, Ndo2db -> $ndo2db_stat, Centcore -> $centcore_stat, Centstorage -> $centstorage_stat, Mysql -> $mysql_stat." | $sms_bin $i
    sleep 10
done
#;;
#*)
#;;
#esac
exit 0
