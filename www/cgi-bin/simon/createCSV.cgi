#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");
print "Content-type: application/json\n\n";

use JSON;
use func qw(web_cgi);
my $cgi = new web_cgi;
my $Get = $ENV{'QUERY_STRING'};
my $json = new JSON;
my $hash = ();
$cgi->hash($Get);
open(OUT,">/data/download/$cgi->{'name'}");

while(<STDIN>){
	$hash = $json->decode($_);
	foreach my $val1(@{$hash->{'data'}}){
		foreach my $val2(@$val1){
			print OUT $val2.",";
		}
			print OUT "\r\n";
	}
	close(OUT);
}
print "{\"file\":\"$cgi->{'name'}\"}";
close(DEBUG);
