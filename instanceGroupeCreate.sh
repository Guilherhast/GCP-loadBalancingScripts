#!/bin/bash

CLOUDCMD=echo
#CLOUDCMD=gcloud

#PREFIX=www
PREFIX=web

if [[ -n $1 ]]; then PREFIX=$1; fi
echo $1

$CLOUDCMD compute instance-groups managed create \
	lb-backend-group \ --template=lb-backend-template \
	--size=2 --zone=$ZONE

$CLOUDCMD compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80


$CLOUDCMD compute addresses create lb-ipv4-1 \
  --ip-version=IPV4 \
  --global

$CLOUDCMD compute addresses describe lb-ipv4-1 \
  --format="get(address)" \
  --global

$CLOUDCMD compute health-checks create http \
	http-basic-check --port 80


$CLOUDCMD compute backend-services create web-backend-service \
  --protocol=HTTP --port-name=http \
  --health-checks=http-basic-check \
  --global

$CLOUDCMD compute backend-services add-backend \
	web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone=$ZONE \
  --global

$CLOUDCMD compute url-maps create web-map-http \
    --default-service web-backend-service


$CLOUDCMD compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http


$CLOUDCMD compute forwarding-rules create http-content-rule \
   --address=lb-ipv4-1\
   --global \
   --target-http-proxy=http-lb-proxy \
   --ports=80





