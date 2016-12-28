#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: application/json\n\n";

use env;
use JSON;
use auth;
use func(web_cgi);

my $user = $ENV{'AUTHENTICATE_UID'};
my $Get = $ENV{'QUERY_STRING'};
my $base_dir = $env::base_dir;
my $auth = new auth($user);
my $json = new JSON;
my $cgi = new web_cgi();
my $data = ();

$cgi->hash($Get);
#$cgi->{'code'} = 'SIN';

backup($cgi->{'code'});

open(OUT,">/data/cgi-bin/billing_system_honbandesu/tables/host_lead_$cgi->{'code'}.table") or die $!;
read (STDIN, my $Post, $ENV{'CONTENT_LENGTH'});
my $data = $json->decode($Post);
my $line = "";
foreach my $j(@{$data->{'data'}}){
	foreach my $l(@$j){
print DEBUG $l."\n";
		if($l eq "Canceled" or $l eq "Charge"){
			$l = 1;
		}elsif($l eq "Active" or $l eq "FoC"){
			$l = 0;
		}elsif($l eq "MID"){
			$l = 2;
		}
	
		$line .= $l.","
	}
	chop($line);
	print OUT "$line\r\n";
	$line = "";
}
close(OUT);

sub backup(){
	my $code = shift;
	system("cp -p /data/cgi-bin/billing_system_honbandesu/tables/host_lead_$code.table /data/cgi-bin/billing_system_honbandesu/tables.backup/host_lead_$code-$env::today.table");

}
close(DEBUG);
