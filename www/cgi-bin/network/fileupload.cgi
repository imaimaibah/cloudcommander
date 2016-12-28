#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use CGI;

print "Content-type: text/html\n\n";
my $Get = $ENV{'QUERY_STRING'};

my ($cgi,$fileName);
$cgi = new CGI;
$fileName = $cgi->param('fileName');

open(OUT, ">Contract_id_list");
binmode(OUT);
while(read($fileName,$buffer,102400)){
		print OUT $buffer;
}

close(OUT);
close($fileName);
