#!/usr/bin/perl

require "/usr/local/2nd_tools/lib/env.pm";
my $base_dir=$env::base_dir;

my $file = $ARGV[0] || die "file is not specified";
my $server = ();

open(IN, "$base_dir/$file") or die "cannot read $file";
while(<IN>){
	chomp;
	my @data = split;
	push(@{$server->{$data[0]}},$data[1]);
}
close(IN);

while((my $key,my $value) = each(%{$server})){
	for(my $i=0;$i<3;$i++){
		if("$value->[$i]" ne "------"){
			last;
		}
		if($i eq 2){
			print "Possible hang state $key\n";
		}
	}
}
