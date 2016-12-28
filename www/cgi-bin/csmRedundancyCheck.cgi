#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/xml\n\n";
my $Post = $ENV{'QUERY_STRING'};

use env;
use JSON;
my $base_dir = $env::base_dir;
my $data = ();
#open(IN, "$base_dir/bin/send_shell.sh -f $base_dir/csmCKRedundancy/csmCKRedundancy -h 'islanda-cbrm' -p sv\@01011 -u root|") or die "FAILED!!";
open(IN, "/home/shin.imai/csmRedundancy.log");
while(<IN>){
	chomp;
	my @tmp = split(/\s/);
	my $vdisk = shift(@tmp);
	my $start;
	my $end;
	my $dom0;
	my $status;
	my $i = 0;
	foreach my $j(@tmp){
		if($j =~ /^NML=(.*)$/){
			$start = &format($1);
			$status = "Normal";
		} elsif($j =~ /^ERR=(.*)$/) {
			$start = &format($1);
			$status = "Error";
		} elsif($j =~ /^on$/) {
			$dom0 = $tmp[$i+1]; 
		} elsif($j =~ /^END=(.*)$/) {
			$end = &format($1);
		}
		$i++;
	}
$data->{$vdisk} = [$status,$end];
}
close(IN);

while(my($key,$val) = each(%{$data})){
	print "$key  ";
	foreach my $j(@$val){
		print "$j  ";
	}
	print "\n";
}

sub format(){
	my $time = shift;
	my @tmp = split(/-/,$time);
	my $tmp = sprintf("%02d",$tmp[1]);
	if($tmp[0] eq "Jan"){
		$tmp[0] = "01";
	}elsif($tmp[0] eq "Feb"){
		$tmp[0] = "02";
	}elsif($tmp[0] eq "Mar"){
		$tmp[0] = "03";
	}elsif($tmp[0] eq "Apr"){
		$tmp[0] = "04";
	}elsif($tmp[0] eq "May"){
		$tmp[0] = "05";
	}elsif($tmp[0] eq "Jun"){
		$tmp[0] = "06";
	}elsif($tmp[0] eq "Jul"){
		$tmp[0] = "07";
	}elsif($tmp[0] eq "Aug"){
		$tmp[0] = "08";
	}elsif($tmp[0] eq "Sep"){
		$tmp[0] = "09";
	}elsif($tmp[0] eq "Oct"){
		$tmp[0] = "10";
	}elsif($tmp[0] eq "Nov"){
		$tmp[0] = "11";
	}elsif($tmp[0] eq "Dec"){
		$tmp[0] = "12";
	}

	my $new = "$tmp[0]-$tmp-$tmp[2]";

return $new;
}
