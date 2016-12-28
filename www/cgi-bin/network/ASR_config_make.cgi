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
my $i = 0;
my $ii = 0;
my $intra_router = "10.3.1.3";

# Update string file
main();

my $all ={};
$all->{'data'} = $data;
print $obj->encode($all);

sub main(){
#make_list
  open(IN,"$base_dir/exp/network/show_link_info.exp \|grep -v kind \|grep -v reserved \|grep -w $intra_router -A 1 -B 2|") or die "FAILED";
  while(<IN>){
    chomp;
    s/\s//g;
    if ($_ eq "--"){
      $i = 0;
      $ii ++;
      s/--//;
      next;
    }
    @tmp = split(/\:/);
    $data->[$ii][$i]=$tmp[1];
  $i++
  }
  close(IN);

#island_check
  $l = 0;
  while(1){
    if ($data->[$l][0] eq ""){
      last;
    }
    use Switch;
    switch ($data->[$l][0]){
          case /SW0001/   {$data->[$l][4] = "islanda"}
          case /SW0002/   {$data->[$l][4] = "islandb"}
          case /SW0003/   {$data->[$l][4] = "islandc"}
          case /SW0004/   {$data->[$l][4] = "islandd"}
          case /SW0005/   {$data->[$l][4] = "islande"}
          case /SW0006/   {$data->[$l][4] = "islandf"}
          else            {$data->[$l][4] = "other"}
    }
  $l++;
  }
  
#MAKE OUTPUT FILE
  #INITIALIZE
  if(-e "ASRconfig_1"){
    unlink "ASRconfig_1";
  }
  #MAKE
  $l = 0;
  open(OUT,">>ASRconfig_1");
  while(1){
    if ($data->[$l][3] eq ""){
      last;
    }
    open(OUT,">>ASRconfig_1");
      $data->[$l][3] =~ s/GigabitEthernet/Gi/;
      $data->[$l][3] =~ s/FastEthernet/fa/;
      print (OUT $data->[$l][3]);
      print (OUT "|");
      print (OUT $data->[$l][4]);
      print (OUT "\n");
    close(OUT);
  $l++;
  }
  #JOINT
  open(OUT,">ASRconfig");
  open(IN1,"ASRconfig_1"); 
  open(IN2,"ASRconfig_2");
  print OUT <IN1>;
  print OUT "-----------------------\n";
  print OUT <IN2>;
}
