#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";

use auth;
use JSON;
use func qw(web_cgi);
open(DEBUG,">/tmp/debug.log");

my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $json = new JSON();
my $cgi = new web_cgi();
my $GET = $ENV{'QUERY_STRING'};
$cgi->hash($GET);

my $hash = ();
print DEBUG $cgi->{'group'};

if($auth->_auth()){
	$auth = new auth();
	$auth->findGroup($cgi->{'group'});
	$hash->{'privilege'} = $auth->{'privilege'};
	$hash->{'ldap'} = $auth->{'ldap'};
}else{
	$hash->{'result'} = "Auth Failed";
}
print $json->encode($hash);
close(DEBUG);
