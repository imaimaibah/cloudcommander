#!/usr/bin/perl

#use strict;
use POSIX ":sys_wait_h";
require "/usr/local/2nd_tools/lib/env.pm";
my $base_dir = $env::base_dir;
my $region = $env::region;
my $region_num = $env::region_num;

parent($ARGV[0]);

sub parent($){
	my $pid;
	my $num_child = shift || 8;
	my $obj = new create_list();
	$obj->eternus();
	if(@{$obj->{'data'}} < $num_child){
		$num_child = @{$obj->{'data'}};
	}
	$SIG{'CHLD'} = 'sigchild';
	for(my $i=0;$i<$num_child;$i++){
		$pid = forker($obj->{'data'}->[$i]);
		if($pid ne '1'){
			print "$pid Started\n";
		}
	}

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		if($waitpid ne 0){
			print "$waitpid has finished\n";
			if($num_child < @{$obj->{'data'}}){
				$pid = forker($obj->{'data'}->[$num_child]);
				print "$pid Started\n";
				$num_child++;
			}
		}
	}

return 0;
}

sub sigchild(){
	my ($sig) = @_;
	#print @_;
}

sub forker($){
	my $eternus = shift;
	if("x$eternus" eq ""){
		return(1);
	}
	my $pid = fork();
	if ($pid eq 0) { # Child process
		#exec("expect -f $base_dir/exp/eternus_status_check.exp $eternus > $base_dir/log/exp/$eternus.log 2>&1");
		open(IN, "$base_dir/exp/eternus_status_check.exp $eternus 2>&1 |") or die "FAILED!!";
		while(<IN>){
			chomp;
			s/\r//g;
		}
		close(IN);
		exit;
	}
return $pid;
}
