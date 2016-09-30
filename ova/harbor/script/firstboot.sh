#!/bin/bash
set -e

echo "======================= $(date)====================="

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

#Install docker-compose
$base_dir/deps/docker-compose-1.7.1/install.sh

systemctl start docker

#Load images of Harbor
$base_dir/harbor/load.sh

$base_dir/script/subsequentboot.sh

echo "===================================================="