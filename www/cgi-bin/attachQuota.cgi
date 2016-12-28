#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use audit qw(audit_web);
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $obj = new auth($user);
my $audit = new audit_web();

print "Content-type: application/xml\n\n";
read (STDIN, $Post, $ENV{'CONTENT_LENGTH'});

if(!$obj->_auth()){
	print "<Response><status>Auth failed</status></Response>\n";
}else{
	open(IN,"curl -X POST -H 'Content-Type: application/xml' -H 'Authorization: Basic c29wdXNlcjptdG0hMDI1Ng==' -d '$Post' 'http://vsys-ap:7902/vsys/services/Quota/attach' 2>/dev/null|") or die "FAILED!!";
	while(<IN>){
 	 print;
	}
	close(IN);
	my $log = <<EOF;
$ENV{'REQUEST_URI'}
$Post
EOF
	$audit->log($user,$log);
}