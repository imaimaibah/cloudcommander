#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use billing;

my $bill = new billing("DEU");
$bill->FoC();
