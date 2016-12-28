#!/usr/bin/perl -I/usr/local/2nd_tools/lib

#Version: 1.0

use env;
use auth;
use JSON;

my $base_dir = $env::base_dir;
my $obj = new JSON();

my $user = $ENV{'AUTHENTICATE_UID'};

my $auth = new auth($user);
#if(!$auth->_auth()){
#        print "Auth failed\n";
#        exit;
#}

my $data = [];

# Update string file
$ii = 1;
while(1){
  main($ii);
}

my $all ={};
$all->{'data'} = $data;
print $obj->encode($all);

sub main(){
  my $i = 0;
  
  open(IN,"$base_dir/exp/network/show_link_info.exp \|grep '\\\[$ii\\\]' -A 9\|grep -v reserved\|grep -v kind|") or die "FAILED";
  if ($ii == 10){
    close(IN);
    last;
  }
  while(<IN>){
    s/\s//g;
    s/\r//g;
    if(!/\[*\]/){
      my @tmp = split(/\:/);
      foreach my $l(@tmp){
      }
      @{$data->[$ii-1][$i]}=($tmp[1]);
#      print $tmp[1];
#      print "\n";
    $i++;
    }
  }
  close(IN);
  $ii++;
}
