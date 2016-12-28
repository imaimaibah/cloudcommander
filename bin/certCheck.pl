#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use Time::Local;

my @server = ("172.16.0.211","172.16.0.212");

foreach my $server(@server){
	check($server);
}

sub check($){

my $server = shift;
my $tmp = `mktemp`;
chomp($tmp);

open(IN,"openssl s_client -connect $server:443 < /dev/null 2>&1|") or return 1;
open(OUT,"|openssl x509 -text|grep 'Not After' >$tmp") or return 1;
while(<IN>){
	if(/-----BEGIN CERTIFICATE-----/){
		print OUT;
		while(<IN>){
			if(/-----END CERTIFICATE-----/){
				print OUT;
				last;
			}
			print OUT;
		}
	}
		
}
close(OUT);
close(IN);

open(IN,$tmp);
while(<IN>){
	chomp;
	my @tmp = $_ =~ /[^\s]+/g;
	my $month = $tmp[3];
	my $day = $tmp[4];
	my $time = $tmp[5];
	my($hour,$min,$sec) = split(/:/,$time);
	my $year = $tmp[6];
	$month1 = convert($month);
	my $t = timelocal($sec, $min, $hour, $day, $month1, $year-1900);
	my $now = time();
	my $diff = $t - $now;
	if($diff < 7776000){
		if(-e "/tmp/certFlag"){
			my $past;
			open(IN,"/tmp/certFlag");
			while(<IN>){
				chomp;
				$past = time() - $_;
			}
			close(IN);
			if($past > 604800){
				system("logger -p 'user.err' 'The expiry date of the certificate for $server is approaching - $year $month $day $time'");
				open(OUT,">/tmp/certFlag");
				print OUT time();
				close(OUT);
			}
		}else{
			system("logger -p 'user.err' 'The expiry date of the certificate for $server is approaching - $year $month $day $time'");
			open(OUT,">/tmp/certFlag");
			print OUT time();
			close(OUT);
		}
	}else{
		system("logger -p 'user.err' '$server - OK - $year $month $day $time'");
	}

}
close(IN);

unlink($tmp);
}

sub convert($){
	my $month = shift;

	if($month eq "Jan"){
		return "00";
	}elsif($month eq "Feb"){
		return "01";
	}elsif($month eq "Mar"){
		return "02";
	}elsif($month eq "Apr"){
		return "03";
	}elsif($month eq "May"){
		return "04";
	}elsif($month eq "Jun"){
		return "05";
	}elsif($month eq "Jul"){
		return "06";
	}elsif($month eq "Aug"){
		return "07";
	}elsif($month eq "Sep"){
		return "08";
	}elsif($month eq "Oct"){
		return "09";
	}elsif($month eq "Nov"){
		return "10";
	}elsif($month eq "Dec"){
		return "11";
	}
return 0;
}
