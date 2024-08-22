#!/bin/bash

CLOUDCMD=echo
URLCMD=echo

PREFIX=web
if [[ -n $1 ]]; then PREFIX=$1; fi

function getFromIp(){
	INSTANCE=$1

	NATIP=$( $CLOUDCMD compute instances describe $INSTANCE \
		--format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone=$ZONE )

	EXTIP=$( $CLOUDCMD compute instances describe $INSTANCE \
		--format='get(networkInterfaces[0].networkIP)' --zone=$ZONE )

	echo "Nat"
	$URLCMD -m5 http://$NATIP ; echo
	echo "EXTIP"
	$URLCMD -m5 http://$EXTIP ; echo
}

EXECFUNC=getFromIp
for name in "$PREFIX"{1..3}; do
	echo Doing for $name
	$EXECFUNC $name
done
