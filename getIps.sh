#!/bin/bash

CLOUDCMD=echo
URLCMD=echo

PREFIX=web
if [[ -n $1 ]]; then PREFIX=$1; fi

function getFromIp(){
	INSTANCE=$1

	NATIP=$( $CLOUDCMD compute instances describe $INSTANCE \
		--format='get(networkInterfaces[0].accessConfigs[0].natIP)' )

	EXTIP=$( $CLOUDCMD compute instances describe instance-name \
		--format='get(networkInterfaces[0].networkIP)' )

	echo "Nat"
	$URLCMD http://$NATIP ; echo
	echo "EXTIP"
	$URLCMD http://$EXTIP ; echo
}

EXECFUNC=getFromIp
for name in "$PREFIX"{1..3}; do
	echo Doing for $name
	$EXECFUNC $name
done
