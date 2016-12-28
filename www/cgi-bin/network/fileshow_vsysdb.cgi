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

my $auth = new auth($user);
#if(!$auth->_auth()){
#        print "Auth failed\n";
#        exit;
#}

my $cgi_filename = $cgi->{'filename'};

$data = [];

main($data);

my $all ={};
$all->{'result'} = $data;
$all->{'scom'} = $cgi_filename;

print $obj->encode($all);

sub main($$){
  my $data = shift;

  open(IN,"/data/cgi-bin/network/dummy/vsys_zero") or die "FAILED";
#  open(IN,"$base_dir/exp/network/show_vsys_zero.exp|") or die "FAILED";
  while(<IN>){
    chomp;
    s/\r//g;
    s/\s//g;
    s/'//g;
    if(/[A-Z0-9]{8}/){
      my @tmp = split(/\,/);
#      my @tmp = $_;
      foreach my $l(@tmp){
      }
      push @$data, \@tmp;
    }
  }
  close(IN);
}
close(DEBUG);
