#!/bin/bash

CLOUDCMD=echo

WWWFILE=/var/www/html/index.html

#PREFIX=www
PREFIX=web

if [[ -n $1 ]]; then PREFIX=$1; fi
echo $1

function createHereDoc(){

	IFS='' read -r -d '' STARTUP <<__EOF__
#!/bin/bash
apt-get update
apt-get install apache2 -y
a2ensite default-ssl
a2enmod ssl
vm_hostname="\$(curl -H "Metadata-Flavor:Google" \
http://169.254.169.254/computeMetadata/v1/instance/name)"
echo "Page served from: \$vm_hostname" | \
tee $WWWFILE
systemctl restart apache2
__EOF__

$CLOUDCMD compute instance-templates create lb-backend-template \
	--region=$REGION \
	--network=default \
	--subnet=default \
	--tags=allow-health-check \
	--machine-type=e2-medium \
	--image-family=debian-11 \
	--image-project=debian-cloud \
	--metadata=startup-script="$STARTUP"
}

#EXECFUNC=createStr
EXECFUNC=createHereDoc
for name in "$PREFIX"{1..3}; do
	echo Doing for $name
	$EXECFUNC $name
done
