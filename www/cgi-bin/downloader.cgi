#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use JSON;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $Post = $ENV{'QUERY_STRING'};
my $cgi = new web_cgi;
$cgi->hash($Post);
my $path = '/data/download/' . $cgi->{'download'};
my $size = -s $path;
if($cgi->{'download'} eq ''){
	print "Content-Type: text/html\n\n";
}else{
	print "Content-Type: application/octet-stream\n";
	print "Content-Disposition: attachment; filename=".$cgi->{'download'}."\n";
	print "Content-Length: $size\n\n";

	open(IN,"$path");
	while(<IN>) {
		print;
	}
	close(IN);
}
