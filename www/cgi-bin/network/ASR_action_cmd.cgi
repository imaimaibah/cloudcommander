#!/usr/bin/perl -I/usr/local/2nd_tools/lib

#Version: 1.0

open(DEBUG,">/tmp/debug.log");

print "Content-type: text/html\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use auth;
use JSON;
use func qw(web_cgi);

my $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Get);
my $cmd;
my $func;
my $obj = new JSON();

my $user = $ENV{'AUTHENTICATE_UID'};

#SAMPLE########i
#my $cgi_com1 = $cgi->{'com1'}= "show run";
#my $cgi_com2 = $cgi->{'com2'}= "";
###############
my $auth = new auth($user);
#if(!$auth->_auth()){
#        print "Auth failed\n";
#        exit;
#}

my $cgi_scom = $cgi->{'scom'};
my $cgi_vrfname = $cgi->{'vrfname'};
my $cgi_peerip = $cgi->{'peerip'};
my $cgi_routemap = $cgi->{'routemap'};


$cgi_scom =~ s/\%20/ /g;
$cgi_scom =~ s/vrf_name/$cgi_vrfname/;
$cgi_scom =~ s/peer_ip/$cgi_peerip/;
$cgi_scom =~ s/route-map_name/$cgi_routemap/;

$data = [];
$intra_router = "10.3.1.3";

main($data);

my $all ={};
$all->{'result'} = $data;
$all->{'scom'} = $cgi_scom;

print $obj->encode($all);

sub main($$){
  my $data = shift;

  open(IN,"$base_dir/exp/network/show_run.exp '$cgi_scom' $intra_router|") or die "FAILED";
  while(<IN>){
    chomp;
#    s/\r//g;
#    my @tmp = split(/\|/);
    my @tmp = $_;
    foreach my $l(@tmp){
    }
    push @$data, \@tmp;
  }
  close(IN);
}
close(DEBUG);
