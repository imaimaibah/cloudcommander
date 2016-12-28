#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use func qw(multiRegion);
my $vm = shift;
my @tmp = split(/-/,$vm);
my $vsys = $tmp[0]."-".$tmp[1];
my $obj = new multiRegion;


$obj->findVMRegion($vsys);
print $obj->{'vsys'}->{$vsys};
