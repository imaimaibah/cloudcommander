#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use billing;

system("rm -rf /data/cgi-bin/billing_system_honbandesu/invoice/*");

my @region = ("AUS","SIN","USA","UKI","DEU");

foreach $region(@region){
my $bill = new billing($region);

$bill->calc();

$bill->invoice();

}

my $bill = new billing("DEU");

$bill->gachanco();

$bill->invoiceTotal();

$bill->invoiceHTML();


