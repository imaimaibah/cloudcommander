#!/usr/bin/perl -I/usr/local/2nd_tools/lib

#open(DEBUG, ">/tmp/debug.log");
use env;
use JSON;
use auth;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
#my $data = ();
#open(DEBUG,">/tmp/debug.log");
my $cgi = new web_cgi;

my $auth = new auth($user);

my $Get = $ENV{'QUERY_STRING'};
$cgi->hash($Get);

print "Content-type: text/html\n\n";

#if(!$auth->_auth()){
#  print "Auth failed";
#  exit;
#}

my $dom0 = $cgi->{'dom0'};

##### DELETE ######
#my $dom0 = 'jp-01-1-ps0000-08-02';
##################

system("$base_dir/exp/log_collect/pcl_check.exp $dom0");

open(OUT, "/tmp/pcl_check");
	while(<OUT>){
		chomp;
		s/\r//g;
		print "$_";
	}
close(OUT);
#close(DEBUG);
