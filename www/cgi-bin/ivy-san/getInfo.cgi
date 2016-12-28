#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: application/json\n\n";

use env;
use JSON;
use auth;
use func(web_cgi);

my $user = $ENV{'AUTHENTICATE_UID'};
my $Get = $ENV{'QUERY_STRING'};
my $base_dir = $env::base_dir;
my $auth = new auth($user);
my $json = new JSON;
my $cgi = new web_cgi();
my $data = ();

$cgi->hash($Get);


open(IN,"/data/cgi-bin/billing_system_honbandesu/tables/host_lead_$cgi->{'code'}.table") or die $!;

my $line = readline(IN);
chomp($line);
$line =~ s/\r//g;
my @header = split(/,/,$line);

while(<IN>){
	chomp;
	s/\r//g;
	my @tmp = split(/,/);
	@{$data->[shift(@tmp)]} = @tmp;
}
close(IN);

unshift(@$data,[@header]);

print $json->encode($data);

close(DEBUG);
