#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/xml\n\n";
my $Post = $ENV{'QUERY_STRING'};

use env;
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $obj = new auth($user);

if(!$obj->_auth()){
	print "<Response><status>Auth failed</status></Response>\n";
}else{
	open(IN,"curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' -H 'Authorization: Basic c29wdXNlcjptdG0hMDI1Ng==' 'http://vsys-ap:7902/vsys/services/Menu/getTemplate?$Post' 2>/dev/null|") or die "FAILED!!";

	while(<IN>){
		print;
	}
	close(IN);
}

