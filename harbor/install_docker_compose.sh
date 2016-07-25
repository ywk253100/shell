#/bin/bash



function docker_compose_install {
	docker_compose_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	cp $docker_compose_dir/docker-compose-1.7.1/docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
}

# docker-compose has not been installed
if ! docker-compose --version &> /dev/null
then
	echo "installing docker-compose..."
	docker_compose_install
	exit $?
fi

# docker-compose has been installed, check its version
if [[ $(docker-compose --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]
then
	docker_compose_version=${BASH_REMATCH[1]}
	docker_compose_version_part1=${BASH_REMATCH[2]}
	docker_compose_version_part2=${BASH_REMATCH[3]}
	
	# the version of docker-compose does not meet the requirement
	if [ $docker_compose_version_part1 -lt 1 ] || ([ $docker_compose_version_part1 -eq 1 ] && [ $docker_compose_version_part2 -lt 6 ])
	then
		while true; do
    		read -p "The version of docker-compose installed [$docker_compose_version] does not meet the requirement[1.6.0+]. Would you want to upgrade it?[y/n]" yn
    		case $yn in
        		[Yy]* ) break;;
        		* ) exit 1;;
    		esac
		done
		echo "upgrading docker-compose..."
		docker_compose_install
	else
		echo "docker-compose[version: $docker_compose_version] exists, skip docker-compose installation"
	fi
else
	echo "failed to parse docker-compose version"
	exit 1
fi


