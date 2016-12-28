#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/xml\n\n";
read (STDIN, $Post, $ENV{'CONTENT_LENGTH'});

use audit qw(audit_web);
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $obj = new auth($user);
my $audit = new audit_web();

if(!$obj->_auth()){
	print "<Response><status>Auth failed</status></Response>\n";
}else{
	open(IN,"curl -X POST -H 'Content-Type: application/xml' -H 'Authorization: Basic c29wdXNlcjptdG0hMDI1Ng==' -d '$Post' 'http://vsys-ap:7902/vsys/services/Menu/setTemplate' 2>/dev/null|") or die "FAILED!!";
	while(<IN>){
  	print;
	}
	close(IN);
}
