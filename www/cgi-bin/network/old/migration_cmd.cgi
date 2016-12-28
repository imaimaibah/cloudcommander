#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: text/html\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use auth;
use audit qw(audit_web);
use func qw(web_cgi);
use strict;
use POSIX();

my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Get);
my $cmd;
my $func;
my $user = $ENV{'AUTHENTICATE_UID'};
#### DELETE BELOW LINE #####
#my $cgi_dom0 = $cgi->{'dom0'} = "jp-01-1-ps0000-08-10";
#my $cgi_dom0ip = $cgi->{'dom0ip'} = "10.0.0.9";
#my $cgi_island = $cgi->{'island'} = "islanda-cbrm";
############################
my $audit = new audit_web();
my $auth = new auth($user);
if(!$auth->_auth()){
        print "Auth failed\n";
        exit;
}

my $cgi_dom0 = $cgi->{'dom0'};
my $cgi_dom0ip = $cgi->{'dom0ip'};
my $cgi_island = $cgi->{'island'};

my $return_value = `$base_dir/exp/resource/searchDom0.exp $cgi_dom0 $cgi_island`;

if ($return_value == 0){
#        print "Content-type: text/plain\n\n";
        print "FAILED:CAN'T LIVE MIGRATION\n";
				exit 0;
}

open(LOCK,">/tmp/lock");
if (! flock(LOCK,6)){
#        print "Content-type: text/plain\n\n";
        print "FAILED:ALREADY STARTED LIVE MIGRATION\n";
        exit 0;
}

my $pid = fork();
if ($pid){
#        print "Content-type: text/plain\n\n";
        print "SUCCESS:STARTED LIVE MIGRATION\n";
        exit 0;
}else{
        chdir('/');
        close(STDIN);
        close(STDOUT);
        close(STDERR);
        POSIX::setsid();
        if(fork()){
                exit 0;
        }else{
                POSIX::setsid();
        }
}

main($cgi_dom0,$cgi_island);
#main2($cgi_dom0ip,$cgi_island);

my $log = $ENV{'REQUEST_URI'};

$audit->log($user,$log);

close(LOCK);
close(DEBUG);

sub main($$){
	my $dom0 = shift;
	my $island = shift;
	system("$base_dir/exp/resource/migration_cmd.exp $dom0 $island");
}

sub main2($$){
	my $dom0ip = shift;
	my $island = shift;
	system("$base_dir/exp/resource/StautsStopCSM_cmd.exp $dom0ip $island");
}
