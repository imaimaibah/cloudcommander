#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: application/xml\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(web_cgi);
use POSIX ":sys_wait_h";
my  $base_dir = $env::base_dir;
my $primergy = ();
my $json = new JSON;


my $cgi = new web_cgi();
$cgi->hash($Get);

#### DELETE BELOW ####
$cgi->{'island'} = 'islandb';
######################

my $i=0;
my $list = {};
open(IN, "$base_dir/exp/node_list.exp $cgi->{'island'}|") or die "FAILED!!";
while(<IN>){
	chomp;
	s/"//g;
	s/\r//g;
	my @tmp = split(/,/);
	if($tmp[0] =~ /ps[0-9]{4}-[0-9]{2}-[0-9]{2}$/){
		$list->{$tmp[0]}->[0] = $tmp[1];
	}elsif($tmp[0] =~ /(..-..-.-ps[0-9]{4}-[0-9]{2}-[0-9]{2})-ifmnt$/){
		$list->{$1}->[1] = $tmp[1];
	}
}
close(IN);

foreach my $server(keys(%$list)){
	$primergy->[$i]->{$server}->[0] = $list->{$server}->[0];
	$primergy->[$i++]->{$server}->[1] = $list->{$server}->[1];
}
	

parent($primergy);

sub parent($){
	my $pid;
	my $num_child = 32;
	my $primergy = shift;
	my $num = @$primergy;
	if($num < $num_child){
		$num_child = $num;
	}
	open(OUT,">/tmp/primergy.csv");
	$SIG{'CHLD'} = 'sigchild';
	for(my $i=0;$i<$num_child;$i++){
		$pid = forker($primergy->[$i]);
	}

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		if($waitpid ne 0){
			if($num_child < @$primergy){
				$pid = forker($primergy->[$num_child]);
				$num_child++;
			}
		}
	}
	close(OUT);

	open(IN,"/tmp/primergy.csv");
	my $i= 0;
	$tmp = ();
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		$tmp->{$tmp[0]} = [$tmp[1],$tmp[2]];
	}
	close(IN);

	foreach my $j(sort(keys(%$tmp))){
		$data->[$i++]->{$j} = $tmp->{$j};
	}
print $json->encode($data);
print DEBUG $json->encode($data);

return 0;
}

sub sigchild(){
	my ($sig) = @_;
	#print @_;
}

sub forker($){
	my $primergy = shift;
	my $status = "OK";
	if("x$primergy" eq ""){
		return(1);
	}
	my $pid = fork();
	if ($pid == 0) { # Child process
		my ($target) = keys(%$primergy);
		my $ip = $primergy->{$target}->[1];
		open(IN, "$base_dir/exp/pserver_irmc_check.exp $ip 2>&1 |") or die "FAILED!!";
		while(<IN>){
			chomp;
			s/\r//g;
			my @tmp = /[^|]+/g;
			foreach(@tmp){
				s/\s+$//g;
				s/^\s+//g;
			}
			if($tmp[0] ne "" and $tmp[0] ne "Sensor Name" and $tmp[0] !~ /^---/){
  			flock(OUT, 2);
  			seek(OUT, 0, 2);
				if($tmp[4] ne "OK" and $tmp[4] ne "N/A"){
					$status = "NG";
				}
			}
		}
		close(IN);
		$ip = $primergy->{$target}->[0];
		$l=0;
		open(IN,"$base_dir/exp/ServerViewRAID.exp $ip 2>&1 |") or die "FAILED";
		while(<IN>){
			chomp;
			s/\r//g;
			my @tmp = split(/,/);
			if($tmp[1] ne "Operational"){
				$status = "NG";
			}
			$l++;
		}

		if($l ne 3){
			$status = "NG";
		}
		close(IN);
		print OUT "$target,$ip,$status\n";
		flock(OUT,8);
		exit;
	}
return $pid;
}

print DEBUG $hash_json;
close(DEBUG);
