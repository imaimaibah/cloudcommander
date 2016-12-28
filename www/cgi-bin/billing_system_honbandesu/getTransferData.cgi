#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";
use env;
use JSON;
use func qw(web_cgi);
my $cgi = new web_cgi;
my $Get = $ENV{'QUERY_STRING'};
$cgi->hash($Get);
my $obj = new JSON;

my $prefix = $cgi->{'prefix'};

my $transfer = ();
my $currency = ();
my $hostlead = ();

my $i=0;
open(IN,"/data/cgi-bin/billing_system_honbandesu/tables/currency.table") or die "FAILED";
while(<IN>){
	chomp;
	my @tmp = split(/,/);
	@{$currency->[$i++]} = @tmp;
}
close(IN);

for(my $l=1;$l<@$currency;$l++){
	my $prefix = $currency->[$l]->[1];
	$i=0;
	open(IN,"/data/cgi-bin/billing_system_honbandesu/tables/transfer_price_$prefix.table") or die "FAILED";
	while(<IN>){
		chomp;
		my @tmp = split(/,/);
		@{$transfer->{$prefix}->[$i++]} = @tmp;
	}
}
close(IN);


my $all=();
$all->{'transfer'} = $transfer;
$all->{'currency'} = $currency;
print $obj->encode($all);
