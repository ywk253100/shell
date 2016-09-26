#!/bin/bash

#docker version: 1.11.2 
#docker-compose version: 1.7.1 
#Harbor version: 0.3.0 

set -e

usage=$'Usage: install.sh [OPTIONS]\n    -h, --host=IP/hostname    The IP address or hostname to access admin UI and registry service. DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.'

while [ $# -gt 0 ]; do
	case $1 in
	    -h|--host)
	    host="$2"
	    shift;;
	    --help|*)
	    echo "$usage"
	    exit 1;;
	esac
	shift || true
done

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $workdir

# The hostname in harbor.cfg did not been modified and the option h is not set
if grep 'hostname = reg.mydomain.com' &> /dev/null ./Deploy/harbor.cfg && [ -z "$host" ]
then
	echo $usage
	exit 1
fi

echo "[Step 1]: install docker"
./install_docker.sh

echo "[Step 2]: install docker-compose"
./install_docker_compose.sh

echo "[Step 3]: load Harbor images"
docker load -i ./harbor.tar.gz

echo "[Step 4]: prepare environment"
cd Deploy/
if [ -n "$host" ]
then
	sed "s/^hostname = .*/hostname = $host/g" -i ./harbor.cfg
fi
./prepare

echo "[Step 5]: check existence of Harbor"
if [ -n "$(docker-compose ps -q)"  ]
then
	echo "stopping existing Harbor..."
	docker-compose down
fi

echo "[Step 6]: start Harbor"
echo "starting..."
docker-compose up -d

protocal=http
hostname=reg.mydomain.com

if [[ $(cat ./harbor.cfg) =~ ui_url_protocol[[:blank:]]*=[[:blank:]]*(https?) ]]
then
protocol=${BASH_REMATCH[1]}
fi

if [[ $(grep 'hostname[[:blank:]]*=' ./harbor.cfg) =~ hostname[[:blank:]]*=[[:blank:]]*(.*) ]]
then
hostname=${BASH_REMATCH[1]}
fi

echo $"Harbor has been installed successfully. 
Now you should be able to open a browser to visit the admin portal at ${protocol}://${hostname}. Note that the default administrator username/password are admin/Harbor12345 .
Log in to the admin portal and create a new project, e.g. myproject. You can then use docker commands to login and push images (By default, the registry server listens on port 80):
$ docker login ${hostname} 
$ docker push ${hostname}/myproject/myrepo 
More details, please visit https://github.com/vmware/harbor"
