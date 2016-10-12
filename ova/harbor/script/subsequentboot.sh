#!/bin/bash
set -e
echo "======================= $(date)====================="

export PATH=$PATH:/usr/local/bin

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $base_dir/common.sh

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
	#If the registry contains no images, the gc will fail.
	#So append a true to avoid failure.
	gc registry:2.5.0 || true
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