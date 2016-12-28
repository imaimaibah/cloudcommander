#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use JSON;
my $base_dir = $env::base_dir;
my $data = ();
my $obj = new JSON;
my $today = $env::today;
my $hour = sprintf("%02d",--$env::hour);

my $capaDir = "/data/trend/$today/$hour";

print "Island,ContractID,VMID,status,image_id,sysvol,VM Type\n";

open(IN,"$capaDir/lserver.log") or die $!;
while(<IN>){
	chomp;
	s/\r//g;
	if(/[A-Z0-9]{8}/){
		my @tmp = $_ =~ /[^\s|]+/g;
		my ($island) = split(/_|-/,$tmp[7]);
		push(@{$data->{$island}->{$tmp[0]}},[$tmp[2],$tmp[3],$tmp[4],$tmp[5],$tmp[6]]);
	}
}
close(IN);

while(my($key,$val)=each(%$data)){
	while(my($key1,$val1)=each(%$val)){
		foreach my $val2(@$val1){
			print $key.",".$key1.",";
			foreach my $val3(@$val2){
				print $val3.",";
			}
			print "\n";
		}
	}
}
