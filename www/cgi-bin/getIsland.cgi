#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use JSON;
use audit qw(audit_web);
use auth;

my $user = $ENV{'AUTHENTICATE_UID'};
my $obj = new JSON();
my $audit = new audit_web();
my $auth = new auth($user);
my $data=();

print "Content-type: application/json\n\n";


if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}\n";
} else {
	open(IN,"curl -X GET -H 'Content-Type: application/x-www-form-urlencoded' -H 'Authorization: Basic c29wdXNlcjptdG0hMDI1Ng==' 'http://vsys-ap:7902/vsys/services/Menu/get?userId=vsysadmin' 2>/dev/null|") or die "FAILED!!";
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = $_ =~ m!<island><id>(.+?)-cbrm</id>!g;
		@{$data->{'island'}} = @tmp;
	}
	close(IN);

	print $obj->encode($data);
	my $log = <<EOF;
$ENV{'REQUEST_URI'}
EOF
	$audit->log($user,$log);
}
