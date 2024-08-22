#!/bin/bash

IP=''
echo $1
if [[ -n $1 ]]; then IP=$1; fi
if [[ -z $IP ]]; then
	echo "No IP"
	exit; 
fi


for i in {1..80}; do
	curl $IP
done
