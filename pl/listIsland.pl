#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use func qw(multiRegion);
my $obj = new multiRegion;

$obj->getRegion();
foreach my $region(@{$obj->{'region'}}){
	if($region->[1] eq "active"){
		print $region->[0]."\n";
	}
}
