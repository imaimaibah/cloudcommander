#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";
my $Post = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(web_cgi);
use auth;
my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Post);
my $data = ();
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);

#Delete below before deploy#
#$cgi->{'eternus'} = "10.1.1.5";
############################
if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}

main($cgi->{'eternus'});

sub main($){
	my $eternus = shift;

open(IN, "$base_dir/exp/eternus_events.exp $eternus|") or die "FAILED!!";

my $i=0;
while(<IN>){
	chomp;
	s/\r//g;
	if(/User .* Logged/){
		next;
	}elsif($i < 20){
		print;
		print "\n";
		$i++;
	}
}
close(IN);
}

