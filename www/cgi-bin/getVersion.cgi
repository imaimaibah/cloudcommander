#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/xml\n\n";
my $Post = $ENV{'QUERY_STRING'};

my @tmp1=split(/&/,$Post);
my $ver;
my $option;

foreach my $j(@tmp1){
	my @tmp2 = split(/=/,$j);
	if($tmp2[0] eq "serviceList"){
		$ver = $tmp2[1];
	}elsif($tmp2[0] eq "tm"){
		$optin = $tmp2[1];
	}
}

my $user = $ENV{'AUTHENTICATE_UID'};
use auth;
my $auth = new auth($user);

if(!$auth->_auth()){
	print "Auth failed";
	exit;
}else{
	open(IN,"curl -X POST -H 'Content-Type: application/x-www-form-urlencoded' -H 'Authorization: Basic c29wdXNlcjptdG0hMDI1Ng==' 'http://vsys-ap:7902/vsys/services/$ver/getVersion?tm=$option' 2>/dev/null|") or die "FAILED!!";
	while(<IN>){
		print;
	}
	close(IN);
}
