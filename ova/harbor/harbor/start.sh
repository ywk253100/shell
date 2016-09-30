#!/bin/bash

#docker version: 1.11.2 
#docker-compose version: 1.7.1 
#Harbor version: 0.3.0 

set -e

usage=$'Please set hostname and other necessary attributes in harbor.cfg first. DO NOT use localhost or 127.0.0.1 for hostname, because Harbor needs to be accessed by external clients.'

while [ $# -gt 0 ]; do
        case $1 in
            --help)
            echo "$usage"
            exit 0;;
            *)
            echo "$usage"
            exit 1;;
        esac
        shift || true
done

workdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $workdir

# The hostname in harbor.cfg has not been modified
if grep 'hostname = reg.mydomain.com' &> /dev/null harbor.cfg
then
	echo $usage
	exit 1
fi

function check_os {
	docker_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	
	if [ -f /etc/lsb-release ]
	then
	    OS_distributor_ID=$(lsb_release -is)
		OS_release_number=$(lsb_release -rs)
	fi
	echo "OS information: $OS_distributor_ID $OS_release_number"

	if [ "$OS_distributor_ID" != Ubuntu ] || [ "$OS_release_number" != 14.04 ]
	then		
	    echo "Recommended operating system: Ubuntu:14.04."
	fi

}

function check_docker {
	if ! docker --version &> /dev/null
	then
		echo "Need to install docker(1.10.0+) first and run this script again."
		exit 1
	fi
	
	# docker has been installed and check its version
	if [[ $(docker --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]
	then
		docker_version=${BASH_REMATCH[1]}
		docker_version_part1=${BASH_REMATCH[2]}
		docker_version_part2=${BASH_REMATCH[3]}
		
		# the version of docker does not meet the requirement
		if [ "$docker_version_part1" -lt 1 ] || ([ "$docker_version_part1" -eq 1 ] && [ "$docker_version_part2" -lt 10 ])
		then
			echo "Need to upgrade docker package to 1.10.0+."
			exit 1
		else
			echo "docker version: $docker_version"
		fi
	else
		echo "Failed to parse docker version."
		exit 1
	fi
}

function check_dockercompose {
	if ! docker-compose --version &> /dev/null
	then
		echo "Need to install docker-compose(1.7.1+) by yourself first and run this script again."
		#docker_compose_install
		exit $?
	fi
	
	# docker-compose has been installed, check its version
	if [[ $(docker-compose --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]
	then
		docker_compose_version=${BASH_REMATCH[1]}
		docker_compose_version_part1=${BASH_REMATCH[2]}
		docker_compose_version_part2=${BASH_REMATCH[3]}
		
		# the version of docker-compose does not meet the requirement
		if [ "$docker_compose_version_part1" -lt 1 ] || ([ "$docker_compose_version_part1" -eq 1 ] && [ "$docker_compose_version_part2" -lt 6 ])
		then
			echo "Need to upgrade docker-compose package to 1.7.1+."
		else
			echo "docker-compose version: $docker_compose_version"
		fi
	else
		echo "Failed to parse docker-compose version."
		exit 1
	fi
}

echo "[Step 0]: checking installation environment ..."
#check_os
check_docker
check_dockercompose

#echo "[Step 1]: loading Harbor images ..."
#docker load -i ./harbor*.tgz

echo "[Step 1]: preparing environment ..."
if [ -n "$host" ]
then
	sed "s/^hostname = .*/hostname = $host/g" -i ./harbor.cfg
fi
./prepare

echo "[Step 2]: checking existing instance of Harbor ..."
if [ -n "$(docker-compose ps -q)"  ]
then
	echo "stopping existing Harbor instance ..."
	docker-compose down
fi

echo "[Step 3]: starting Harbor ..."
docker-compose up -d

protocol=http
hostname=reg.mydomain.com

if [[ $(cat ./harbor.cfg) =~ ui_url_protocol[[:blank:]]*=[[:blank:]]*(https?) ]]
then
protocol=${BASH_REMATCH[1]}
fi

if [[ $(grep 'hostname[[:blank:]]*=' ./harbor.cfg) =~ hostname[[:blank:]]*=[[:blank:]]*(.*) ]]
then
hostname=${BASH_REMATCH[1]}
fi

echo $"
----Harbor has been installed and started successfully.----

Now you should be able to visit the admin portal at ${protocol}://${hostname}. 
For more details, please visit https://github.com/vmware/harbor .
"
