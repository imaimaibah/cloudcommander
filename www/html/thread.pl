#!/usr/bin/perl

use strict;
use threads;

my @threads;

print "Create threads\n";
foreach (1 .. 5){
	my $thread = threads->new(\&my_thread, $_);
	push(@threads, $thread);
}

print "Join threads \n";


foreach(@threads){
	my $return = $_->join;
	print "$return closed\n";
}

# スレッドの処理
sub my_thread {
	my $i = shift;
	system("ls;sleep $i");
return ($i);
}
