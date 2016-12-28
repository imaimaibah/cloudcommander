#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

use env;
use func qw(web_cgi);
use audit;
use auth;
use JSON;

print "Content-type: application/json\n\n";

my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $Get = $ENV{'QUERY_STRING'};
my $cgi = new web_cgi();
my $auth = new auth($user);
my $audit = new audit();
my $json = new JSON();
$cgi->hash($Get);
read (STDIN, $Post, $ENV{'CONTENT_LENGTH'});

my $data = ();

if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
}else{
	my $to = $cgi->{'to'};
	my $hash = $json->decode($Post);
	my ($type) = keys(%$hash);
	my @domU = @{$hash->{$type}};
	foreach my $j(@domU){
		print DEBUG $j."\n";
	}
	$data->{'result'} = "SUCCESS";
}

print $json->encode($data);
close(DEBUG);
