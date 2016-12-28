#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use JSON;
use auth;

my $data = ();
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);

print "Content-type: application/json\n\n";

if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}

open(IN,"$env::base_dir/exp/florent/get_user-mgmt_user-list.exp|") or die $!;
while(<IN>){
	chomp;
	s/\r//g;
	if(/[0-9A-Z]{8}/){
		my @tmp = $_ =~ /[^\s|]+/g;
		$data->{$tmp[1]} = [$tmp[0]];
	}
}
close(IN);

open(IN,"$env::base_dir/exp/florent/get_secure_user-list.exp|") or die $!;
while(<IN>){
	chomp;
	s/\r//g;
	my @tmp = $_ =~ /[^\s|]+/g;
	if(exists($data->{$tmp[0]})){
		my $userID = shift(@tmp);
		foreach my $l(@tmp){
			push(@{$data->{$userID}},$l);
		}
	}
}
close(IN);

my $obj = new JSON;
print $obj->encode($data);
