#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: application/json\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(validity web_cgi);
use auth;
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $cgi = new web_cgi;
$cgi->hash($Get);
my $data = ();
my $obj =  new JSON();

if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
	print $obj->encode($data);
	exit;
}

my $VSYSID = $cgi->{'vm'};
$VSYSID =~ s/-S-[0-9]{4}//;
my @island;

open(IN,"$base_dir/exp/getVMDetail.exp $cgi->{'vm'}|") or die "FAILED!!";
while(<IN>){
	chomp;
	s/\r//g;
	if(/[A-Z0-9]{8}-[A-Z0-9]{9}-S-/){
		my @tmp = $_ =~ /[^\s|]+/g;
print DEBUG "$tmp[0]\n";
		$data->{'server_name'} = $tmp[0];
		$data->{'type'} = $tmp[1];
		$data->{'resource_status'} = $tmp[2];
		$data->{'os_type'} = $tmp[4];
		@island = split(/_/,$tmp[3]);
	}
}
close(IN);

$data->{'island'} = $island[0];
$data->{'island'} =~ s/island//;
$data->{'island'} =~ s/-cbrm//;
$data->{'island'} = uc($data->{'island'});

open(IN, "$base_dir/exp/search_vm.exp $cgi->{'vm'} $island[0]|") or die "FAILED!!";
while(<IN>){
	chomp;
	#if(/LServer name="(.*?)"/){
	#	$data->{'server_name'} = $1;
	#}elsif(/VmHost name="(.*?)"/){
	if(/VmHost name="(.*?)"/){
		$data->{'dom0'} = $1;
	#}elsif(/TemplateLink name="(.*?)"/){
	#	$data->{'type'} = $1;
	#}elsif(/<ResourceStatus>(.*?)<\/ResourceStatus>/){
	#	$data->{'resource_status'} = $1;
	#}elsif(/<PowerStatus>(.*?)<\/PowerStatus>/){
	#	$data->{'power_status'} = $1;
	}elsif(m!</LServer>!){
		last;
	}
}
close(IN);


if($data ne ""){
	$data->{'result'} = "SUCCESS";
} else {
	$data->{'result'} = "FAILED";
}

my $hash_json = $obj->encode($data);

print DEBUG $hash_json;

print $hash_json;

