#!/bin/bash

CLOUDCMD=echo
#CLOUDCMD=gcloud

#PREFIX=www
PREFIX=web

if [[ -n $1 ]]; then PREFIX=$1; fi
echo $1

$CLOUDCMD compute firewall-rules create www-firewall-network-lb \
	--target-tags network-lb-tag --allow tcp:80
