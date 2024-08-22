#!/bin/bash

CLOUDCMD=echo

PREFIX=web
if [[ -n $1 ]]; then PREFIX=$1; fi

# Describe rules
$CLOUDCMD compute forwarding-rules describe \
	www-rule --region $REGION

# Get ips
IPADDRESS=$($CLOUDCMD compute forwarding-rules \
	describe www-rule --region $REGION \
	--format="json" | jq -r .IPAddress
)

# Write ips
echo $IPADDRESS

# Attack network
for i in {1..10}; do
	curl -m1 $IPADDRESS;
done
