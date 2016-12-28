#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use JSON;
use auth;
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $data = ();
open(DEBUG,">/tmp/debug.log");

print "Content-type: application/json\n\n";
read (STDIN, $Post, $ENV{'CONTENT_LENGTH'});

#while(<STDIN>){
	#chomp;
	my @tmp = split(/=/,$Post);
	open(OUT,"|$base_dir/exp/resetLDAPAccount.exp");
	$tmp[1] =~ s/%([0-9A-Fa-f]{2})/pack('H2', $1)/eg;
	print OUT "$user,$tmp[1]\n";
	close(OUT);
#}

$data->{'result'} = "SUCCESS";
my $obj=new JSON();

print $obj->encode($data);
close(DEBUG);
