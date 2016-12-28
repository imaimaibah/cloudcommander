#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: text/html\n\n";

use env;
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $base_dir = $env::base_dir;

if(!$auth->_auth()){
	print "Auth failed";
	exit;
}

open(IN,"$base_dir/exp/getGIP.exp |");
while(<IN>){
 	print;
}
close(IN);
