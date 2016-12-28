#!/usr/bin/perl

use strict;
use threads; 
use Thread::Queue;
my $queue = Thread::Queue->new();

$| = 1;

my @producer;
my %handler;
my @dom0 = ("jp-01-1-ps0000-08-28",
						"jp-01-1-ps0000-08-29");

sub producer_main(){
	my @option = @_;
	foreach my $option(@option){
		print $option."\n";
	}

return 0;
}

my $j=0;
for(my $j=0;$j<@dom0;$j++){
#foreach my $i(@dom0){
	my $producer = threads->new(\&producer_main,$dom0[$j],"xm list",$j);
	push(@producer,$producer);
}

foreach my $i(@producer){
	$i->join; 
	while(my $result = $queue->dequeue_nb()){
		print $result."\n";
	}
}


