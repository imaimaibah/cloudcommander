#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: text/plain\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(web_cgi);
use auth;
use POSIX ":sys_wait_h";
my $base_dir = $env::base_dir;
my $serverview = ();
my $user = $ENV{'AUTHENTICATE_UID'};
my $Get = $ENV{'QUERY_STRING'};
my $json = new JSON();
my $data = ();
my $auth = new auth($user);
if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}

my $cgi = new web_cgi();
$cgi->hash($Get);

##### DELETE BELOW LINES #####
$cgi->{'server'} = "jp-01-1-ps0000-08-14";
$cgi->{'disk'} = "33/4";
##############################

system("$base_dir/exp/resource/diskDetach.exp $cgi->{'server'} $cgi->{'disk'}");
my $ret=$?;
$ret>>8;
if($ret eq 0){
	print "{\"result\":\"Done\"}";
}
