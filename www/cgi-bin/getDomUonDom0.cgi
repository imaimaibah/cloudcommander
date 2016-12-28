#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use audit qw(audit_web);
use auth;
use env;
use JSON;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $Post = $ENV{'QUERY_STRING'};
my $cgi = new web_cgi();
$cgi->hash($Post);

my $obj = new auth($user);
my $audit = new audit_web();
my $data = ();

print "Content-type: application/xml\n\n";

if(!$obj->_auth()){
	$data->{'result'} = "Auth failed";
}else{
	open(IN,"$base_dir/exp/getDomUonDom0.exp $cgi->{'primergy'}|") or die "FAILED";
	my $i = 0;
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		if($tmp[1] ne ""){
			@{$data->[$i++]->{$tmp[0]}} = ($tmp[1],$tmp[2]);
		}else{
			$data->{'result'} = "ERROR";
		}
		
	}
	close(IN);
}

my $obj = new JSON();
my $hash_json = $obj->encode($data);
print $hash_json;
