#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

use env;
use func qw(web_cgi);
use auth;
use JSON;
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $Get = $ENV{'QUERY_STRING'};
my $cgi=new web_cgi;
$cgi->hash($Get);
my $json = new JSON();

my $data = ();

if(!$auth->_auth()){
	print "Content-type: text/plain\n\n";
	print "Auth failed";
	exit;
}

print "Content-type: text/plain\n\n";
my $vm = $cgi->{'vm'};
my $dom0 = $cgi->{'dom0'};
my $user = $ENV{'AUTHENTICATE_UID'};
$cgi->{'password'} =~ s/%([0-9A-Fa-f]{2})/pack('H2', $1)/eg;
my $password = $cgi->{'password'};

if($vm ne ""){
	my $ttl = $vm.".ttl";
	open(OUT,">/data/download/$ttl") or die "FAILED!!";
	print OUT <<EOF;
timeout = 5
connect '$env::ent_centos /ssh /auth=password /user=$user /passwd=$password'
waitregex "\\\$ "
sendln "ssh root\@$dom0"
waitregex "password" "\\\(yes/no\\\)"
if result=0 then
	messagebox "TIMEOUT" "Cloud Commander"
	exit
elseif result=1 then
	sendln "sr\@01011"
elseif result=2 then
	sendln "yes"
	waitregex "password"
	sendln "sr\@01011"
else
	messagebox "Could not connect." "Cloud Commander"
endif
waitregex "# "
sendln "xm console $vm"
sendln
EOF
	close(OUT);
	print $ttl;

}else{
	my $ttl = $dom0.".ttl";
	open(OUT,">/data/download/$ttl") or die "FAILED!!";
	print OUT <<EOF;
timeout = 5
connect '10.3.0.130 /ssh /auth=password /user=$user /passwd=$password'
waitregex "\\\$ "
sendln "ssh root\@$dom0"
waitregex "password" "\\\(yes/no\\\)"
if result=0 then
	messagebox "TIMEOUT" "Cloud Commander"
	exit
elseif result=1 then
	sendln "sr\@01011"
elseif result=2 then
	sendln "yes"
	waitregex "password"
	sendln "sr\@01011"
else
	messagebox "Could not connect." "Cloud Commander"
endif
waitregex "# "
EOF
	close(OUT);
	print $ttl;
}

close(DEBUG);
