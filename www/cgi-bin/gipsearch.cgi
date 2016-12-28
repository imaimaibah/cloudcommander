#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";
my $Post = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(validity web_cgi);
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Post);
my $data = ();
my $i = 1;
if($cgi->{'gip'} eq "ALL"){
	$cgi->{'gip'} = "";
}

if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}


open(IN,"$base_dir/exp/search_vsys_gip.exp $cgi->{'gip'}|") or die "FAILED!!";
while(<IN>){
	chomp;
	s/\r//g;
	if(/[A-Z0-9]{8}/){
		my @tmp = /[:A-Z0-9.-]+/g;
		$data->[$i]->{'org_id'} = $tmp[0];
		$data->[$i]->{'vsys_id'} = $tmp[1];
		$data->[$i]->{'server_id'} = $tmp[2];
		$data->[$i]->{'gip'} = $tmp[3];
		$data->[$i]->{'status'} = $tmp[4];
		$data->[$i]->{'entry'} = $tmp[5]." ".$tmp[6];
		$data->[$i]->{'update'} = $tmp[7]." ".$tmp[8];
		$i++;
	}
}
close(IN);

if($data ne ""){
	$data->[0]->{'result'} = "SUCCESS";
}else{
	$data->[0]->{'result'} = "FAILED";
}
my $obj = new JSON();
my $hash_json = $obj->encode($data);
print $hash_json;

