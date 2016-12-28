#!/bin/bash

function use(){
	echo $0 ORGID USERID
}

if [ "$1" == "" ];then
	echo "ORG ID is empty"
	use
	exit
fi

if [ "$2" == "" ];then
	echo "User ID is empty"
	use
	exit
fi

ORG=$1
User=$2

URL="http://acctrl/sopac/authority/operation?organizationId=$ORG&userId=$User"
curl -X GET --http1.0  "$URL"
