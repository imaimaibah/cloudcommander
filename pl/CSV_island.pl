#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir = $env::base_dir;
my $dat = "$base_dir/capacity/raw/dat.csv";
my @region = `awk -F, '{print \$6}' $dat|sort|uniq`;
my $storage = "$base_dir/capacity/raw/storage.csv";
my $product_list = "$base_dir/capacity/raw/product.csv";

foreach my $region(@region){
	chomp($region);
	islandCSV($region);
}
islandDom0CSV();

# Defined Functions
sub islandCSV(){
my $region = shift;

# Create CSV files
# Max VMs;
my $MaxVMs = 2784;
my @tmp = split(/-/,$region);
if(! -e "$base_dir/capacity/$tmp[0]"){
	mkdir("$base_dir/capacity/$tmp[0]");
}
open(OUT,">$base_dir/capacity/$tmp[0]/dat.csv") or die "FAILED!!";

# Economy Equivalent (Running)
my $RVMs = `awk -F',' 'BEGIN{n=0} \$3 != "" && \$6 == "$region" {n += \$2} END{print n}' $dat`;
chomp($RVMs);

# Economy Equivalent (Stopped)
my $SVMs = `awk -F',' 'BEGIN{n=0} \$3 == "" && \$6 == "$region" {n += \$2} END{print n}' $dat`;
chomp($SVMs);

# Deployable(Economy Equivalent)
my $Dep = $MaxVMs - $RVMs;

# Dployable(Economy Equivalent) Including Stopped VMs
my $Dep2 = $Dep - $SVMs;

# Deployed VMs
my $DepVM = `awk -F',' '\$6 == "$region" {print}' $dat|wc -l`;
chomp($DepVM);

# Economy
my $eco = `awk -F',' 'BEGIN{n=0} \$2==1 && \$4 != "FW" && \$6=="$region" {n++} END{print n}' $dat`;
chomp($eco);

# Standard 
my $std = `awk -F',' 'BEGIN{n=0} \$2==2 && \$4 != "SLB" && \$6=="$region" {n++} END{print n}' $dat`;
chomp($std);

# Advanced
my $adv = `awk -F',' 'BEGIN{n=0} \$2==4 && \$6=="$region" {n++} END{print n}' $dat`;
chomp($adv);

# High-Performance
my $high = `awk -F',' 'BEGIN{n=0} \$2==8 && \$6=="$region" {n++} END{print n}' $dat`;
chomp($high);

# FireWall
my $fw = `awk -F',' 'BEGIN{n=0} \$4 == "FW" && \$6=="$region" {n++} END{print n}' $dat`;
chomp($fw);

# SLB
my $slb = `awk -F',' 'BEGIN{n=0} \$4 == "SLB" && \$6=="$region" {n++} END{print n}' $dat`;
chomp($slb);

# VSYS
my $vsys = `grep "$region" $dat |awk -F'-' '{print \$1\$2}'|sort|uniq|wc -l`;
chomp($vsys);

# DISK USAGE
# Total
my $total1 = `awk -F',' '\$1~/Total/ && \$4=="$region" {print \$2}' $storage`;
chomp($total1);

my $total2 = `awk -F',' '\$1~/Total/ && \$4=="$region" {print \$3}' $storage`;
chomp($total2);

# Free
my $free1 = `awk -F',' '\$1~/Free/ && \$4=="$region" {print \$2}' $storage`;
chomp($free1);

my $free2 = `awk -F',' '\$1~/Free/ && \$4=="$region" {print \$3}' $storage`;
chomp($free2);

# Zero Clear
my $zero1 = `awk -F',' '\$1~/Zero/ && \$4=="$region" {print \$2}' $storage`;
chomp($zero1);

my $zero2 = `awk -F',' '\$1~/Zero/ && \$4=="$region" {print \$3}' $storage`;
chomp($zero2);

if($total1>$total2){
	$total = sprintf("%.1f",$total2/(1024*1024));
	$free = sprintf("%.1f",$free2/(1024*1024));
	$zero = sprintf("%.1f",$zero2/(1024*1024));
}else{
	$total = sprintf("%.1f",$total1/(1024*1024));
	$free = sprintf("%.1f",$free1/(1024*1024));
	$zero = sprintf("%.1f",$zero1/(1024*1024));
}
my $inUse = sprintf("%.1f",$total - $free - $zero);
my $free_percent = sprintf("%.1f",($free+$zero)/$total*100);

# BY OS
my %run;
os_list(\%run);
my %stop;
os_list(\%stop);
open(IN, "grep '$region' $dat|") or die "FAILED!!";
while(<IN>){
	chomp;
	my @tmp = split(/,/);
	my $tmp = os_name("$tmp[3]");

	if($tmp  eq "0" and $tmp[2] ne ""){
		$run{'others'} += 1;
	}elsif($tmp  eq "0" and $tmp[2] eq ""){
		$stop{'others'} += 1;
	}elsif($tmp[2] ne ""){
		$run{$tmp} += 1;
	}else{
		$stop{$tmp} += 1;
	}
}
close(IN);

$fw = $run{'Firewall'} + $stop{'Firewall'};
$slb = $run{'Server Load Balancer'} + $stop{'Server Load Balancer'};
$eco -= $fw;
$std -= $slb;

#Display the data
print OUT <<EOF;
1.VM Usage
,Max VMs:,$MaxVMs
,Running VMs(Economy Equivalent):,$RVMs
,Stopped VMs(Economy Equivalent):,$SVMs
,Deployable(Economy):,$Dep
,Deployable(including stopped VMs):,$Dep2
,Deployed VMs:,$DepVM
,Economy:,$eco
,Standard:,$std
,Advanced:,$adv
,High-perf:,$high
,Firewall:,$fw
,SLB:,$slb
,VSYS:,$vsys

2. Disk Usage
,Total Disk Space(TB):,$total
,In Use(TB):,$inUse
,Zero Clearing(TB):,$zero
,Free Disk Space(TB):,$free
,Free Disk Space(%):,$free_percent

3. OS Usage
EOF

	print OUT "Running\n";
#	printf OUT (",%s,%s\n",'FW',$run{'FW'});
#	printf OUT (",%s,%s\n",'SLB',$run{'SLB'});
	foreach my $key (sort keys %run){
#		if($key eq 'FW' or $key eq 'SLB'){
#			next;
#		}
		printf OUT (",%s,%s\n",$key,$run{$key});
	}

	print OUT "\nStopped\n";
#	printf OUT (",%s,%s\n",'FW',$stop{'FW'});
#	printf OUT (",%s,%s\n",'SLB',$stop{'SLB'});
	foreach my $key (sort keys %stop){
#		if($key eq 'FW' or $key eq 'SLB'){
#			next;
#		}
		printf OUT (",%s,%s\n",$key,$stop{$key});
	}
	close(OUT);

return 0;
}

