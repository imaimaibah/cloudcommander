#!/usr/bin/perl

#use strict;
use Socket;
use IO::Handle;
use POSIX ":sys_wait_h";
require "/usr/local/2nd_tools/lib/env.pm";
my $base_dir = $env::base_dir;
my $region = $env::region;
my $region_num = $env::region_num;
my @list;
open(IN,"$base_dir/exp/serverList.exp islanda-cbrm|") or die "FAILED";
while(<IN>){
	chomp;
	s/\r//g;
	if(!/SERVER/ and !/----/ and !/^$/){
		my @tmp = $_ =~ /[^\s\t]+/g;
		push(@list,$tmp[1])
	}
}
close(IN);

parent($ARGV[0]);

sub parent($){
	my $pid;
	my $num_child = shift || 32;
	$SIG{'CHLD'} = 'sigchild';
	if($num_child > @list){
		for(my $i=0;$i<@list;$i++){
			$pid = forker($list[$i]);
		}
	}else{
		for(my $i=0;$i<$num_child;$i++){
			$pid = forker($list[$i]);
		}
	}

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		if($waitpid ne 0){
			if($num_child < @list){
				$pid = forker($list[$num_child]);
				$num_child++;
			}
		}
	}

return 0;
}

sub sigchld(){
	my ($sig) = @_;
	#print @_;
}

sub forker($){
	my $pserver = shift;
	my $flag = 0;
	if("x$pserver" eq ""){
		return(1);
	}
#socketpair(CHILD, PARENT, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or  die "socketpair: $!";
#CHILD->autoflush(1);
#PARENT->autoflush(1);
	my $pid = fork();
	if ($pid eq 0) { # Child process
#		close(CHILD);
		open(IN,"$base_dir/exp/xm_list.exp $pserver|") or die "FAILED";
		while(<IN>){
			s/\r//g;
			chomp;
			if(!/Name/ and !/Domain-0/){
				$flag++;
			}
		}
		print "$pserver,$flag\n";
		close(IN);
		exit;
	}
#	close(PARENT);
return $pid;
}
