#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use JSON;
use auth;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $data = ();
open(DEBUG,">/tmp/debug.log");
my $cgi = new web_cgi;
my $Get = $ENV{'QUERY_STRING'};
$cgi->hash($Get);

print "Content-type: application/json\n\n";

system("test.exp $cgi->{'island'} $cgi->{'type'}");



print "$cgi->{'island'}";

