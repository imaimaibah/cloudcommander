#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";

use env;
use JSON;
use auth;

my $user = $ENV{'AUTHENTICATE_UID'};
my $base_dir = $env::base_dir;
my $auth = new auth($user);
my $json = new JSON;
my $data = ();

open(IN,"/data/cgi-bin/billing_system_honbandesu/tables/currency.table") or die $!;
readline(IN);
my $i=0;
while(<IN>){
	chomp;
	s/\r//g;
	my @tmp = split(/,/);
	@{$data->[$i++]} = ($tmp[1],$tmp[2],$tmp[3]);
}
close(IN);

print $json->encode($data);
