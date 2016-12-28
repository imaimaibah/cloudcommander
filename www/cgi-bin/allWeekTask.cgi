#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/xml\n\n";
my $Post = $ENV{'QUERY_STRING'};
my $user = $ENV{'AUTHENTICATE_UID'};
use auth;
my $auth = new auth($user);

if(!$auth->_auth()){
	print "Auth failed";
	exit;
}else{

open(IN,"curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' -H 'Authorization: Basic c29wdXNlcjptdG0hMDI1Ng==' 'http://vsys-ap:7902/vsys/services/Admin/allWeekTask?$Post' 2>/dev/null|") or die "FAILED!!";
while(<IN>){
	print;
}
close(IN);

}

