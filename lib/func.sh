#!/bin/bash

function validityVSYS(){
	VSYS=$1
	echo $VSYS | grep -E '^[A-Z0-9]{8}-[A-Z0-9]{9}$' > /dev/null 2>&1
	RET=$?

return $RET
}

function validityVM(){
	VM=$1
	echo $VM | grep -E '^[A-Z0-9]{8}-[A-Z0-9]{9}-S-[0-9]{4}$' > /dev/null 2>&1
	RET=$?

return $RET
}
