#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir=$env::base_dir;
my $dat = "$base_dir/capacity/raw/dat.csv";
my $storage = "$base_dir/capacity/raw/storage.csv";
my $gip = "$base_dir/capacity/raw/gip.csv";
my $vfile = "$base_dir/capacity/raw/vdisk.csv";
my $gip_list = "$base_dir/capacity/raw/gip_list.csv";
my $product_list = "$base_dir/capacity/raw/product.csv";
my $vdisk = {};
my $gip_data = {};
my $user = {};
my $region_num = `awk -F, '{print \$6}' $dat|sort|uniq|wc -l`;
chomp($region_num);

if(!-e "$base_dir/capacity/regin"){
	mkdir("$base_dir/capacity/region");
}

# Capacity Script Version
my $ver = 1.1;

# Contract ID
my $ConID = `awk -F- '{print \$1}' $dat|sort|uniq|wc -l`;
chomp($ConID);

# Max VMs;
my $MaxVMs = 2784*$region_num;

# Economy Equivalent (Running)
my $RVMs = `awk -F',' 'BEGIN{n=0} \$3 != "" {n += \$2} END{print n}' $dat`;
chomp($RVMs);

# Economy Equivalent (Stopped)
my $SVMs = `awk -F',' 'BEGIN{n=0} \$3 == "" {n += \$2} END{print n}' $dat`;
chomp($SVMs);

# Deployable(Economy Equivalent)
my $Dep = $MaxVMs - $RVMs;

# Dployable(Economy Equivalent) Including Stopped VMs
my $Dep2 = $Dep - $SVMs;

# Deployed VMs
my $DepVM = `cat $dat|wc -l`;
chomp($DepVM);

# Economy
my $eco = `awk -F',' 'BEGIN{n=0} \$2==1 && \$4 != "FW" {n++} END{print n}' $dat`;
chomp($eco);

# Standard 
my $std = `awk -F',' 'BEGIN{n=0} \$2==2 && \$4 != "SLB" {n++} END{print n}' $dat`;
chomp($std);

# Advanced
my $adv = `awk -F',' 'BEGIN{n=0} \$2==4 {n++} END{print n}' $dat`;
chomp($adv);

# High-Performance
my $high = `awk -F',' 'BEGIN{n=0} \$2==8 {n++} END{print n}' $dat`;
chomp($high);

# FireWall
my $fw = `awk -F',' 'BEGIN{n=0} \$4 == "FW" {n++} END{print n}' $dat`;
chomp($fw);

# SLB
my $slb = `awk -F',' 'BEGIN{n=0} \$4 == "SLB" {n++} END{print n}' $dat`;
chomp($slb);

# VSYS
my $vsys = `awk -F'-' '{print \$1\$2}' $dat|sort|uniq|wc -l`;
chomp($vsys);

# DISK USAGE
# Total
my $total1 = `awk -F',' 'BEGIN{n=0} \$1~/Total/ {n += \$2} END{print n}' $storage`;
chomp($total1);

my $total2 = `awk -F',' 'BEGIN{n=0} \$1~/Total/ {n += \$3} END{print n}' $storage`;
chomp($total2);

# Free
my $free1 = `awk -F',' 'BEGIN{n=0} \$1~/Free/ {n += \$2} END{print n}' $storage`;
chomp($free1);

my $free2 = `awk -F',' 'BEGIN{n=0} \$1~/Free/ {n += \$3} END{print n}' $storage`;
chomp($free2);

# Zero Clear
my $zero1 = `awk -F',' 'BEGIN{n=0} \$1~/Zero/ {n += \$2} END{print n}' $storage`;
chomp($zero1);

my $zero2 = `awk -F',' 'BEGIN{n=0} \$1~/Zero/ {n += \$3} END{print n}' $storage`;
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
open(IN, "$dat") or die "FAILED!!";
while(<IN>){
	chomp;
	my @tmp = split(/,/);
	my $tmp = os_name("$tmp[3]");

	if($tmp eq "0" and $tmp[2] ne ""){
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

my $inetTotal = `grep 'Total of pooled ip network number' $gip|cut -d: -f2`;
chomp($inetTotal);
$inetTotal *= 254;
my $inetUse = `grep 'Total of allocated ip address' $gip|cut -d: -f2|awk 'BEGIN{n=0} {n += \$1} END{print n}'`;
chomp($inetUse);
my $inetFree = $inetTotal - $inetUse;
my $inetFree_percent = sprintf("%.1f",$inetFree/$inetTotal*100);
my $gipTotal = `grep 'Total of pooled global ip address number' $gip|cut -d: -f2`;
chomp($gipTotal);
my $gipUse = `grep 'Total of allocated global ip address number' $gip|cut -d: -f2`;
chomp($gipUse);
my $gipWash = `grep 'Total of unavailable global ip address number' $gip|cut -d: -f2`;
chomp($gipWash);
my $gipFree = $gipTotal - $gipUse - $gipWash;
my $gipFree_percent = sprintf("%.1f",$gipFree/$gipTotal*100);


# Create the data
my $regioncsv="$base_dir/capacity/region/dat.csv";
print <<EOF;
1. Contract IDs					$ConID

2.VM Usage
	Max VMs:				$MaxVMs
	Running VMs(Economy Equivalent):	$RVMs
	Stopped VMs(Economy Equivalent):	$SVMs
	Deployable(Economy):			$Dep
	Deployable(including stopped VMs):	$Dep2
	Deployed VMs:				$DepVM
	Economy:				$eco
	Standard:				$std
	Advanced:				$adv
	High-perf:				$high
	Firewall:				$fw
	SLB:					$slb
	VSYS:					$vsys

3. Disk Usage
	Total Disk Space(TB):			$total
	In Use(TB):				$inUse
	Zero Clearing(TB):			$zero
	Free Disk Space(TB):			$free
	Free Disk Space(%):			$free_percent

4. OS Usage
EOF

print "Running\n";
#printf("\t%s\t%s\n",'FW',$run{'FW'});
#printf("\t%s\t%s\n",'SLB',$run{'SLB'});
foreach my $key (sort keys %run){
	#if($key eq 'FW' or $key eq 'SLB'){
	#	next;
	#}
	printf("%s:\t%s\n",$key,$run{$key});
}

print "\nStopped\n";
#printf ("\t%s\t%s\n",'FW',$stop{'FW'});
#printf ("\t%s\t%s\n",'SLB',$stop{'SLB'});
foreach my $key (sort keys %stop){
	#if($key eq 'FW' or $key eq 'SLB'){
	#	next;
	#}
	printf ("%s:\t%s\n",$key,$stop{$key});
}

print <<EOF;

5. Internet Connect Usage
	Total:					$inetTotal
	In Use:					$inetUse
	Free Internet Connect:			$inetFree
Free Internet Connect(%):			$inetFree_percent

6. Glogal IP Address Usage
	Total:					$gipTotal
	In Use:					$gipUse
	Unavailable:				$gipWash
	Free Global IP Address:			$gipFree
	Free Global IP Address(%):		$gipFree_percent

Capacity Data Tool Ver.$ver


This e-mail is for notification purposes only. Please do not respond to
this email as this email address is not monitored.
EOF



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
