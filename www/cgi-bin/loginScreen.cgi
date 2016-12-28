#!/usr/bin/perl -I/usr/local/2nd_tools/lib
open(DEBUG,">/tmp/debug.log");

print "Content-type: text/plain\n\n";
my $Post = $ENV{'QUERY_STRING'};

use env;
use JSON;
use auth;
use func qw(web_cgi);
my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Post);
my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);
my $data = ();

#Delete below before deploy#
#$cgi->{'eternus'} = "10.1.1.5";
############################

if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
	exit;
}

if($cgi->{'dom0'} ne "undefined"){
	main($cgi->{'vm'},$cgi->{'dom0'},$cgi->{'password'});
}else{
	get($cgi->{'vm'});
}

sub main($$$){
	my $vm = shift;
	my $dom0 = shift;
	my $passwd = shift;

	open(IN, "$base_dir/exp/loginScreen.exp $vm $dom0 $passwd|") or die "FAILED!!";

	my $i=0;
	while(<IN>){
		chomp;
		s/\r//g;
		print;
		print "\n";
	}
	close(IN);
}

sub get($){
	my $vm = shift;
	if(-e "/data/loginScreen/$vm"){
		open(IN,"/data/loginScreen/$vm") or die "FAILED";
		my $line;
		while(<IN>){
			if(/^\[Date: [0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]$/){
				$line = $_;
				while(<IN>){
					if(/^END$/){
						last;
					}else{
						$line .= $_;
					}
				}
			}
		}
		print $line;
		close(IN);
	}else{
		print "Past Login Screen doesn't exist";
	}
}
close(DEBUG);
