#!/bin/bash

# System
CLOUDCMD=echo

# Configuration

REGION=us-central1
ZONE=us-central1-c

PROJECT=123

# Instances
INSTANCENAME=labInstance
TEMPLATENAME=labTemplate
MANAGEDGROUPNAME=labManagedGroup

# Firewall
FIREWALLRULENAME=labFirewall
FIREWALLTAG=labNetworkTag
FIREWALLHEALTHCHECKNAME=labHealthCheckFirewall
FIREWALLHEALTHCHECKTAG=labHealthCheckTag

# Address
ADDRESSNAME=netAddress

HEALTHCHECKNAME=netHealthCheck
BACKENDSERVNAME=netBackEnd

# Proxy
URLMAPNAME=labUrlMap
PROXYNAME=labProxy
FORWARDRULENAME=labForwardRule

# CONSTANTS
SERVERFILE='/var/www/html/index.nginx-debian.html'


function createInstance(){
	$CLOUDCMD compute instances create "$INSTANCENAME" \
		--zone=$ZONE \
		--tags=network-lb-tag \
		--machine-type=e2-small  \
		--image-family=debian-11  \
		--image-project=debian-cloud \
		--network=default
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
	--global \
	--network=default \
	--subnet=default \
	--tags=allow-health-check \
	--machine-type=e2-medium \
	--image-family=debian-11 \
	--image-project=debian-cloud \
	--metadata=startup-script="$STARTUPTEMPLATE"
	#--region=$REGION \


}

function createManagedGroup(){
	$CLOUDCMD compute instance-groups managed  \
		create $MANAGEDGROUPNAME \
		-backend-group --template=$TEMPLATENAME  \
		--size=2 --zone=$ZONE
	}


function createFirewall(){
$CLOUDCMD compute firewall-rules create $FIREWALLRULENAME \
	--target-tags $FIREWALLTAG --allow tcp:80 --global

$CLOUDCMD compute firewall-rules create $FIREWALLHEALTHCHECKNAME \
	--network=default \
	--action=allow \
	--direction=ingress \
	--source-ranges=130.211.0.0/22,35.191.0.0/16 \
	--target-tags=$FIREWALLHEALTHCHECKTAG \
	--rules=tcp:80 --global

}

function createAddress(){
$CLOUDCMD compute addresses create $ADDRESSNAME \
	--ip-version=IPV4 \
	--global
}

function createHealthCheck(){
$CLOUDCMD compute health-checks create http \
	$HEALTHCHECKNAME --port 80

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

}

function createProxy(){
$CLOUDCMD compute url-maps create $URLMAPNAME \
	--default-service web-backend-service


$CLOUDCMD compute target-http-proxies create $PROXYNAME \
	--url-map $URLMAPNAME

}

function createForwardingRule(){
$CLOUDCMD compute forwarding-rules create $FORWARDRULENAME \
	--address=$ADDRESSNAME \
	--global \
	--target-http-proxy=$PROXYNAME \
	--ports=80

}


# Run
createInstance &&
echo &&
createTemplate &&
echo &&
createManagedGroup &&
echo  &&
createFirewall &&
echo  &&
createAddress &&
echo  &&
createHealthCheck &&
echo  &&
createBackendService &&
echo  &&
createProxy &&
echo  &&
createForwardingRule &&
echo


