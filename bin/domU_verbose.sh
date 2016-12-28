#!/bin/bash

. "/usr/local/2nd_tools/lib/env.sh"
. "$BASEDIR/lib/func.sh"

DOM0=$1

$BASEDIR/pl/make_data.pl

awk -F, '$3=="'"$DOM0"'" {print $1}' $BASEDIR/tmp/raw/dat.csv
