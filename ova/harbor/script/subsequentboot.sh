#!/bin/bash
set -e
echo "======================= $(date)====================="

export PATH=$PATH:/usr/local/bin

#Add rules to iptables
addIptableRules

#Stop Harbor
echo "Shutting down Harbor..."
down

#Garbage collection
value=$(ovfenv -k gc_enabled)
if [ "$value"="true" ]
then
	echo "GC enabled, starting garbage collection..."
	gc harbor_registry_1 registry:2.5.0 /etc/registry/config.yml	
else
	echo "GC disabled, skip garbage collection"
fi

#Configure Harbor
echo "Configuring Harbor..."
configure

#Start Harbor
echo "Starting Harbor..."
up

echo "===================================================="