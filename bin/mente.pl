#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir = $env::base_dir;

my $opt = "";

open(IN,"$base_dir/exp/showRegion.exp|") or die "FAILED!!";
while(<IN>){
	chomp;
	chop;
	if(/cbrm/){
		my @tmp = /[^\s\t|]+/g;
		$opt .= "$tmp[0] "
	}
}
close(IN);

system("$base_dir/exp/monitoring_stop.exp $opt");
system("$base_dir/exp/sorry.exp");
