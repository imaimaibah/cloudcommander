#!/usr/bin/perl -I/usr/local/2nd_tools/lib
#open(DEBUG,">/tmp/deb.log");
use env;
use JSON;
use auth;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $cgi = new web_cgi;

my $auth = new auth($user);

my $Get = $ENV{'QUERY_STRING'};
$cgi->hash($Get);

print "Content-type: text/html\n\n";

my $param = $cgi->{'param'};
my $island = $cgi->{'island'};
#print DEBUG $cgi->{'param'}." cgi\n";
#print DEBUG $param." param\n";
#if(!$auth->_auth()){
#	print "Auth failed";
#	exit;
#}

$param =~ tr/+/ /;
$param =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;
print DEBUG $param." param\n";


system("$base_dir/exp/log_collect/delfile.exp '$param' $island");

open(IN, "/tmp/del_file_log.txt");
	while(<IN>){
		chomp;
		s/\r//g;
		print "$_";
	}
close(IN);
#close(DEBUG);
