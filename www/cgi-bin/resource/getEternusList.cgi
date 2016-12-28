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
my $eternus = ();
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
	$cgi->{'island'} = 'all |grep et0000';
}

my $i=0;
open(IN, "$base_dir/exp/node_list.exp $cgi->{'island'}|") or die "FAILED!!";
while(<IN>){
	chomp;
	s/"//g;
	s/\r//g;
	my @tmp = split(/,/);
	if($tmp[0] =~ /et[0-9]{4}-[0-9]{2}-[0-9]{2}$/){
		$eternus->[$i++]->{$tmp[0]}->[0] = $tmp[1];
	}
}
close(IN);

parent($eternus);

sub parent($){
	my $pid;
	my $num_child = 32;
	my $eternus = shift;
	my $num = @$eternus;
	if($num < $num_child){
		$num_child = $num;
	}
	open(OUT,">/tmp/eternus.csv");
	$SIG{'CHLD'} = 'sigchild';
	for(my $i=0;$i<$num_child;$i++){
		$pid = forker($eternus->[$i]);
	}

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		if($waitpid ne 0){
			if($num_child < @$eternus){
				$pid = forker($eternus->[$num_child]);
				$num_child++;
			}
		}
	}
	close(OUT);

	open(IN,"/tmp/eternus.csv");
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
	my $eternus = shift;
	if("x$eternus" eq ""){
		return(1);
	}
	my $pid = fork();
	if ($pid == 0) { # Child process
		my ($target) = keys(%$eternus);
		my $ip = $eternus->{$target}->[0];
		open(IN, "$base_dir/exp/eternusCMD.exp $ip \"show status\" 2>&1 |") or die "FAILED!!";
		while(<IN>){
			chomp;
			s/\r//g;
			if(/^Summary Status\s+\[(.+)\]/){
  			flock(OUT, 2);
  			seek(OUT, 0, 2);
				print OUT "$target,$ip,$1\n";
			}
		}
		close(IN);
		flock(OUT,8);
		exit;
	}
return $pid;
}
close(DEBUG);
