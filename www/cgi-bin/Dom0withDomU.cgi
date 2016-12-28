#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use JSON;

print "Content-type: application/json\n\n";
my $base_dir = $env::base_dir;
my $dom0 = ();
my %tmp;

open(IN, "$base_dir/pl/getAllDomU.pl|") or die "FAILED!!";
while(<IN>){
	chomp;
	s/\r//g;
	my @tmp = split(/,/);
	$tmp{$tmp[0]} = $tmp[1];
}
close(IN);

my $i = 0;
foreach my $j(sort(keys(%tmp))){
	$dom0->[$i]->{$j} = $tmp{$j};
	$i++;
}

=pud

open(IN, "$base_dir/exp/Dom0withDomU.exp $island|") or die "FAILED!!";
my @data = ();
my $i = 0;


my $tmp = ();
while(<IN>){
	chomp;
	if(/(..-..-.-ps[0-9]{4}-[0-9]{2}-[0-9]{2})[\s\t]+([^\s\t]+)/){
		my $dom0 = $1;
		my $status = $2;
		$tmp->{$dom0} = $status;
	}elsif(/^###SERVER LIST###$/){
			last;
	}
}

while(<IN>){
	chomp;
	s/\r//g;
	if(/LServer name="(.*?)"/){
		$data[$i][0] = $1;
	}elsif(/VmHost name="(.*?)"/){
		$data[$i][1] = $1;
	}elsif(m!</LServer>!){
			$i++;
	}
}
close(IN);

foreach my $i(@data){
	if($i->[1] ne ""){
		push(@{$tmp->{$i->[1]}},$i->[0]);
	}
}

my $l=0;
foreach my $i(sort(keys(%{$tmp}))){
	@{$dom0->[$l]->{$i}} = @{$tmp->{$i}};
	$l++;
}
=cut

my $obj = new JSON();
my $hash = $obj->encode($dom0);
print $hash;