sub os_name(){
	my $product = shift;
	my $tmp;

open(IN2, "$product_list") or die "FAILED!!";
while(<IN2>){
	chomp;
	my @tmp = split(/,/);
	if($tmp[0] eq $product){
		shift(@tmp);
		foreach my $name(@tmp){
			$tmp .= "$name + ";
		}
		$tmp =~ s/ \+ $//;
		close(IN2);
		return $tmp;
	}
}
close(IN2);
return 0;
}

sub islandDom0CSV($){
	my $data = {};

	open(IN,"$dat") or die "FAILED!!";
	while(<IN>){
		chomp;
		my @tmp = split(/,/);
		if($tmp[2] eq ""){
			next;
		}
		my @isl = split(/-/,$tmp[5]);
		if(&os_name("$tmp[3]") eq 'Firewall'){
			$data->{$isl[0]}->{$tmp[2]}->{'FW'}++;
		}elsif(&os_name($tmp[3]) eq 'Server Load Balancer'){
			$data->{$isl[0]}->{$tmp[2]}->{'SLB'}++;
		}elsif($tmp[1] eq 1){
			$data->{$isl[0]}->{$tmp[2]}->{'economy'}++;
		}elsif($tmp[1] eq 2){
			$data->{$isl[0]}->{$tmp[2]}->{'standard'}++;
		}elsif($tmp[1] eq 4){
			$data->{$isl[0]}->{$tmp[2]}->{'advanced'}++;
		}elsif($tmp[1] eq 8){
			$data->{$isl[0]}->{$tmp[2]}->{'high'}++;
		}
	}
	close(IN);

	outCSV($data);

return 0;
}

sub outCSV($){
	my $data = shift;
foreach my $region(keys(%$data)){
	open(OUT2, ">$base_dir/capacity/$region/dom0.csv") or die "FAILED!!";
	print OUT2 "Dom0,FW,SLB,Economy,Standard,Advanced,High-Perfomance,Total(Eco. Equi),Total\n";
	while(my($key,$val) = each(%{$data->{$region}})){
		my $tmp = "$key\n";
		my $total = 0;
		my $total_equ = 0;
		if($val->{'FW'} eq ""){
			$val->{'FW'} = 0;
		}elsif($val->{'SLB'} eq ""){
			$val->{'SLB'} = 0;
		}elsif($val->{'economy'} eq ""){
			$val->{'economy'} = 0;
		}elsif($val->{'standard'} eq ""){
			$val->{'standard'} = 0;
		}elsif($val->{'advanced'} eq ""){
			$val->{'advanced'} = 0;
		}elsif($val->{'high'} eq ""){
			$val->{'high'} = 0;
		}
		$total += $val->{'FW'};
		$total_equ += $val->{'FW'};
		$total += $val->{'SLB'};
		$total_equ += $val->{'SLB'}*2;
		$total += $val->{'economy'};
		$total_equ += $val->{'economy'};
		$total += $val->{'standard'};
		$total_equ += $val->{'standard'}*2;
		$total += $val->{'advanced'};
		$total_equ += $val->{'advanced'}*4;
		$total += $val->{'high'};
		$total_equ += $val->{'high'}*8;
		print OUT2 "$key,$val->{'FW'},$val->{'SLB'},$val->{'economy'},$val->{'standard'},$val->{'advanced'},$val->{'high'},$total_equ,$total\n";
	}
	close(OUT2);
}

return 0;
}

sub os_list(){
	my $data = shift;
	my $tmp;
	open(IN,"$product_list") or die "FAILED!!";
	while(<IN>){
		chomp;
		my @tmp = split(/,/);
		shift(@tmp);
		foreach my $name(@tmp){
			$tmp .= "$name + ";
		}
		$tmp =~ s/ \+ $//;
		$$data{$tmp} = 0;
		$tmp = "";
	}
	close(IN);

return 0;
}
