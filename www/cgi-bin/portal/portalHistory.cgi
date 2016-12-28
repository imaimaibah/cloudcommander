#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use audit qw(audit_web);
use auth;
use func qw(validity);
use JSON;
use env;
use sdm::local_contents_web;
print "Content-type: application/json\n\n";

my $user = $ENV{'AUTHENTICATE_UID'};
my $base_dir = $env::base_dir;
my $Get = $ENV{'QUERY_STRING'};
my $auth = new auth($user);
my $cgi = new web_cgi();
my $json = new JSON();
my $data = {};

$cgi->hash($Get);

#if($cgi->{'page'} eq "sorry"){
if(1){
	sorry($data);
	@{$data->{'history'}} = sort { $a <=> $b } @{$data->{'history'}};
	print $json->encode($data);
}

sub sorry(){
	my $data = shift;
	my @file = glob("/data/local_contents/portal/sorry.html-*");

	foreach my $file(@file){
		my ($tmp) = $file =~ /sorry\.html-(.*)$/g;
		push(@{$data->{'history'}},$tmp);
	}
	
}

