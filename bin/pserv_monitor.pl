#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
my $base_dir = $env::base_dir;
my $flag = shift;
my $argc = @ARGV;
my %data;

if($argc eq 0){
	print "option is not specified.\n";
	exit;
}

# Devide islandx and cb-relay
=pud
foreach my $server(@ARGV){
	my $region;
	if($server =~ /^(island.)-/){
		$region = "$1-sl";
	}elsif($server =~ /(sw|et|ps)([0-9]{4})-..-../){
		my $num = $2;
		$num = sprintf("%d",$num);
		if($num eq 0){
			$region = "cb-relay";
		}else{
			my $island = "a";
			for(my $i = 1;$i<$num;$i++){
				$island++;
			}
			$region = "island".$island."-sl";
		}
	}else{
		$region = "cb-relay";
	}
	push(@{$data{$region}},$server);
}
=cut

# Create CSV
# $key = group, $value = hostname
#while(my($key, $value) = each(%data)){
my %ip;
	open(IN,"$base_dir/exp/node_list.exp all|");
	while(<IN>){
		chomp;
		s/\r//g;
		s/"//g;
		my @tmp = split(/,/);
		$ip{$tmp[0]} = $tmp[1];
	}
	close(IN);
	open(OUT, ">$base_dir/tmp/cb-cmgr-zentai") or die "FAILED!!";
		foreach my $server(@ARGV){
			if($ip{$server} ne ""){
				print OUT "$ip{$server},$server\n";
			}else{
				print "$server is not found in /etc/hosts. Ignore\n";
			}
	}
	close(OUT);

if($flag eq "-s"){
# monitoring stop 
# $key = group, $value = hostname
	#while(my($key, $value) = each(%data)){
		open(IN,"$base_dir/exp/monitor_node_stop.exp cb-cmgr-zentai $base_dir/tmp/cb-cmgr-zentai|");
		while(<IN>){
			chomp;
			s/\r//;
			my @tmp = split(/,/);
			if($tmp[2] eq 5){
				print "$tmp[0]\t[STOP]\n";
			}else{
				print "$tmp[0]\t[FAILED]\n";
			}
		}
		close(IN);
	#}
}elsif($flag eq "-r"){
# monitoring start
# $key = group, $value = hostname
	#while(my($key, $value) = each(%data)){
		open(IN,"$base_dir/exp/monitor_node_start.exp cb-cmgr-zentai $base_dir/tmp/cb-cmgr-zentai|");
		while(<IN>){
			chomp;
			s/\r//;
			my @tmp = split(/,/);
			if($tmp[2] eq 0 or $tmp[2] eq 2){
				print "$tmp[0]\t[START]\n";
			}else{
				print "$tmp[0]\t[FAILED]\n";
			}
		}
		close(IN);
	#}
}else{
	print "Invalid option specified\n";
	exit 1;
}

