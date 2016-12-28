#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use Getopt::Long;

use env;
use func qw(multiRegion);
my $base_dir = $env::base_dir;
my $region = $env::region;
my $region_num = $env::region_num;
my $obj = new multiRegion();
$obj->getRegion();

my $data = ();
GetOptions(\%opt, 'what-contains=s');

if("x$opt{'what-contains'}" eq "x"){
	show_usage();
	exit 127;
}


#my $file = "$base_dir/data/islanda-cnm.dat";
foreach my $region(@{$obj->{'region'}}){
	my @tmp=split(/-/,$region->[0]);
if($tmp[0] ne 'islanda' and $main::region ne "JP"){
	next;
}
	my $data = create_data("$base_dir/data/$tmp[0]-cnm.dat");
	my $ret = show($data,$opt{'what-contains'});
	if($ret eq 0){
		exit 0;
	}
}

$data = create_data($file);
my $ret = show($data,$opt{'what-contains'});
if($ret eq 1){
	$data = ();
	$file = "$base_dir/data/region-cnm.dat";
	$data = create_data($file);
	$ret = show($data,$opt{'what-contains'});
}

exit $ret;

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

sub show(){
	my $data = $_[0];
	my $contained = $_[1];
	my $num = '';

	for(my $i=0;$i<=$#$data;$i++){
		while ((my $key, my $value) = each(%{$data->[$i]})){
			if($value eq $contained){
				$num = $i;
			}
		}
		
	}

	if($num ne ''){
		foreach my $key (sort keys %{$data->[$num]}){
			print $key.": ".$data->[$num]->{$key}."\n";
		}
	} else {
		return 1;
	}

return 0;
}

sub show_usage(){

return 0;
}
