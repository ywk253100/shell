#!/bin/bash
set -e

attrs=( 
	auth_mode 
	ldap_url 
	ldap_searchdn 
	ldap_search_pwd 
	ldap_basedn 
	ldap_uid email_server 
	email_server_port 
	email_username 
	email_password 
	email_from 
	email_ssl 
	)

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

#The location of harbor.cfg
cfg=$base_dir/harbor/harbor.cfg

#Modify hostname
ip=$(ip addr show eth0|grep "inet "|tr -s ' '|cut -d ' ' -f 3|cut -d '/' -f 1)
if [ -n "$ip" ]
then
	echo "Read IP address: [ IP - $ip ]"
	sed -i -r s/"hostname = .*"/"hostname = $ip"/ $cfg
else
	echo "Failed to get the IP address"
	exit 1
fi

for attr in "${attrs[@]}"
do
	value=$(ovfenv -k $attr)
	echo "Read attribute using ovfenv: [ $attr - $value ]"
	if [ -n "$value" ]
	then
		sed -i -r s%"#?$attr = .*"%"$attr = $value"% $cfg
	fi
done