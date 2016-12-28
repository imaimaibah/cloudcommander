#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: text/plain\n\n";

use env;
use JSON;
use func qw(web_cgi);
use auth;
use POSIX "sys_wait_h";
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $Get = $ENV{'QUERY_STRING'};
my $json = new JSON();
my $data = [];
my $auth = new auth($user);
my $orgId = $cgi->{'orgId'};

#if(!$auth->_auth()){
#	print "Auth failed";
#	exit;
#}

#### Delete ####
#my $orgId = ZNSZH72Y;
#my $orgId = "";
#### Delete ####

my $cgi= new web_cgi();
$cgi->hash($Get);

my $i = 0;
if($orgId eq ""){
	open(IN,"$base_dir/exp/activate/contract-info_list.exp|") or die "FAILED!!";
	while(<IN>){
		chomp;
		s/"//g;
		s/\r//g;
		my @tmp = split(/,/);

		push (@{$tmp->{$tmp[0]}->{$tmp[1]}->{$tmp[2]}}, $tmp[3], $tmp[4]);
	}
	close (IN);

		foreach my $tmp2(sort(keys(%$tmp))){
			$data->[$i++]->{$tmp2} = $tmp -> {$tmp2};
		}
	print $json->encode($data);
} else {
	open(OUT,"$base_dir/exp/activate/contract-info_list.exp $orgId|") or die "FAILED!!";
	while(<OUT>){
		chomp;
		s/"//g;
		s/\r//g;
		my @tmp = split(/,/);
		push (@{$tmp->{$tmp[0]}},$tmp[1]);
	}
	close(OUT);
	print $json->encode($tmp);
}

close(DEBUG);
