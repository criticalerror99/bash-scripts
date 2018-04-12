#!/bin/bash

function create_vhost(){
	USERNAME=$1
	DOCUMENTROOT=$2/www$3
	COUNT=$3
	CONFPATH=/etc/apache2/vhosts.d/
	VHOST=vhost-${USERNAME}-${COUNT}
	VHOSTCONF=${CONFPATH}${VHOST}.conf
	#create simple vhost configuration
	echo "<VirtualHost *:80>" >> $VHOSTCONF
	echo "	ServerName ${USERNAME}.example.local" >> $VHOSTCONF
	echo "	DocumentRoot ${DOCUMENTROOT}" >> $VHOSTCONF
	echo "	ErrorLog /var/log/apache2/${VHOST}-error_log" >> $VHOSTCONF
	echo "	CustomLog /var/log/apache2/${VHOST}-access_log combined" >> $VHOSTCONF
	echo "</VirtualHost>" >> $VHOSTCONF
}

function create_user(){
	USER=$1

	grep -E "^$USER" /etc/passwd
	if [ $? -eq 0 ]; then
		echo "User $USER already exist"
		return 1	
	fi

	useradd $USER
	#create user dir and 5 www dirs inside eg. www1, www2
	USERDIR=/www/$USER
	mkdir -p ${USERDIR}/www{1..5}
	chown -R $USER:users $USERDIR
	
	#create vhost for each directory created above
	for vhost_number in {1..5}
	do
		create_vhost $USER $USERDIR $vhost_number
	done
}

function main(){
	USER_NAME=$1

	if [ `id -u` -ne 0 ]; then
		echo "You must run a script as a root"
		exit 1
	fi	

	if [ $# -eq 0 ]; then
		echo "Invalid arguments number"
		exit 2
	fi
	
	if [ $# -eq 1 ]; then
		create_user $USER_NAME
		exit 0
	fi
	
	if [ $# -eq 3 ]; then
			for ((num=$2; num <= $3; num++))
			do
				create_user ${USER_NAME}$num
			done
	else
		echo "Invalid arguments number"
		exit 3
	fi
}

main $@
