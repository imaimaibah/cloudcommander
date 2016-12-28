#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use POSIX ":sys_wait_h";
use env;
my $base_dir = $env::base_dir;

my $file = shift;
my $vm=();
my $ret = 0;

open(IN,$file) or die "Cannot read a file";
my $i=0;
while(<IN>){
	chomp;
	if(/SOPMGTCB-[A-Z0-9]{9}-S-[0-9]{4}/){
		exit 1
	}elsif(/[A-Z0-9]{8}-[A-Z0-9]{9}-S-[0-9]{4}/){
		@{$vm->[$i++]} = $_ =~ /[^\s\|\t]+/g;
	}
}
close(IN);

if($vm eq ""){
	exit 2;
}

print "\n\n";
my $flag = 0;
foreach my $el(@{$vm}){
	if($el->[0] =~ /0001$/ and $el->[1] eq "UNDEPLOY"){
		exit 4;
	}
		print "$el->[0] : $el->[1]\n";

	if($el->[1] eq "UNDEPLOYING" or $el->[1] eq "DEPLOYING"){
		$flag++;
	}
}
if($flag ne 0){
	print "$flag of the VMs are not in good state to release.\n";
	print "Please contact 2nd list support.\n";
	exit 1;
}
print "\n\n";

print "Would you like to stop them? (y/n)";
my $flag=readline(STDIN);
chomp($flag);
if($flag eq 'y'){
	stopVM($vm);
	if($ret eq 2){
		exit 3;
	}
}else{
	exit 1;
}

sub stopVM(){
	local $|=1;
	my $pid;
	my $num_child = 4;
	my $obj = shift;
	if(@{$obj} < $num_child){
		$num_child = @{$obj};
	}

	my $num_vm = $#{$obj};
	$num_vm++;
	print "Stopping : 0/$num_vm";
	for(my $i=0;$i<$num_child;$i++){
		$pid = forker($obj->[$i]);
		if($pid ne '1'){
			print "\r";
			print "Stopping : $i/$num_vm";
			sleep 2;
		}
	}

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		my $ret_stop = $?>>8;
		if($ret_stop eq 2){
			$ret = 2;
		}
		if($waitpid ne 0){
			if($num_child < @{$obj}){
				$pid = forker($obj->[$num_child]);
				$num_child++;
				print "\r";
				print "Stopping : $num_child/$num_vm";
			}
		}
	}
	print "\n";

return 0;
}

sub forker($){
	my $lserver = shift;
	if("x$lserver" eq ""){
		return 1;
	}
	my $pid = fork();
	if ($pid == 0) { # Child process
		if($lserver->[1] =~ /RUNNING|UNEXPECTED_STOP|STOP_ERROR/){
			exec("$base_dir/exp/force_stop.exp $lserver->[2] $lserver->[0] > /dev/null 2>&1");
			exit;
		}else{
			exit;
		}
	}

return $pid;
}
