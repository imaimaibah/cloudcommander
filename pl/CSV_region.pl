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

CreateVdisk($vdisk);
vdiskCSV($vdisk);
CreateGIP($gip_data);
gipCSV($gip_data);
CreateUser($user);
userCSV($user);

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
open(OUT, ">$regioncsv");
print OUT <<EOF;
1. Contract IDs,$ConID

2.VM Usage
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

3. Disk Usage
,Total Disk Space(TB):,$total
,In Use(TB):,$inUse
,Zero Clearing(TB):,$zero
,Free Disk Space(TB):,$free
,Free Disk Space(%):,$free_percent

4. OS Usage
EOF

print OUT "Running\n";
#printf OUT (",%s,%s\n",'FW',$run{'FW'});
#printf OUT (",%s,%s\n",'SLB',$run{'SLB'});
foreach my $key (sort keys %run){
#	if($key eq 'FW' or $key eq 'SLB'){
#		next;
#	}
	printf OUT (",%s,%s\n",$key,$run{$key});
}

print OUT "\nStopped\n";
#printf OUT (",%s,%s\n",'FW',$stop{'FW'});
#printf OUT (",%s,%s\n",'SLB',$stop{'SLB'});
foreach my $key (sort keys %stop){
#	if($key eq 'FW' or $key eq 'SLB'){
#		next;
#	}
	printf OUT (",%s,%s\n",$key,$stop{$key});
}

print OUT <<EOF;

5. Internet Connect Usage
,Total:,$inetTotal
,In Use:,$inetUse
,Free Internet Connect:,$inetFree
,Free Internet Connect(%):,$inetFree_percent

6. Glogal IP Address Usage
,Total:,$gipTotal
,In Use:,$gipUse
,Unavailable:,$gipWash
,Free Global IP Address:,$gipFree
,Free Global IP Address(%):,$gipFree_percent

Capacity Data Tool Ver.$ver
EOF
close(OUT);

# Defined Functions
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

sub CreateVdisk($){
	my $vdisk = shift;

	open(DAT, "$dat") or die "FAILED!!";
	while(<DAT>){
		chomp;
		my @tmp = split(/,/);
		my @org = split(/-/, $tmp[0]);
		$vdisk->{$org[0]}->{"$org[0]-$org[1]"}->{'sysvol'} += sprintf("%d",$tmp[4]);
	}
	close(DAT);

	open(VDISK, "$vfile") or die "FAILED!!";
	while(<VDISK>){
		chomp;
		my @tmp = split(/,/);
		my @org = split(/-/, $tmp[0]);
		$vdisk->{$org[0]}->{"$org[0]-$org[1]"}->{$tmp[2]} += sprintf("%d",$tmp[1]);
	}
	close(VDISK);

return 0;
}

sub vdiskCSV($){
	my $vdisk = shift;
	my @org = keys(%$vdisk);
	my $total;
	my $total_org;
	my $vdiskcsv = "$base_dir/capacity/region/vdisk.csv";

	open(OUT,">$vdiskcsv") or die "FAILED!!";
	print OUT "Organization,VSYS,type,size(GB)\n";

	foreach my $org(@org){
		foreach my $vsys(keys(%{$vdisk->{$org}})){
			foreach my $type(keys(%{$vdisk->{$org}->{$vsys}})){
				$tmp .= ",$type,$vdisk->{$org}->{$vsys}->{$type}";
				$total += $vdisk->{$org}->{$vsys}->{$type};
				print OUT "$org,$vsys,$type,$vdisk->{$org}->{$vsys}->{$type}\n";
			}
			print OUT "$org,$vsys,Total,$total\n";
			$total_org += $total;
			$total = 0;
		}
		print OUT "$org,-,Total,$total_org\n";
		$total_org = 0;
	}
	close(OUT);


return 0;
}

sub CreateGIP($){
	my $gip = shift;

	open(GIP, "$gip_list") or die "FAILED!!";
	while(<GIP>){
		chomp;
		my @tmp = split(/,/);
		$gip->{$tmp[0]}->{$tmp[1]}++;
	}
	close(GIP);

return 0;
}

sub gipCSV($){
	my $gip = shift;
	my $gip_out = "$base_dir/capacity/region/gip.csv";
	my $total = 0;

	open(GIP_OUT, ">$gip_out") or die "FAILED!!";
	print GIP_OUT "ORG ID,VSYS ID,ATTACHED,DETACHED,Total\n";
	while(my($key,$val)=each(%$gip)){
		my @org = split(/-/,$key);
		if($val->{'ATTACHED'} eq ""){
			$val->{'ATTACHED'} = 0;
		}
		if($val->{'DETACHED'} eq ""){
			$val->{'DETACHED'} = 0;
		}
		$total += $val->{'ATTACHED'};
		$total += $val->{'DETACHED'};
		print GIP_OUT "$org[0],$key,$val->{'ATTACHED'},$val->{'DETACHED'},$total\n";
		$total = 0;
	}
	close(GIP_OUT);

return 0;
}

