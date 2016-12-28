#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";
use env;
use JSON;
use func qw(web_cgi);
use auth;
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $Get = $ENV{'QUERY_STRING'};
my $auth = new auth($user);
my $cgi = new web_cgi();
$cgi->hash($Get);
read (STDIN, $Post, $ENV{'CONTENT_LENGTH'});

if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}

open(OUT,">>/data/loginScreen/$cgi->{'vm'}") or die "FAILED";
print OUT "[Date: $env::year/$env::mon/$env::mday $env::hour:$env::min:$env::sec]\n";
print OUT $Post;
print OUT "END\n";
close(OUT);
print "{\"result\":\"SUCCESS\"}";
