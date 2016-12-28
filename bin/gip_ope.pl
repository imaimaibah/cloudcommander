#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use func qw(multiRegion);
my $base_dir = $env::base_dir;
#my @data = ();
my $data = {};
my $vsys = $ARGV[0];
my @gip;
my @aip;
my @dip;

open(IN,"$base_dir/exp/gip_ope.exp $vsys|");
#my $i = 0;
while(<IN>){
	chomp;
	if(/[A-Z0-9]{8}-[A-Z0-9]{9}/){
		my($vsys_id,$gip,$status,$vnet_id) = /[^\s\|]+/g;
		#@{$data[$i++]} = ($vsys_id,$gip,$status,$vnet_id);
		$data->{$gip}->[0] = $status;
	}
}
close(IN);

if($data[0][3] eq ""){
	print "Empty\n";
	exit;
}

my $obj = new multiRegion();
$obj->findVMRegion($vsys);
my $island = $obj->{'vsys'}->{$vsys};
$obj = undef;

open(IN,"$base_dir/exp/gip_cnm.exp $data[0][3] $island|");
while(<IN>){
	chomp;
	if(/Router IPv4.*?([0-9.]+)/){
#		push(@gip,$1);
		$data->{$1}->[1] = "ATTACHED";
	}
}
close(IN);

foreach my $j(keys(%$data)){
	if($data->{$j}->[0] eq "ATTACHED" and $data->{$j}->[1] eq ""){
		if(!grep(/^$j->[1]$/,@gip)){
			push(@aip,$j->[1]);
		}
	}elsif($data->{$j}->[0] eq "DETACHED" and $data->{$j}->[1] ne ""){
		if(grep(/^$j->[1]$/,@gip)){
			push(@dip,$j->[1]);
		}
	}
}

attach(\@aip,\@dip,$data[0]->[3]);

sub attach(){
	my $aip = shift;
	my $dip = shift;
	my $vnet = shift;
	my $ex = "curl -k -X PUT -H 'Authorization: Basic cm9vdDpzb3B4ZW4=' -H 'Content-Type: application/xml' --data \@$base_dir/tmp/FILENAME https://$island:23461/cnm/internet_connectors";
	for(my $i = 0;$i<@{$aip};$i++){
		create_xml($$aip[$i]);
		#system("$ex/$$aip[0]/regist_globalip");
	}

	for(my $i = 0;$i<@{$dip};$i++){
		create_xml($$dip[$i]);
		#system("$ex/$$dip[0]/release_globalip");
	}

return 0;
}

sub create_xml(){
	my $gip = shift;
	open(OUT,">$base_dir/tmp/FILENAME");
	print OUT <<EOF;
<?xml version="1.0" encoding="utf-8" ?>
<request>
<globalip ipv4="$gip" />
</request>
EOF
	close(OUT);
return 0;
}
