#!/usr/bin/perl -I/usr/local/2nd_tools/lib

#Version: 1.1

use env;
use POSIX ":sys_wait_h";

my $base_dir = $env::base_dir;
my @ip;
my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )  =  localtime(time() - 86400);
$sec= sprintf("%02d", $sec);
$min= sprintf("%02d", $min);
$hour = sprintf("%02d", $hour);
$mday = sprintf("%02d", $mday);
$mon = sprintf("%02d",++$mon);
$year += 1900;
my $yesterday = "$year-$mon-$mday";

open(IN,"$base_dir/exp/releaseGIP.exp $yesterday|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	if(/[A-Z0-9]{8}-[A-Z0-9]{9}/){
		my @tmp = $_ =~ /[^\s|]/g;
		push(@ip,$tmp[1]);
	}
}
close(IN);

$SIG{PIPE} = sub { die "oops, $program pipe broke" };

my $pid = open(KID_TO_WRITE, "|-");

if ($pid) {
	foreach $ip(@ip){
		print KID_TO_WRITE "$ip\n";
	}
} else {
	($EUID, $EGID) = ($UID, $GID);
	$grand = open(GRAND_TO_WRITE, "|-");
	if($grand){
		open(STDOUT,'>&=',fileno(GRAND_TO_WRITE)) or die "FAILED";
		open(OUT,"|$base_dir/exp/nslookup.exp") or die "FAILED";
		while(<STDIN>){
			s/\r//g;
			print OUT "$_";
		}
		close(OUT);
	}else{
	($EUID, $EGID) = ($UID, $GID);
		my %data;
		while(<STDIN>){
			s/\r//g;
			if(/([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}) START$/){
				$data{$1} = 1;
			}

			if(/server can't find ([0-9]{0,3})\.([0-9]{0,3})\.([0-9]{0,3})\.([0-9]{0,3})\.in-addr\.arpa\.: NXDOMAIN/){
				my $ip = "$4.$3.$2.$1";
				delete($data{$ip});
			}
		}

		action(\%data);

	}
}

sub action($){
	my $data = shift;
	if(!scalar(keys(%$data))){
		return 0;
	}

	foreach my $ip(keys(%$data)){
		system("logger -p 'user.err' 'GIP is released and seems still registered in the DNS reverse lookup entries. Please remove the IP from the entries.'");
		system("logger -p 'user.err' '$ip needs to be deregistered'");
	}

	open(SMTP,"|$base_dir/pl/smtp.pl -f GCP_administrator\@jp.fujitsu.com -t c3s-global-suppport-2nd\@ml.css.fujitsu.com -s '$env::region GIP has been released.' > /dev/null");
	print SMTP <<EOF;
Release of GIP registered in the reverse lookup record has been detected.
Please remove the GIP from the entries.

EOF
#	foreach my $gip(keys(%$data)){
#		print SMTP $gip."\n";
#		print OUT $gip."\n";
#	}
	close(SMTP);
}
