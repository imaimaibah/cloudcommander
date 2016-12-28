#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use func qw(multiRegion);
my $base_dir = $env::base_dir;
my $obj = new multiRegion();
$obj->getRegion();
my $sw = ();

foreach my $region(@{$obj->{'region'}}){
	my @tmp = split(/-/,$region->[0]);

	my $data = create_data("$base_dir/data/$tmp[0]-cnm.dat");
	if($ret eq 0){
		exit 0;
	}
	foreach my $j(@$data){
		my $node;
		my $ip;
		my $pass;
		while(my($key,$val) = each(%$j)){
			$key =~ s/^\s+//;
			if($key eq 'node_name'){
				$node = $val;
			}elsif($key eq 'ipaddress'){
				$ip = $val;
			}elsif($key eq 'ssh_pass_1'){
				$pass = $val;
			}
		}
		@{$sw->{$node}} = ($ip,$pass);
	}
}

while(my($key,$val) = each(%$sw)){
	if($key =~ /sw00/){
		system("expect $base_dir/exp/fjswitch.exp $val->[0] $val->[1]");
	}
}

sub create_data(){
	my $data = ();
	my $file = $_[0];
	open(IN, "$file") or die "Cannot read a file";
	my $num = 0;
	while(<IN>){
		chomp;
		s/\r//g;
		if(/^\[([0-9]+)\]/){
			$num = $1;
			next;
		}elsif(/^$/){
			next;
		}elsif(!/^(\t| ).*$/){
			next;
		}

		my @temp = ();
		@temp = split(/:/);
		$temp[1] =~ s/^(\t| )*//;
		$data->[$num]->{$temp[0]} = $temp[1];

	}

	shift(@{$data});
return $data;
}
