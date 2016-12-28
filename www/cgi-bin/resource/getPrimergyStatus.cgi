#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/xml\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Get);
my $cmd;
my $data = ();
my $json = new JSON();

#### DELETE BELOW ####
$cgi->{'primergy'} = 'jp-01-1-ps0000-08-14';
######################

my $irmc;

open(IN,"$base_dir/exp/node_list.exp all|grep $cgi->{'primergy'}|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	s/"//g;
	my @tmp = split(/,/);
	if($tmp[0] eq "$cgi->{'primergy'}-ifmnt"){
		$irmc = $tmp[1];
	}
}
close(IN);

#if($cgi->{'option'} eq "iRMC"){
	my @tmp = split(/\./,$cgi->{'primergy'});
	$tmp[1]++;
	open(IN, "$base_dir/exp/pserver_irmc_check.exp $irmc|") or die "FAILED!!";
	my $i=0;
	while(<IN>){
		chomp;
		s/\r//g;
		if(/-+\+-+/ or /Sensor Name/ or /Signal.*Sensor/ or /^$/){
			next;
		}

		my @tmp = split(/\|/);
		foreach my $j(@tmp){
			$j =~ s/^\s+//g;
			$j =~ s/\s+$//g;
		}
		$data->{'irmc'}->{$tmp[0]} = $tmp[4];

		$i++;
	}
	close(IN);
#}elsif($cgi->{'option'} eq "dom0"){
	my $cmd = "xm list";
	open(IN, "$base_dir/exp/pserver_cmd.exp $cgi->{'primergy'} '$cmd'|") or die "FAILED!!";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/Name/ or /Domain-0/){
			next;
		}

		my @tmp = $_ =~ /[^\s]+/g;
		push(@{$data->{'domU'}},$tmp[0]);
	}
	close(IN);
	$cmd = 'tail -20 /var/log/messages';
	open(IN, "$base_dir/exp/pserver_cmd.exp $cgi->{'primergy'} '$cmd'|") or die "FAILED!!";
	my $i = 0;
	while(<IN>){
		chomp;
		s/\r//g;
		push(@{$data->{'syslog'}},$_);
	}
	close(IN);
#}else{
#	print "Choose one of the options\n";
#	exit;
#}

print $json->encode($data);
