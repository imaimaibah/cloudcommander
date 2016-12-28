#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";
my $Post = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(validity web_cgi);
use auth;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Post);
my $i = 1;

if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}

#open(IN,"$base_dir/exp/sorry.exp" |) or die "FAILED!!";
#close(IN);
#system("$base_dir/exp/maintenance.exp start");
system("/tmp/sorry_dummy.sh");
$ret = $?;
$ret >> 8;

if($ret == 0 ){
	$data->[0]->{'result'} = "SUCCESS";
	$data->[0]->{'result1'} = "$user";
	$data->[0]->{'result2'} = "$ret";
  $data->[0]->{'result3'} = "$auth";
}else{
	$data->[0]->{'result'} = "FAILED";
  $data->[0]->{'result1'} = "$user";
  $data->[0]->{'result2'} = "$ret";
  $data->[0]->{'result3'} = "$auth";
}
my $obj = new JSON();
my $hash_json = $obj->encode($data);
print $hash_json;

