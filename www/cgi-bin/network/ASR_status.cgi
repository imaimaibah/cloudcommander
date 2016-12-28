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

#SAMPLE########
#$cgi_contractid = $cgi->{'contractid'} = "AAAAAAAA";
#$cgi_contractid = $cgi->{'contractid'} = "MGM2D8H1";
###############
my $auth = new auth($user);
#if(!$auth->_auth()){
#        print "Auth failed\n";
#        exit;
#}

my $VRFSET = [];
my $data = [];
my $intra_router = "10.3.1.3";
my $cgi_contractid = $cgi->{'contractid'};
my $i = 0;
my $ii = 0;
my $counter = 0;

if ($cgi->{'contractid'} ne "AAAAAAAA"){
  outputhtml($VRFSET);
}else{
  open(ORG,"/data/cgi-bin/network/Contract_id_list");
  while(<ORG>){
    $cgi_contractid = $_;
    outputhtml($VRFSET);
  }
  close(ORG);  
  $counter = 1;
}

my $all ={};
$all->{'vrf'} = $VRFSET;
$all->{'counter'} = $counter;
print $obj->encode($all);

outputcsv($VRFSET);

sub outputcsv(){
  open(OUT, ">/data/download/ASR.csv");
    print OUT ("Contract ID",",","VRF",",","Interface",",","IP-address",",","Island",",","description",",","Peer IP",",","route-map","\n");
    my $num = 0;
    while (1){
      last if ($VRFSET->[$num][0] eq "");
      print OUT ($VRFSET->[$num][4],",",$VRFSET->[$num][2],",",$VRFSET->[$num][0],",",$VRFSET->[$num][1],",",$VRFSET->[$num][5],",",$VRFSET->[$num][6],",",$VRFSET->[$num][7],",",$VRFSET->[$num][8],"\n");
      $num ++;
    }
  close(OUT);
}

sub outputhtml(){
  my $VRFSET = shift;

  # Reading of string file in island name and interface name
  open(IN,"ASRconfig") or die "FAILED";
  while(<IN>){
    chomp;
    s/\r//g;
    my @tmp = split(/\|/);
    foreach my $l(@tmp){
    }
    push @$data, \@tmp;
  }
  close(IN);

  # Extraction of 'contractid' and 'vnet_id' and 'island name'
  open(IN,"$base_dir/exp/network/search_vnet_id.exp $cgi_contractid|") or die "FAILED";
  #open(IN,"/data/cgi-bin/network/pickup_vnet_id") or die "FAILED"; #dummy
  while(<IN>){
	  chomp;
	  s/\r//g;
	  if(/[A-Z0-9]{8}-[A-Z0-9]{9}/){
      my @tmp = split(/\|/);
      foreach my $l(@tmp){
              $l=~s/^\s+//;
              $l=~s/\s+$//;
      }
      $contractid = substr(@tmp[1],0,8);
      $island = substr(@tmp[2],0,7);
      $vnet_id = @tmp[3];
    }
  }
  close(IN);

  # Extraction of 'vlan_id'
  open(IN,"$base_dir/exp/network/search_vlan_id.exp $island $vnet_id|") or die "FAILED";
  #open(IN,"/data/cgi-bin/network/pickup_vlan_id") or die "FAILED"; #dummy
  $vlanid = substr(<IN>,28);
  close(IN);

  # Extraction of 'VRF_NAME'
  open(IN,"$base_dir/exp/network/search_vrf.exp $intra_router $vlanid|") or die "FAILED";
  #open(IN,"/data/cgi-bin/network/vrf_search_1") or die "FAILED"; #dummy
  while(<IN>){
	  chomp;
	  s/\r//g;
    my @tmp = split(/\s+/);
    $vrfname = $tmp[1];
  }
  close(IN);

  #VRF_DETAIL
  open(IN,"$base_dir/exp/network/show_vrf_int.exp $intra_router SOPOS|") or die "FAILED";
  #open(IN,"$base_dir/exp/network/show_vrf_int.exp $intra_router $vrfname|") or die "FAILED";
  #open(IN,"/data/cgi-bin/network/vrf_search_2") or die "FAILED"; #dummy
  while(<IN>){
	  chomp;
	  s/\r//g;
    my @tmp = split(/\s+/);
    push @$VRFSET, \@tmp;
      #contractid
      $VRFSET->[$i][4] = $contractid;

      #Connection destination in interface
      my $int_island = substr($VRFSET->[$i][0],0,7);
      while(1){
        if ($int_island eq $data->[$ii][0]){
          $VRFSET->[$i][5] = $data->[$ii][1];
          last;
        }
        $ii++
      }
    
      # Extraction of 'description'
      my $int =  substr($VRFSET->[$i][0],2);
      open(IN2,"$base_dir/exp/network/show_vrf_int_detail.exp $intra_router $int|") or die "FAILED";
      #open(IN2,"/data/cgi-bin/network/vrf_search_3_$i") or die "FAILED"; #dummy
      while(<IN2>){
        chomp;
        s/\r//g;
        if (/description/){
          my @tmp = split(/description\s/);
          $VRFSET->[$i][6] = $tmp[1];
        }
      }
      close(IN2);

      # Extraction of 'PeerIP' and 'route-map'
      open(IN3,"$base_dir/exp/network/show_vrf_neighbor.exp $intra_router SOPOS|") or die "FAILED";
      #open(IN3,"$base_dir/exp/network/show_vrf_neighbor.exp $intra_router $vrfname|") or die "FAILED";
      #open(IN3,"/data/cgi-bin/network/vrf_search_4") or die "FAILED"; #dummy
      while(<IN3>){
	      chomp;
	      s/\r//g;
        my @tmp = split(/\s+/);
        $VRFSET->[$i][7] = $peer_ip = $tmp[2];
        $VRFSET->[$i][8] = $route_map = $tmp[4];
      }
      close(IN3);

      $i ++;
  }
  close(IN);
}

close(DEBUG);
