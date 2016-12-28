#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

print "Content-type: text/plain\n\n";
my $Get = $ENV{'QUERY_STRING'};

use env;
use JSON;
use func qw(web_cgi);
use auth;
use POSIX ":sys_wait_h";
my $base_dir = $env::base_dir;
my $serverview = ();
my $user = $ENV{'AUTHENTICATE_UID'};
my $Get = $ENV{'QUERY_STRING'};
my $json = new JSON();
my $data = ();
my $auth = new auth($user);
if(!$auth->_auth()){
	print "{\"result\":\"Auth failed\"}";
	exit;
}

my $cgi = new web_cgi();
$cgi->hash($Get);

if($cgi->{'island'} eq 'region'){
	$cgi->{'island'} = 'all |grep ps0000';
}

my $i=0;
open(IN, "$base_dir/exp/node_list.exp $cgi->{'island'}|") or die "FAILED!!";
while(<IN>){
	chomp;
	s/"//g;
	s/\r//g;
	my @tmp = split(/,/);
	if($tmp[0] =~ /ps[0-9]{4}-[0-9]{2}-[0-9]{2}$/){
		$serverview->[$i++]->{$tmp[0]}->[0] = $tmp[1];
	}
}
close(IN);
$serverview->[$i++]->{"jp-01-1-ps0000-08-09"}->[0] = "10.0.0.8";

parent($serverview);

sub parent($){
	my $pid;
	my $num_child = 32;
	my $serverview = shift;
	my $num = @$serverview;
	if($num < $num_child){
		$num_child = $num;
	}
	open(OUT,">/tmp/serverview.csv");
	$SIG{'CHLD'} = 'sigchild';
	for(my $i=0;$i<$num_child;$i++){
		$pid = forker($serverview->[$i]);
	}

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		if($waitpid ne 0){
			if($num_child < @$serverview){
				$pid = forker($serverview->[$num_child]);
				$num_child++;
			}
		}
	}
	close(OUT);

	open(IN,"/tmp/serverview.csv");
	my $i= 0;
	$tmp = ();
	while(<IN>){
		chomp;
		s/\r//g;
		my @tmp = split(/,/);
		push(@{$tmp->{$tmp[0]}->{$tmp[1]}}, $tmp[2]);
	}
	close(IN);

	foreach my $j(sort(keys(%$tmp))){
		$data->[$i++]->{$j} = $tmp->{$j};
	}
print $json->encode($data);

return 0;
}

sub sigchild(){
	my ($sig) = @_;
	#print @_;
}

sub forker($){
	my $serverview = shift;
	if("x$serverview" eq ""){
		return(1);
	}
	my $pid = fork();
	if ($pid == 0) { # Child process
		my ($target) = keys(%$serverview);
		my $ip = $serverview->{$target}->[0];
		#open(IN, "$base_dir/exp/eternusCMD.exp $ip \"show status\" 2>&1 |") or die "FAILED!!";
		open(IN,"$base_dir/exp/resource/getServerViewRAID.exp $ip|") or die "FAILED!!";
		while(<IN>){
			chomp;
			s/\r//g;
			if(/^[^\s]+$/){
  			flock(OUT, 2);
  			seek(OUT, 0, 2);
				print OUT "$target,$ip,$_\n";
			}
		}
		close(IN);
		flock(OUT,8);
		exit;
	}
return $pid;
}
close(DEBUG);
