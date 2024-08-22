#!/bin/bash

CLOUDCMD=echo
#CLOUDCMD=gcloud

if [[ -n $1 ]]; then REGION=$1; fi
if [[ -n $2 ]]; then ZONE=$2; fi

if [[ -n $REGION ]]; then
	$CLOUDCMD config set compute/region $REGION
fi
if [[ -n $ZONE ]]; then
	$CLOUDCMD config set compute/zone $ZONE
fi
