#!/usr/bin/perl -I/usr/local/2nd_tools/lib
open(DEBUG,">/tmp/debug.log");

print "Content-type: application/json\n\n";
use env;
use Time::Local;
use JSON;
use func qw(web_cgi);
my $cgi = new web_cgi;
my $Get = $ENV{'QUERY_STRING'};
$cgi->hash($Get);
$" = ",";
my $obj = new JSON;

my $data = ();
my $base_dir = $env::base_dir;

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )  =  localtime(time() - 86400);
$mon = sprintf("%02d",$mon);
$year += 1900;
if($mon eq "00"){
	$mon = "12";
	$year--;
}
my $lastmonth = "$year-$mon";

open(IN,"$base_dir/exp/simon/simon2.exp $lastmonth|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	my @tmp = split(/,/);
#### INFO
# $tmp[0] - Time
# $tmp[4] - Status(Task ID)
#	$tmp[5] - VMID;
# $tmp[7] - migration type
# $tmp[9] - FROM Physical ID
# $tmp[10] - TO Physical ID
	my ($time) = split(/\./,$tmp[0]);
	my ($status,$taskid) = $tmp[4] =~ /(Completed|Starting)\((island.-cbrm_[0-9]+)\)/;
	my($resourceID,$vmid) = $tmp[5] =~ /(island.-cbrm_[0-9]+)\(([A-Z0-9]{8}-[A-Z0-9]{9}-S-[0-9]{4})\)/;
	my($migration) = $tmp[7] =~ /mode="(.*)"/;
	my $from = "";
	my $to = "";
	for(my $i=8;$i<=10;$i++){
		($from) = $tmp[$i] =~ /from_rid="(.*)"/;
		if($from ne ""){
			last;
		}
	}

	for(my $i=8;$i<=10;$i++){
		($to) = $tmp[$i] =~ /to_rid="(.*)"/;
		if($to ne ""){
			last;
		}
	}

	if($status eq "Starting"){
		@{$data->{$resourceID}->{$taskid}->[0]} = ($time,$vmid,$migration,$from,$to,$status);
	}elsif($status eq "Completed"){
		@{$data->{$resourceID}->{$taskid}->[1]} = ($time,$vmid,$migration,$from,$to,$status);
	}

}
close(IN);

my $json = ();
$json->{"data"} = ();
@{$json->{'data'}->[0]} = ("Resource ID","VM ID","Physical Server ID","Start Time","Stop Time","Number of Physical CPU","Number of Virtual CPU Core","Number of Physical CPU Core","Migration");
my $i = 1;
my $type;
if($cgi->{'type'} eq 'enterprise'){
	$type = "Enterprise";
} elsif($cgi->{'type'} eq 'standard'){
	$type = "Standard";
}
open(IN,"$base_dir/exp/simon/simon.exp $lastmonth $type|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	my @tmp = split(/,/);
	if($tmp[0] !~ /island.-cbrm_[0-9]+/){
		next;
	}

if(!defined($data->{$tmp[0]})){
	@{$json->{"data"}->[$i]} = @tmp;
	if($json->{"data"}->[$i]->[8] eq ""){
		$json->{"data"}->[$i]->[8] = "-";
	}
	$i++;
	next;
}

#Start
	@{$json->{"data"}->[$i]}= @tmp;
	while(my($key,$val)=each(%{$data->{$tmp[0]}})){
		my $stime = to_sec($val->[0]->[0]);
		my $ctime = to_sec($val->[1]->[0]);
		my $time1 = to_sec($tmp[3]);
		my $time2 = to_sec($tmp[4]);

		if($ctime eq $time2 and $tmp[2] eq $val->[1]->[3]){
			push(@{$json->{"data"}->[$i]},"$val->[0]->[2] Started");
		}

		if($ctime eq $time1 and $tmp[2] eq $val->[1]->[4]){
			push(@{$json->{"data"}->[$i]},"$val->[0]->[2] Completed");
		}
	}
	if($json->{"data"}->[$i]->[8] eq ""){
			$json->{"data"}->[$i]->[8] = "-";
	}
	$i++;

}

close(IN);

	print $obj->encode($json);
close(DEBUG);

sub to_sec($){
	my $time = shift;

	my($year,$month,$day,$hour,$min,$sec) = $time =~/([0-9]{4})-([0-9]{2})-([0-9]{2}).([0-9]{2}):([0-9]{2}):([0-9]{2})/;
#	my $t = timelocal($sec, $min, $hour, $day, $month-1, $year-1900);
	$t = $year.$month.$day.$hour.$min.$sec;


return $t;
}

sub test($){
	my $data = shift;

	while(my($key,$val)=each(%$data)){
		foreach my $val1(@$val){
			print "$key,";
			foreach my $val2(@$val1){
				print "$val2,";
			}
			print "\n";
		}
	}
}