sub CreateUser($){
	my $user = shift;
	open(IN, "$dat") or die "FAILED!!";
	while(<IN>){
		chomp;
		my @tmp = split(/,/);
		my @org = split(/-/,$tmp[0]);
		my $org = "$org[0]";
		my $vsys = "$org[0]-$org[1]";
		my $os = &os_name("$tmp[3]");
		if("$os" eq "Firewall"){
			if($tmp[2] ne ""){
				$user->{$org}->{$vsys}->{'FW'}->[0] += 1;
			}else{
				$user->{$org}->{$vsys}->{'FW'}->[1] += 1;
			}
		}elsif("$os"eq "Server Load Balancer"){
			if($tmp[2] ne ""){
				$user->{$org}->{$vsys}->{'SLB'}->[0] += 1;
			}else{
				$user->{$org}->{$vsys}->{'SLB'}->[1] += 1;
			}
		}elsif($tmp[1] eq "1"){
			if($tmp[2] ne ""){
				$user->{$org}->{$vsys}->{'economy'}->[0] += 1;
			}else{
				$user->{$org}->{$vsys}->{'economy'}->[1] += 1;
			}
		}elsif($tmp[1] eq "2"){
			if($tmp[2] ne ""){
				$user->{$org}->{$vsys}->{'standard'}->[0] += 1;
			}else{
				$user->{$org}->{$vsys}->{'standard'}->[1] += 1;
			}
		}elsif($tmp[1] eq "4"){
			if($tmp[2] ne ""){
				$user->{$org}->{$vsys}->{'advanced'}->[0] += 1;
			}else{
				$user->{$org}->{$vsys}->{'advanced'}->[1] += 1;
			}
		}elsif($tmp[1] eq "8"){
			if($tmp[2] ne ""){
				$user->{$org}->{$vsys}->{'high'}->[0] += 1;
			}else{
				$user->{$org}->{$vsys}->{'high'}->[1] += 1;
			}
		}
	}
	close(IN);
	while(my($key1,$val1)=each(%$user)){
		while(my($key2,$val2)=each(%$val1)){
			foreach my $key3(('FW','SLB','economy','standard','advanced','high')){
				if($user->{$key1}->{$key2}->{$key3}->[0] eq ""){
					$user->{$key1}->{$key2}->{$key3}->[0] = 0;
				}
				if($user->{$key1}->{$key2}->{$key3}->[1] eq ""){
					$user->{$key1}->{$key2}->{$key3}->[1] = 0;
				}
			}
		}
	}

return 0;
}

sub userCSV($){
	my $user = shift;
	my $user_out = "$base_dir/capacity/region/user.csv";
	open(OUT, ">$user_out") or die "FAILED!!";
	print OUT "ORG ID,VSYS ID,FW(RUN),FW(STOP),SLB(RUN),SLB(STOP),Eco(RUN),Eco(STOP),Std(RUN),Std(STOP),Adv(RUN),Adv(STOP),High(RUN),High(STOP),Total(RUN),Total(STOP),Total)\n";
	while(my($key1,$val1)=each(%$user)){
		my ($total_org,$total_run_org,$total_stop_org,$total_fw_run,$total_fw_stop,$total_slb_run,$total_slb_stop,$total_eco_run,$total_eco_stop,$total_stan_run,$total_stan_stop,$total_adv_run,$total_adv_stop,$total_high_run,$total_high_stop);
		while(my($key2,$val2)=each(%$val1)){
			print OUT "$key1,$key2,$val2->{'FW'}->[1],$val2->{'FW'}->[0],$val2->{'SLB'}->[1],$val2->{'SLB'}->[0],";
			print OUT "$val2->{'economy'}->[1],$val2->{'economy'}->[0],$val2->{'standard'}->[1],$val2->{'standard'}->[0],";
			print OUT "$val2->{'advanced'}->[1],$val2->{'advanced'}->[0],$val2->{'high'}->[1],$val2->{'high'}->[0],";
			my $total_run = $val2->{'FW'}->[1] + $val2->{'SLB'}->[1] + $val2->{'economy'}->[1] + $val2->{'standard'}->[1] + $val2->{'advanced'}->[1] + $val2->{'high'}->[1];
			my $total_stop = $val2->{'FW'}->[0] + $val2->{'SLB'}->[0] + $val2->{'economy'}->[0] + $val2->{'standard'}->[0] + $val2->{'advanced'}->[0] + $val2->{'high'}->[0];
			print OUT "$total_run,";
			print OUT "$total_stop,";
			$total = $total_run + $total_stop;
			print OUT "$total\n";
			$total_org += $total;
			$total_run_org += $total_run;
			$total_stop_org += $total_stop;
			$total_fw_run += $val2->{'FW'}->[1];
			$total_fw_stop += $val2->{'FW'}->[0];
			$total_slb_run += $val2->{'SLB'}->[1];
			$total_slb_stop += $val2->{'SLB'}->[0];
			$total_eco_run += $val2->{'economy'}->[1];
			$total_eco_stop += $val2->{'economy'}->[0];
			$total_stan_run += $val2->{'standard'}->[1];
			$total_stan_stop += $val2->{'standard'}->[0];
			$total_adv_run += $val2->{'advanced'}->[1];
			$total_adv_stop += $val2->{'advanced'}->[0];
			$total_high_run += $val2->{'high'}->[1];
			$total_high_stop += $val2->{'high'}->[0];
		}
		print OUT "$key1,Total,$total_fw_run,$total_fw_stop,$total_slb_run,$total_slb_stop,$total_eco_run,$total_eco_stop,$total_stan_run,$total_stan_stop,$total_adv_run,$total_adv_stop,$total_high_run,$total_high_stop,$total_run_org,$total_stop_org,$total_org\n";
		$total_org = 0;
	}
	close(OUT);

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

