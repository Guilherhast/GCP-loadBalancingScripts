#!/bin/bash

CLOUDCMD=echo

PREFIX=web
if [[ -n $1 ]]; then PREFIX=$1; fi

# Get list of affected isntances
LIST=$( echo "$PREFIX"{1..3} | tr ' ' ',' )

# Create static ip
$CLOUDCMD compute addresses create network-lb-ip-1 \
	--region $REGION

# Create helh-check
$CLOUDCMD compute http-health-checks create basic-check

# Create a pool
$CLOUDCMD compute target-pools create www-pool \
  --region $REGION --http-health-check basic-check

# Add instances to list
$CLOUDCMD compute target-pools add-instances www-pool \
	--instances $LIST --zone=$ZONE

# Add forwarding rule
$CLOUDCMD compute forwarding-rules create www-rule \
    --region  $REGION \
    --ports 80 \
    --address network-lb-ip-1 \
    --target-pool www-pool

