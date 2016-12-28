#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir = $env::base_dir;

my $domu = "";
my $vdisk = "";
while(my $arg = shift){
	if($arg eq "--domu"){
		$domu = shift;
	}elsif($arg eq "--vdisk"){
		$vdisk = shift;
	}
}

if($domu ne ""){
	domu($domu);
}elsif($vdisk ne ""){
	vdisk($vdisk);
}else{
	usage();
}


### Functions ###
sub domu($){
	my $domu = shift;
	my @provider = @{gather_disks($domu)};
	my %tmp;
	@provider = grep(!$tmp{$_}++,@provider);

return 0;
}

sub vdisk($){
	my $vdisk = shift;
	my $opt = '-v';
	my @provider = @{gather_disks($vdisk, $opt)};
	@provider = grep(!$tmp{$_}++,@provider);

return 0;
}

sub usage(){
	print <<EOF;
Option : [--domu <DomU name> | --vdisk <Vdisk ID> ]
EOF

exit 1;
}

sub gather_disks($$){
	my $domu = shift;
	my $opt = shift;
	my @disk = ();
	open(IN,"expect -f $base_dir/exp/gather_providers.exp $domu $opt 2> /dev/null|") or die "Cannot execute";
	while(<IN>){
		chomp;
		push @disk,$_;
	}
	close(IN);

return \@disk;
}
