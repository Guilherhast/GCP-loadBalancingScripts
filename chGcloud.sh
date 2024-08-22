#!/bin/bash

FILE=$1

if  [ -z $1 ]; then echo "No file set" && exit; fi

for FILE in $*; do
	echo $FILE
	sed -i '1,5s/CLOUDCMD=echo/CLOUDCMD=gcloud/' $FILE
	sed -i '1,5s/URLCMD=echo/URLCMD=curl/' $FILE
done
