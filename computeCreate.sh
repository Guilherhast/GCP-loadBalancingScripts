#!/bin/bash

CLOUDCMD=echo
#CLOUDCMD=gcloud

WWWFILE=/var/www/html/index.html

#PREFIX=www
PREFIX=web

if [[ -n $1 ]]; then PREFIX=$1; fi
echo $1

function createStr(){
	SERVERNAME=$1

	$CLOUDCMD compute instances create $1 \
	--zone=Zone \
	--tags=network-lb-tag \
	--machine-type=e2-small \
	--image-family=debian-11 \
	--image-project=debian-cloud \
	--metadata=startup-script="#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo '<h3>Web Server: $SERVERNAME</h3>' | tee $WWWFILE"
}

function createHereDoc(){
	SERVERNAME=$1

	IFS='' read -r -d '' STARTUP <<__EOF__
#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo -e " <h3>Web Server: $SERVERNAME\n</h3>" | tee $WWWFILE
__EOF__

	$CLOUDCMD compute instances create $INSTANCENAME \
		--zone=$ZONE \
		--tags=network-lb-tag \
		--machine-type=e2-small  \
		--image-family=debian-11  \
		--image-project=debian-cloud \
		--network=default  \
		--metadata=startup-script="$STARTUP"
}

#EXECFUNC=createStr
EXECFUNC=createHereDoc
for name in "$PREFIX"{1..3}; do
	echo Doing for $name
	$EXECFUNC $name
done
