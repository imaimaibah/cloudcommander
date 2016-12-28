#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use func;
use POSIX ":sys_wait_h";
my $base_dir = $env::base_dir;
my $data = ();
my $ASR = 10.3.1.1

#open(IN,"$base_dir/exp/find_fw.exp");
open(IN,"./j");
my $i = 0;
while(<IN>){
	chomp;
	chop;
	if(/host ([A-Z0-9]{8}-[A-Z0-9]{9}-S-[0-9]{4})/){
		$data->[$i]->[0] = $1;
	}elsif(/fixed-address ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/){
		$data->[$i]->[1] = $1;
		$i++;
	}
	
}
close(IN);

$i = 0;
my @option;
my $tmp;
for($i=0;$i<@$data;$i++){
	if($data->[$i]->[0] =~ /SOPMGTCB/){
		next;
	}
	for(my $l = 0;$l<30;$l++){
		$tmp .= "$data->[$i]->[1] ";
		$i++;
	}
	push(@option,$tmp);
	$tmp = "";
}

parent(@option);


sub parent($){
	my $pid;
	my @option = @_;
	$SIG{'CHLD'} = 'sigchild';
	for(my $i=0;$i<@option;$i++){
		$pid = forker($option[$i]);
		if($pid ne '1'){
			print "$pid Started\n";
		}
	}

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		if($waitpid ne 0){
			print "$waitpid has finished\n";
		}
	}

return 0;
}

sub sigchld(){
	my ($sig) = @_;
	#print @_;
}

sub forker($){
	my $option = shift;
	if("x$option" eq "x"){
		return(1);
	}
	my $pid = fork();
	if ($pid == 0) { # Child process
		exec("expect -f $base_dir/exp/fwping.exp $ASR $option >> $base_dir/log/log 2>&1");
		exit;
	}
return $pid;
}
