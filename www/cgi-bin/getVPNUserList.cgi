#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");
use audit qw(audit_web);
use auth;
use JSON;
use env;

my $user = $ENV{'AUTHENTICATE_UID'};
my $base_dir = $env::base_dir;
my $ip = $env::ipcom;
my $auth = new auth($user);
my $audit = new audit_web();
my $json = new JSON();
my $data = ();

print "Content-type: application/json\n\n";

if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
}else{
	$auth->userList();
	@{$data->{'userList'}} = sort {$a->[1] cmp $b->[1]} @{$auth->{'users'}};
	my $log = <<EOF;
$ENV{'REQUEST_URI'}
EOF
	$data->{'result'} = "SUCCESS";
	$audit->log($user,$log);
}

print $json->encode($data);
close(DEBUG);
