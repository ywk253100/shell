#!/bin/bash
set -e
echo "======================= $(date)====================="

export PATH=$PATH:/usr/local/bin

#iptables -A INPUT -p tcp --dport 5480 -j ACCEPT

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

#Shut down Harbor
echo "Shutting down Harbor..."
docker-compose -f $base_dir/harbor/docker-compose.yml down

#Collect attrs and modify harbor.cfg
echo "Configuring Harbor..."
$base_dir/script/config.sh

#Start Harbor
$base_dir/harbor/start.sh

echo "===================================================="