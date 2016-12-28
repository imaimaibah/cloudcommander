#!/usr/bin/perl -I/usr/local/2nd_tools/lib

print "Content-Type: application/json\n\n";

use JSON;

# Define Variables
my $base = "/usr/local/2nd_tools/capacity";
my @type = (\&contract,\&vsys,\&disk,\&deployed_eco);
my $data = {};


############################
##                        ##
##    Main Process        ##
##                        ##
############################

make_data($data);

create_dateData($data);

foreach my $key(keys(%{$data})){
	if($key ne "date"){
		insert_data($data->{$key},$key);
	}
}

my $obj = new JSON();
my $res = $obj->encode($data);
print $res;


############################
##                        ##
##    Define Functions    ##
##                        ##
############################

sub make_data($$){
	my $data = shift;
	my $region = [];
	getRegion($region);

	foreach my $i(@{$region}){
			$data->{$i} = {};
	}

return 0;
}

sub create_dateData($){
	my $data = shift;
	my @date = ();

	opendir(DIR,$base) or die "FAILED";
	foreach my $i(readdir(DIR)){
		if($i ne ".." and $i ne "." and $i ne "lib"){
			opendir(DIR2,"$base/$i");
			foreach my $j(readdir(DIR2)){
				if($j ne ".." and $j ne "."){
					push(@date,$j);
				}
			}
			foreach my $date(sort(@date)){
				push(@{$data->{'date'}},$date);
			}
			closedir(DIR2);
			closedir(DIR);
			return 0;
		}
	}

}

sub getRegion(\@){
	my $region = shift;
push(@$region,'TATEBAYASHI');

	#opendir(DIR,$base);
	#foreach my $i(readdir(DIR)){
	#	if($i ne '.' and $i ne '..' and $i ne 'lib' and -d $i){
	#		push(@{$region},'TATEBAYASHI');
	#	}
	#}
	#closedir(DIR);

return 0;
}

sub insert_data($$){
	my $data = shift;
	my $region = shift;

	opendir(DIR,"$base/$region") or die "FAILED";
	foreach my $dir(sort(readdir(DIR))){
		if($dir ne ".." and $dir ne "."){
			foreach my $func(@type){
				$func->($data,$region,"$base/$region/$dir");
			}
		}
	}
	closedir(DIR);

return 0;
}

############################
##                        ##
##    Data Collection     ##
##                        ##
############################

sub contract($){
	my $data = shift;
	my $region = shift;
	my $dir = shift;
	my $contract = 0;

	open(IN,"$dir/raw/dat.csv") or die "FAILED";
	my %tmp;
	while(<IN>){
		chomp;
		my @tmp = split(/-/);
		$tmp{$tmp[0]} += 1;
	}

	foreach my $cnt(keys(%tmp)){
		$contract++;
	}

	push(@{$data->{'contract'}},$contract);
	close(IN);

return 0;
}

sub vsys($){
	my $data = shift;
	my $region = shift;
	my $dir = shift;
	my $vsys = 0;

	open(IN,"$dir/raw/dat.csv") or die "FAILED";
	my %tmp;
	while(<IN>){
		chomp;
		my @tmp = split(/-/);
		$tmp{$tmp[0].$tmp[1]} += 1;
	}

	foreach my $cnt(keys(%tmp)){
		$vsys++;
	}

	push(@{$data->{'vsys'}},$vsys);
	close(IN);

return 0;
}

sub disk($){
	my $data = shift;
	my $region = shift;
	my $dir = shift;
	my $disk = 0;

	open(IN,"$dir/raw/dat.csv") or die "FAILED";
	my %tmp;
	while(<IN>){
		chomp;
		my @tmp = split(/,/);
		$disk += $tmp[4];
	}

	push(@{$data->{'disk'}},$disk);
	close(IN);

return 0;
}

sub deployed_eco($){
	my $data = shift;
	my $region = shift;
	my $dir = shift;
	my $deployed_eco = 0;

	open(IN,"$dir/raw/dat.csv") or die "FAILED";
	my %tmp;
	while(<IN>){
		chomp;
		my @tmp = split(/,/);
		$tmp{$tmp[0]} += 1;
	}

	foreach my $cnt(keys(%tmp)){
		$deployed_eco += 1;
	}

	push(@{$data->{'deployed_eco'}},$deployed_eco);
	close(IN);

return 0;
}
