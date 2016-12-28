#!/usr/bin/perl

print "Content-type: text/html\n\n";

open(OUT,">/tmp/post_data.txt");

while(<STDIN>){
	print OUT;
}
close(OUT);
