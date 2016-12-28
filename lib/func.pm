#!/usr/bin/perl -I/usr/local/2nd_tools/lib

package validity;
sub new {
	my $pkg = shift;
	bless{
		opt => undef,
	},$pkg;
}

sub typeid(){
	my $self = shift;
	$self->{'opt'} = shift;

	my $ret = $self->org();
	if($ret eq 1){
		return 1;
	}

	my $ret = $self->vsys();
	if($ret eq 1){
		return 2;
	}

	my $ret = $self->vm();
	if($ret eq 1){
		return 3;
	}

return 0;
}

sub org(){
	my $self = shift;
	if($_[0] ne ""){
		$self->{'opt'} = shift;
	}

	if($self->{'opt'} =~ /^[A-Z0-9]{8}$/){
		return 1;
	}

return 0;
}

sub vsys(){
	my $self = shift;
	if($_[0] ne ""){
		$self->{'opt'} = shift;
	}

	if($self->{'opt'} =~ /^[A-Z0-9]{8}-[A-Z0-9]{9}$/){
		return 1;
	}

return 0;
}

sub vm(){
	my $self = shift;
	if($_[0] ne ""){
		$self->{'opt'} = shift;
	}

	if($self->{'opt'} =~ /^[A-Z0-9]{8}-[A-Z0-9]{9}-S-[0-9]{4}$/){
		return 1;
	}

return 0;
}

sub fmail(){
	my $self = shift;
	my $addr = shift;
	#if($_[0] eq ""){
	#	return 1;
	#}

	if($addr =~ /@.*\.fujitsu\.com/){
		return 1;
	}
return 0;
}

sub ipaddress(){
	my $self = shift;
	my $addr = shift;

	if($addr =~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/){
		return 1;
	}

return 0;
}

sub dom0(){
	my $self = shift;
	my $dom0 = shift;
	if($dom0 =~ /-01-1-ps[0-9]{4}-0[0-8]-[0-9]{2}$/){
		return 1;
	}

	if($self->ipaddress($dom0)){
		return 1;
	}

return 0;
}

package multiRegion;
use env qw(env);
my $base_dir = $env::base_dir;

sub new(){
	my $pkg=shift;
	bless{
		region => undef,
		vsys => undef,
	},$pkg;
}

sub getRegion(){
	my $self=shift;
	my $i = 0;
	open(IN,"$base_dir/exp/showRegion.exp|") or die "Couldn't retrieve the data";
	while(<IN>){
		chomp;
		chop;
		if(/island.-cbrm/){
			@tmp = /[^\s\t|]+/g;
			$self->{'region'}->[$i]->[0] = $tmp[0];
			$self->{'region'}->[$i]->[1] = $tmp[5];
			$i++;
		}
	}

return 0;
}

sub findVMRegion($){
	my $self=shift;
	my $vsys=shift;
	my $obj = new validity;
	my $ret = $obj->typeid($vsys);
	if($ret ne 2){
		return 1;
	}
	open(IN,"$base_dir/exp/getVMRegion.exp $vsys|") or die "Couldn't retrieve the data";
	while(<IN>){
		chomp;
		if(/(island.)-cbrm/){
			$self->{'vsys'}->{"$vsys"} = $1;
		}
	}
	close(IN);
		

return 0;
}

package sdm;
sub new {
	my $pkg = shift;
	bless{},$pkg;
}

sub forceRelease(){
use func qw(validity);
use audit;
	my $obj = new validity();
	my $audit = new audit();
	print "Please enter a VSYS ID which you want to release. \n";
	print ">> ";
	my $vsysID = readline(STDIN);
	chomp $vsysID;
	if($obj->vsys($vsysID)){
		$audit->audit("START releasing $vsysID");
		system("$base_dir/bin/force_release.sh $vsysID");
		my $ret = $?>>8;
		if($ret eq 0){
			$audit->audit("Release $vsysID completed");
		}else{
			$audit->audit("Release $vsysID failed");
			return $ret;
		}
	}else{
		print "Invalid VSYS ID\n\n";
		return 1;
	}

return 0;
}

package web_cgi;

sub new(){
	my $pkg = shift;
	bless{},$pkg;
}

sub hash{
	my $self = shift;
	my $opt = shift;
	chomp($opt);
	my @tmp = split(/&/,$opt);
	foreach my $j(@tmp){
		my @tmp = split(/=/,$j);
		$self->{$tmp[0]} = $tmp[1];
	}
}

;1;
