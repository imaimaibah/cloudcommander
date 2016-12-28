#!/usr/bin/perl

print "Content-type: text/plain\n\n";
while(my($key,$val)=each(%ENV)){
	print "$key : $val\n";
}

print $ENV{'Authorization'}."\n";
