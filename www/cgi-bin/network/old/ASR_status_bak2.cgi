#!/usr/bin/perl -I/usr/local/2nd_tools/lib

#Version: 1.0

open(DEBUG,">/tmp/debug.log");

print "Content-type: text/html\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(web_cgi);
use auth;

my $user = $ENV{'AUTHENTICATE_UID'};
my $auth = new auth($user);

my $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Get);
my $user = $ENV{'AUTHENTICATE_UID'};

my $audit = new audit_web();
#my $auth = new auth($user);
#if(!$auth->_auth()){
#        print "Auth failed\n";
#        exit;
#}

#########
#my $cgi_contactid = $cgi->{'contractid'} ="SKZL65ZQ";
#########

my $cgi_contactid = $cgi->{'contractid'};

my $VRFSET = [];
my $data = [];
my $intra_router = "10.3.1.3"; 

# アイランド番号とインターフェースの紐付けファイルの読み込み
open(IN,"ASRconfig") or die "FAILED";
while(<IN>){
  chomp;
  s/\r//g;
  my @tmp = split(/\|/);
  foreach my $l(@tmp){
  }
  push @$data, \@tmp;
}

# 対象のvnet_id,islandの抽出
#open(IN,"$base_dir/exp/network/pickup_vnet_id.exp $cgi_contractid|") or die "FAILED";
open(IN,"/data/cgi-bin/network/pickup_vnet_id") or die "FAILED"; #dummy
while(<IN>){
	chomp;
	s/\r//g;
  # 契約ID記載の行のみを抽出し不要な文字列を削除
	if(/[A-Z0-9]{8}-[A-Z0-9]{9}/){
    my @tmp = split(/\|/);
    foreach my $l(@tmp){
            $l=~s/^\s+//;
            $l=~s/\s+$//;
    }
  #アイランド名とvnet_idを抽出
     $contractid = substr(@tmp[1],0,8);
     $island = substr(@tmp[2],0,7);
     $vnet_id = @tmp[3];
  }
}
close(IN);

# vlan_idの抽出
#open(IN,"$base_dir/exp/network/pickup_vlan_id.exp $island $vnet_id|") or die "FAILED";
open(IN,"/data/cgi-bin/network/pickup_vlan_id") or die "FAILED"; #dummy
$vlanid = substr(<IN>,28);
close(IN);

# VRF_NAMEの抽出
#open(IN,"$base_dir/exp/network/vrf_serach_2.exp $intra_router $vlanid|") or die "FAILED";
open(IN,"/data/cgi-bin/network/vrf_serach_1") or die "FAILED"; #dummy
while(<IN>){
	chomp;
	s/\r//g;
  my @tmp = split(/\s+/);
  $vrfname = $tmp[1];
}
close(IN);

#VRF_DETAIL
my $i = 0;
my $ii =0;
#open(IN,"$base_dir/exp/network/vrf_serach_2.exp $intra_router $vrfname|") or die "FAILED";
open(IN,"/data/cgi-bin/network/vrf_serach_2") or die "FAILED"; #dummy

while(<IN>){
	chomp;
	s/\r//g;
  my @tmp = split(/\s+/);
  push @$VRFSET, \@tmp;
    # インターフェースの接続先確認
    my $int_island = substr($VRFSET->[$i][0],0,7);
    while(1){
      if ($int_island eq $data->[$ii][0]){
        $VRFSET->[$i][5] = $data->[$ii][1];
        last;
      }
    $ii++
    }
    # 対象のインターフェースのdescriptionを取得
    my $int =  substr($VRFSET->[$i][0],2);
#    open(IN2,"$base_dir/exp/network/vrf_serach_3.exp $intra_router $int|") or die "FAILED";
    open(IN2,"/data/cgi-bin/network/vrf_serach_3_$i") or die "FAILED"; #dummy
    while(<IN2>){
      chomp;
      s/\r//g;
      if (/description/){
        my @tmp = split(/description\s/);
        $VRFSET->[$i][4] = $tmp[1];
      }
    }
    $i ++;
}
close(IN);

#FRAME
#print ("Contract ID",",","VRF",",","Interface",",","IP-address",",","Island",",","description","\n\n");

my $num = 0;
while (1){
  last if ($VRFSET->[$num][0] eq "");
  print ($contractid,",",$VRFSET->[$num][2],",",$VRFSET->[$num][0],",",$VRFSET->[$num][1],",",$VRFSET->[$num][5],",",$VRFSET->[$num][4],"<br>","\n");
  $num ++;
}

close(DEBUG);
