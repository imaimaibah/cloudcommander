#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use func qw(multiRegion);
$base_dir = $env::base_dir;
my $obj = new multiRegion();

# Get island list
$obj->getRegion();
my @region = @{$obj->{'region'}};
my $output = "$base_dir/capacity/raw/dat.csv";
my $output2 = "$base_dir/capacity/raw/storage.csv";
my $output3 = "$base_dir/capacity/raw/gip_list.csv";
my $output4 = "$base_dir/capacity/raw/product.csv";
if(!-e "$base_dir/capacity/raw"){
	mkdir("$base_dir/capacity/raw");
}
my %image;
my %vdisk;

# Create Image List
open(IN, "$base_dir/exp/capacity2.exp|") or die "FAILED!!";
my $flag = 0;
while(<IN>){
	chomp;
	chop;
	my @tmp;
	if(/IMG_/){
		@tmp = /[^|]+/g;
	}else{
		next;
	}
	my $id = shift(@tmp);
	($id) = $id =~ /^\s+(.*?)\s+$/;
	foreach my $youso(@tmp){
		($youso) = $youso =~ /^\s+(.*?)\s+$/;
		push(@{$image{$id}},$youso);
	}
}
close(IN);

open(OUT,">$output4") or die "FAILED!!";
while(my($key,$val) = each(%image)){
	print OUT "$key";
	foreach my $os(@$val){
		print OUT ",$os";
	}
	print OUT "\n";
}
close(OUT);

# Create VDisk List
open(IN,"$base_dir/exp/capacity4.exp|") or die "FAILED!!";
$flag = 0;
while(<IN>){
	chomp;
	chop;
	my @tmp;
	if(/^server_id/){
		$flag++;
		next;
	}elsif(/^vsys_id/){
		$flag = 0;
		next;
	}
	@tmp = /[^\s\t]+/g;
	if($flag eq 0){
		@{$vdisk{$tmp[0]}}=($tmp[1],$tmp[2]);
	}else{
		$sysvol{$tmp[0]}=$tmp[1];
	}
}
close(IN);
open(OUT, ">$base_dir/capacity/raw/vdisk.csv") or die "FAILED!!";
foreach my $element(keys(%vdisk)){
	print OUT $element.",".$vdisk{$element}[0].",".$vdisk{$element}[1]."\n";
}
close(OUT);

# Create GIP List
open(IN, "$base_dir/exp/capacity3.exp|") or die "FAILED!!";
open(OUT, ">$base_dir/capacity/raw/gip.csv") or die "FAILED!!";
$flag=0;
while(<IN>){
	chomp;
	chop;
	@tmp = split(/:/);
	foreach my $tmp(@tmp){
		$tmp=~s/^[\s\t]*//g;
		$tmp=~s/[\s\t]*$//g;
	}
	print OUT "$tmp[0]:$tmp[1]\n";
}
close(OUT);
close(IN);

# Create Global IP list
open(IN, "$base_dir/exp/capacity5.exp|") or die "FAILED!!";
open(OUT, ">$output3") or die "FAILED!!";
while(<IN>){
	chomp;
	my @tmp;
	if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
		@tmp = /[^\s\|\t]+/g;
		print OUT "$tmp[0],$tmp[1]\n";
	}
}
close(OUT);
close(IN);


open(OUT, ">$output") or die "file $output cannot be written";
open(OUTS,">$output2") or die "FAILED!!";
foreach $region(@region){

# Gather RoR data
open(IN, "$base_dir/exp/capacity1.exp $region->[0]|") or die "FAILED!!";
my @data = ();
my $i = 0;
my $m = 0;
my @size;

while(<IN>){
	if(/LServer name="(.*?)"/){
		$data[$i][0] = $1;
	}elsif(/VmHost name="(.*?)"/){
		$data[$i][1] = $1;
	}elsif(/TemplateLink name="(.*?)"/){
		$data[$i][2] = $1;
		if($data[$i][2] eq "economy"){
			$data[$i][2] = 1;
		}elsif($data[$i][2] eq "standard"){
			$data[$i][2] = 2;
		}elsif($data[$i][2] eq "advanced"){
			$data[$i][2] = 4;
		}elsif($data[$i][2] eq "high_performance"){
			$data[$i][2] = 8;
		}
	}elsif(/ServerImageLink name="(.*?)"/){
		$data[$i][3] = $1;
	}elsif(m!</LServer>!){
			$i++;
	}

	if(m!<spz_total_size unit='MB'>(.*)</spz_total_size>!){
		$size[$m] = $1;
		$m++;
	}

	if(m!<spz_free_size unit='MB'>(.*)</spz_free_size>!){
		$size[$m] = $1;
		$m++;
	}

	if(m!<spz_initialization_size unit='M?B'>(.*)</spz_initialization_size>!){
		$size[$m] = $1;
		$m++;
	}
		
}
close(IN);


for(my $i = 0;$i<=$#data;$i++){
	# Exclude Management CBs
	if($data[$i][0] =~ /(SOPMGTCB|INTER-REGION)/){
		next;
	}
	$data[$i][4] = $sysvol{$data[$i][0]};
	print OUT $data[$i][0].','.$data[$i][2].','.$data[$i][1].','.$data[$i][3].','.$data[$i][4].',',$region->[0]."\n";
}

# Eternus Pool Disk Space
print OUTS <<EOF;
Total,$size[0],$size[3],$region->[0]
Free,$size[1],$size[4],$region->[0]
Zero,$size[2],$size[5],$region->[0]
EOF
}
close(OUT);
close(OUTS);


# Defined Functions
sub os_name(){
	my $product = shift;
	my $tmp;

open(IN2, "$output4") or die "FAILED!!";
while(<IN2>){
	chomp;
	my @tmp = split(/,/);
	if($tmp[0] eq $product){
		shift(@tmp);
		foreach my $name(@tmp){
			$tmp .= "$name + ";
		}
		$tmp =~ s/ \+ $//;
		close(IN2);
		return $tmp;
	}
}
close(IN2);
return 0;
}
