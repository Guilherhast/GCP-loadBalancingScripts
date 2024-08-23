#!/bin/bash

# System
CLOUDCMD=echo

# Configuration

REGION=us-central1
ZONE=us-central1-c

PROJECT=123

# Instances
INSTANCENAME=lab-instance
TEMPLATENAME=lab-template
MANAGEDGROUPNAME=lab-managed-group

# Firewall
FIREWALLRULENAME=lab-firewall-rule
FIREWALLTAG=lab-network-tag
FIREWALLHEALTHCHECKNAME=lab-health-check-firewall-rule
FIREWALLHEALTHCHECKTAG=lab-allow-health-check-tag

# Address
ADDRESSNAME=net-address

HEALTHCHECKNAME=net-health-check
BACKENDSERVNAME=net-back-end

# Proxy
URLMAPNAME=lab-url-map
PROXYNAME=lab-proxy
FORWARDRULENAME=lab-forward-rule

# CONSTANTS
SERVERFILE='/var/www/html/index.nginx-debian.html'

function setProject(){
	$CLOUDCMD config set project $PROJECT
	$CLOUDCMD config set compute/region $REGION
	$CLOUDCMD config set compute/zone $ZONE
}

function createInstance(){
	$CLOUDCMD compute instances create "$INSTANCENAME" \
		--tags=$FIREWALLTAG \
		--machine-type=e2-micro  \
		--image-family=debian-11  \
		--image-project=debian-cloud \
		--network=default
		#--zone=$ZONE \
		#--metadata=startup-script="$STARTUPINS"
}

function createTemplate(){
	IFS='' read -r -d '' STARTUPTEMPLATE <<__EOF__
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' '$SERVERFILE'
__EOF__

$CLOUDCMD compute instance-templates create $TEMPLATENAME \
	--network=default \
	--subnet=default \
	--tags=$FIREWALLHEALTHCHECKTAG \
	--machine-type=e2-medium \
	--image-family=debian-11 \
	--image-project=debian-cloud \
	--metadata=startup-script="$STARTUPTEMPLATE"
	#--tags=$FIREWALLTAG,$FIREWALLHEALTHCHECKTAG \
	#--region=$REGION \
	#--global \

}

function createManagedGroup(){
	$CLOUDCMD compute instance-groups managed  \
		create $MANAGEDGROUPNAME \
		--template=$TEMPLATENAME  \
		--size=2
		#--zone=$ZONE \

}


function createFirewall(){
$CLOUDCMD compute firewall-rules create $FIREWALLRULENAME \
	--target-tags $FIREWALLTAG --allow tcp:80

$CLOUDCMD compute firewall-rules create $FIREWALLHEALTHCHECKNAME \
	--network=default \
	--action=allow \
	--direction=ingress \
	--target-tags=$FIREWALLHEALTHCHECKTAG \
	--rules=tcp:80
	#--source-ranges=130.211.0.0/22,35.191.0.0/16 \

}

function createAddress(){
$CLOUDCMD compute addresses create $ADDRESSNAME \
	--ip-version=IPV4 \
	--global
}

function createHealthCheck(){
$CLOUDCMD compute health-checks create http $HEALTHCHECKNAME

}

function createBackendService(){
$CLOUDCMD compute backend-services create $BACKENDSERVNAME \
	--protocol=HTTP --port-name=http \
	--health-checks=$HEALTHCHECKNAME \
	--global

$CLOUDCMD compute backend-services add-backend \
	$BACKENDSERVNAME \
	--instance-group=$MANAGEDGROUPNAME \
	--instance-group-zone=$ZONE \
	--global

}

function createProxy(){
$CLOUDCMD compute url-maps create $URLMAPNAME \
	--default-service $BACKENDSERVNAME \
	--global


$CLOUDCMD compute target-http-proxies create $PROXYNAME \
	--url-map $URLMAPNAME \
	--global

}

function createForwardingRule(){
$CLOUDCMD compute forwarding-rules create $FORWARDRULENAME \
	--address=$ADDRESSNAME \
	--target-http-proxy=$PROXYNAME \
	--ports=80 \
	--global

}


# Run
echo Setting project &&
setProject &&
echo Creating intance &&
createInstance &&
echo Creating Template &&
createTemplate &&
echo Creating managed group &&
createManagedGroup &&
echo  Creating Firewall rules &&
createFirewall &&
echo  Creating Address &&
createAddress &&
echo  Creating Healthcheck &&
createHealthCheck &&
echo  Creating backend service &&
createBackendService &&
echo  Creating proxy &&
createProxy &&
echo  Creating forward rule &&
createForwardingRule &&
echo


