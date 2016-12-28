#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;

my $currency=();
my $orglead=();

my $i=0;
open(IN,"/data/cgi-bin/billing_system_honbandesu/tables/currency.table") or die "FAILED";
while(<IN>){
	chomp;
	my @tmp = split(/,/);
	@{$currency->[$i++]} = @tmp;
}
close(IN);

open(IN,"/data/cgi-bin/billing_system_honbandesu/tables/host_lead.table") or die "FAILED";
while(<IN>){
	chomp;
	my @tmp = split(/,/);
	@{$orglead->[$i++]} = @tmp;
}
close(IN);

