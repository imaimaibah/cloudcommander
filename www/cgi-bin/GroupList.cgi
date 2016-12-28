#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use auth;
use JSON;

my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $json = new JSON();
my $hash;
my $data = ();

print "Content-type: application/json\n\n";
if($auth->_auth()){
	$auth->groupList();
	@{$data} = sort {$a cmp $b} @{$auth->{'groups'}};
}else{
	$auth->{'groups'}->{'result'} = "Auth failed";
}
#$hash = $json->encode($auth->{'groups'});
$hash = $json->encode($data);
print $hash;
