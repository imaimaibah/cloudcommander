#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-type: application/json\n\n";
my $Post = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(web_cgi);
my  $base_dir = $env::base_dir;
my $cgi = new web_cgi;
$cgi->hash($Post);
my $cmd;
my $func;
my $data = ();

#Delete below before deploy#
#$cgi->{'eternus'} = "10.1.1.5";
############################

main($cgi->{'eternus'});

sub main($){
	my $eternus = shift;

open(IN, "$base_dir/exp/eternus_cmd.exp $eternus|") or die "FAILED!!";

my $func;
my $type;
while(<IN>){
	chomp;
	s/\r//g;
	if(/^(ENCLOSURE)$/){
		$func = \&enclosureStatus;
		$type = $1;
	}elsif(/^(CE|DE #1|DE #2)$/){
		$func = \&ceStatus;
		$type = $1;
	}

	$func->($_,$type);
}
close(IN);

my $obj = new JSON();
my $hash_json = $obj->encode($data);
print $hash_json;
}


sub enclosureStatus(){
	my $line = shift;
	my $type = shift;

	if($line =~ /^\sName\s*\[(.*?)\]/){
		$data->{'hostname'} = $1;
	}elsif($line =~ /^\sSerial Number\s*\[(.*?)\]/){
		$data->{'serial'} = $1;
	}elsif($line =~ /^\sStatus\s*\[(.*?)\]/){
		$data->{'status'} = $1;
	}elsif($line =~ /\sController Enclosure \([0-9]\.5"\)\s*\[(.*?)\]/){
		$data->{'ce_status'} = $1;
	}elsif($line =~ /\sDrive Enclosure #0?1 \([0-9]\.5"\)\s*\[(.*?)\]/){
		$data->{'de1_status'} = $1;
	}elsif($line =~ /\sDrive Enclosure #0?2 \([0-9]\.5"\)\s*\[(.*?)\]/){
		$data->{'de2_status'} = $1;
	}elsif($line =~ /\sFirmware Version\s*\[(.*?)\]/){
		$data->{'firmware'} = $1;
	}

return 0;
}

sub ceStatus(){
	my $line = shift;
	my $type = shift;

	if($line =~ /Disk#/){
		my @tmp = $line =~ /(Disk#[0-9]{1,2}).*?\[(.+?)\]/g;
		for(my $i=0;$i<@tmp;$i++){
			$tmp[$i+1] =~ s/\s*$//g;
			push(@{$data->{$type}},$tmp[++$i]);
		}
	}

return 0;
}
