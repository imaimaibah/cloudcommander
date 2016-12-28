#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use audit qw(audit_web);
use auth;
use JSON;
use env;

my $user = $ENV{'AUTHENTICATE_UID'};
my $base_dir = $env::base_dir;
my $ip = "10." . ($env::region_base + 3) . ".1.40";
### DEETE BELOW LINE ####
$ip = '10.3.1.200';
#########################
my $auth = new auth($user);
my $audit = new audit_web();
my $json = new JSON();
my $data = ();

print "Content-type: application/json\n\n";

if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
}else{
	open(IN,"$base_dir/exp/showLDAPUser.exp |") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		s/mail: //g;
		if(/@.*fujitsu.com/){
			push(@{$data->{'userList'}},$_);
		}
	}
	close(IN);
	$data->{'result'} = "SUCCESS";
}

print $json->encode($data);
