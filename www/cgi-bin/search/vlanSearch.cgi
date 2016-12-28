#!/usr/bin/perl -I/usr/local/2nd_tools/lib

our $VERSION='2.0';

print "Content-type: application/json\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(validity web_cgi);
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Get);
my $data = ();
my $validity = new validity;

if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}elsif(!$validity->vsys($cgi->{'vsysid'}) and !$validity->org($cgi->{'vsysid'})){
	print "{\"result\":\"Invalid VSYS ID\"}";
	exit;
}else{
	$data->{'result'} = 'SUCCESS';
}

open(IN,"$base_dir/exp/vlansearch_vsys.exp $cgi->{'vsysid'}|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	if(/[A-Z0-9]{8}-[A-Z0-9]{9}/ or /[A-Z0-9]{8}/){
		my @tmp = $_ =~ /[^|\t\s]+/g;
		my ($island) = $tmp[3] =~ /[^-]+/g;
		$data->{'vlan'} = [$tmp[0],$tmp[1],$tmp[2],$island];
	}
}
close(IN);

if(ref($data->{'vlan'}) ne "ARRAY"){
	print "{\"result\":\"Not found\"}";
	exit;
}

open(IN,"$base_dir/exp/vlansearch_cnm.exp $data->{'vlan'}->[3] $data->{'vlan'}->[2]|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	my @s = /^[\s\t]*([^\s\t].+)[\s\t]*:[\s\t]*([^\s\t].+)[\s\t]*$/g; 
	if($s[0] =~ /Intranet-Connector Mode|VLAN ID|Intranet-Connector IPv4|Intranet-Connector IPv6/){
		push(@{$data->{'vlan'}},$s[1]);
	}
			
}
close(IN);

my $obj = new JSON();
print $obj->encode($data);
