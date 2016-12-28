#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: application/json\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use auth;
use JSON;
use func qw(web_cgi);
my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Get);
my $cmd;
my $func;
my $obj = new JSON();
my $data = [];
my $domu=[];
my $user = $ENV{'AUTHENTICATE_UID'};
#### DELETE BELOW LINE #####
#$cgi->{'dom0'} = "jp-01-1-ps0000-08-11";
############################
#my $auth = new auth($user);
#if(!$auth->_auth()){
#	print "{\"result\":\"Auth failed\"}";
#	exit;
#}
main($cgi->{'dom0'},$data,$domu);

my $all = {};
$all->{'raid'} = $data;
$all->{'domu'} = $domu;

print $obj->encode($all);

sub main($$){
	my $dom0 = shift;
	my $data = shift;
	my $domu = shift;

	my $i = 0;
	my $ii = 0;
	open(IN, "$base_dir/exp/resource/serverview_cmd.exp $dom0|") or die "FAILED!!";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/^=========================/){
			$i++;
			$ii = 0;
			next;
		}elsif(/^========XM LIST ========/){
			last;
		}elsif(/Partition|Properties/){
			next;
		}
		my @tmp = split(/:/);
		foreach my $l(@tmp){
			$l=~s/^\s+//;
			$l=~s/\s+$//;
		}

		@{$data->[$i]->[$ii++]}=($tmp[0], $tmp[1]);
	}

	while(<IN>){
		chomp;
		s/\r//g;
		push(@$domu,$_);
	}
	close(IN);

}


close(DEBUG);
