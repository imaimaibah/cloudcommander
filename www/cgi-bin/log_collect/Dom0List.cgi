#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

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
my $dom0 = [];

my $auth = new auth($user);

print "Content-type: text/plain\n\n";

my $cgi = new web_cgi();
$cgi->hash($Get);
my $island = $cgi->{'island'};

#if(!$auth->_auth()){
#	print "{\"result\":\"Auth failed\"}";
#	exit;
#}

##### Delete #####
#my $island = region;
#my $island = islanda;
#my $island = islandb;
#################

if($island eq 'region'){
	$island = 'all | grep ps0000 | sort';
} else {
	$island = $island.'| sort';
}

my $i=0;
open(IN, "$base_dir/exp/node_list.exp $island|") or die "FAILED!!";
while(<IN>){
	chomp;
	s/"//g;
	s/\r//g;
	my @tmp = split(/,/);

	if($tmp[0] =~ /ps[0-9]{4}-[0-9]{2}-[0-9]{2}$/){
		push(@{$dom0->[$i]->{'dom0'} = @tmp[0], $dom0->[$i]->{'ip'} = @tmp[1]});
#		push(@{$tmp->[$i]->{'dom0'} = @tmp[0], $tmp->[$i]->{'ip'} = @tmp[1]});
#		@{$dom0->[$i++]->{'ip'}} = @tmp[1];
#		push (@{$dom0}, @{$dom0->[$i++]->{'ip'} = @tmp[1]});
#		$dom0->[$i++]->{$tmp[0]}->[0] = $tmp[1];
#		push (@{$tmp->{$tmp[0]}},$tmp[1]);
#		@{$tmp->{$tmp[0]}} = @tmp;
		$i++;
	}
}
	close(IN);

#	foreach my $tmp2(sort(keys(%$tmp))){
#		$dom0->[$i++]->{$tmp2} = $tmp -> {$tmp2}; 
#	}

print $json->encode($dom0);

close(DEBUG);
