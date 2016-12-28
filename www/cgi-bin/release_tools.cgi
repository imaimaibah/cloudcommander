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

if($cgi->{'argu'} eq "status"){
	system("/tmp/sorry_dummy1.sh");  
}elsif($cgi->{'argu'} eq "start"){
 system("/tmp/sorry_dummy2.sh");
}else{
	if($cgi->{'argu'} eq "stop"){
  	system("/tmp/sorry_dummy3.sh");
	}elsif($cgi->{'argu'} eq "mstatus"){
 		system("/tmp/sorry_dummy4.sh");
	}else{
  	if($cgi->{'argu'} eq "mstart"){
    	system("/tmp/sorry_dummy5.sh");
  	}elsif($cgi->{'argu'} eq "mstop"){
    	system("/tmp/sorry_dummy6.sh");
  	}else{
		}
	}
}

$ret = $?;
$ret >> 8;

if($ret == 0 ){
	$data->[0]->{'result'} = "SUCCESS";
}else{
	$data->[0]->{'result'} = "FAILED";
}

$data->[0]->{'argu'} = $cgi->{'argu'};

my $obj = new JSON();
my $hash_json = $obj->encode($data);
print $hash_json;

