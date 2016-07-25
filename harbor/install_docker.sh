#/bin/bash

function docker_install {
	docker_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	OS_distributor_ID=$(lsb_release -is)
	OS_release_number=$(lsb_release -rs)
	
	if [ $OS_distributor_ID != Ubuntu ] || [ $OS_release_number != 14.04 ]
	then		
	    echo "The docker installer embeded in this script only works on Ubuntu:14.04, and your OS is [$OS_distributor_ID:$OS_release_number]. You can install docker(1.10.0+) by yourself and run this script again"
	fi
	
	dpkg -i $docker_dir/docker-1.11.2-trusty/cgroup-lite_1.9_all.deb
	dpkg -i $docker_dir/docker-1.11.2-trusty/aufs-tools_1%3a3.2+20130722-1.1_amd64.deb
	dpkg -i $docker_dir/docker-1.11.2-trusty/liberror-perl_0.17-1.1_all.deb
	dpkg -i $docker_dir/docker-1.11.2-trusty/git-man_1%3a1.9.1-1ubuntu0.3_all.deb
	dpkg -i $docker_dir/docker-1.11.2-trusty/git_1%3a1.9.1-1ubuntu0.3_amd64.deb
	dpkg -i $docker_dir/docker-1.11.2-trusty/libltdl7_2.4.2-1.7ubuntu1_amd64.deb
	dpkg -i $docker_dir/docker-1.11.2-trusty/libsystemd-journal0_204-5ubuntu20.19_amd64.deb
	dpkg -i $docker_dir/docker-1.11.2-trusty/docker-engine_1.11.2-0~trusty_amd64.deb
}

# docker has not been installed
if ! docker --version &> /dev/null
then
	echo "installing docker..."
	docker_install
	exit $?
fi

# docker has been installed and check its version
if [[ $(docker --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]
then
	docker_version=${BASH_REMATCH[1]}
	docker_version_part1=${BASH_REMATCH[2]}
	docker_version_part2=${BASH_REMATCH[3]}
	
	# the version of docker does not meet the requirement
	if [ $docker_version_part1 -lt 1 ] || ([ $docker_version_part1 -eq 1 ] && [ $docker_version_part2 -lt 10 ])
	then
		while true; do
    		read -p "The version of docker installed [$docker_version] does not meet the requirement[1.10.0+]. Would you want to upgrade it?[y/n]" yn
    		case $yn in
        		[Yy]* ) break;;
        		* ) exit 1;;
    		esac
		done
		echo "upgrading docker..."
		docker_install
	else
		echo "docker[version: $docker_version] exists, skip docker installation"
	fi
else
	echo "failed to parse docker version"
	exit 1
fi





