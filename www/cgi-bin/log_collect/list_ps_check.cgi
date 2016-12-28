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

my $sedai = $cgi->{'sedai'};
my $ps_num = $cgi->{'ps_num'};
my $island = $cgi->{'island'};

##### DELETE ######
#my $sedai = 1;
#my $opeType = 7;
##################

system("$base_dir/exp/log_collect/ps_check.exp $sedai $ps_num $island");

open(OUT, "/tmp/ps_result$sedai$ps_num");
	while(<OUT>){
		chomp;
		s/\r//g;
		print "$_";
	}
close(OUT);
#close(DEBUG);
