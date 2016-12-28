#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

use auth;
use JSON;
use env;

my $base_dir = $env::base_dir;

my $user = $ENV{'AUTHENTICATE_UID'};
my $ip = $env::ipcom;
my $auth = new auth($user);
my $json = new JSON();
my $hash;
my $data = ();

print "Content-type: application/json\n\n";
if($auth->_auth()){
	$auth->userList();
	open(OUT,"|$base_dir/exp/validitySSLAccount.exp $ip >/tmp/account") or die "FAILED!!";
	foreach my $user(@{$auth->{'users'}}){
		print OUT "$user->[1]\n";
	}
	close(OUT);

	open(IN,"/tmp/account") or die "FAILED!!";
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		foreach my $user(@{$auth->{'users'}}){
			if($user->[1] eq $tmp[0]){
					$user->[3] = $tmp[1];
			}
		}
	}
	close(IN);
	unlink("/tmp/account");
	@{$data} = sort {$a->[1] cmp $b->[1]} @{$auth->{'users'}};
}else{
	$auth->{'users'}->{'result'} = "Auth failed";
}

#$hash = $json->encode($auth->{'users'});
$hash = $json->encode($data);
print $hash;
close(DEBUG);
