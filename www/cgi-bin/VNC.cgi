#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

#use POSIX ":sys_wait_h";
use POSIX;
use env;
use auth;
use audit qw(audit_web);
use func qw(web_cgi multiRegion);
use JSON;
my $json = new JSON();
my $base_dir = $env::base_dir;
my $opid;
my $opid2;
my $opid3;
my $user = $ENV{'AUTHENTICATE_UID'};
my $cgi = new web_cgi();
my $audit = new audit_web();
my $auth = new auth($user);
my $GET = $ENV{'QUERY_STRING'};
$cgi->hash($GET);
my $vm = $cgi->{'vm'};
my $userIP = $ENV{'REMOTE_ADDR'};
my @tmp = split(/-/,$vm);
my $vsys = $tmp[0]."-".$tmp[1];
my $obj = new multiRegion;
$obj->findVMRegion($vsys);
my $island = $obj->{'vsys'}->{$vsys}."-cbrm";
my $log = $vm . "_" . $env::today . "-" . $env::now;
my $flag = "/tmp/VNC.flag";

#use Socket;
#use IO::Handle;
if(!$auth->_auth()){
	print "Content-type: application/json\n\n";
	#$data->{'result'} = "Auth failed";
	print "Auth failed";
	exit;
}else{

	if(-e $flag){
		print "Content-type: text/plain\n\n";
		print "Somebody is using. Wait for a while\n";
		exit 1;
	}else{
		system("touch $flag");
	}

my $p = fork();
if($p){
	print "Content-type: text/plain\n\n";
	print "SUCCESS";
	exit 0;
}else{
		chdir('/');
		close(STDIN);
		close(STDOUT);
		close(STDERR);
		POSIX::setsid();
		if(fork()){
			exit 0;
		}else{
			POSIX::setsid();
		}
}

parent($vm,$island,$userIP,$log);
	unlink($flag);
}

sub parent(){
	my $pid1;
	my $pid2;
	my $vm = shift;
	my $island = shift;
	my $userIP = shift;
	my $log = shift;
	my $port = 17770;


	$SIG{'CHLD'} = 'sigchild';
	$pid1 = forker1($vm,$island,$userIP);
	$pid2 = forker2($port,$log);
	$pid3 = forker3();
	$SIG{'ALRM'} = sub {unlink($flag);kill(SIGHUP,$pid1,$pid2,$pid3);};
	$SIG{'KILL'} = sub {unlink($flag);kill(SIGHUP,$pid1,$pid2,$pid3);};
	$SIG{'HUP'} = sub {unlink($flag);kill(SIGHUP,$pid1,$pid2,$pid3);};

	alarm 60;

	while ( (my $waitpid = waitpid(-1, &WNOHANG) ) > -1 ) {
		if($waitpid eq $pid2){
			unlink($flag);
			kill(SIGHUP,$pid1,$pid3);
		}
	}


return 0;
}

sub sigchild(){
	my ($sig) = @_;
	#print @_;
}

sub forker1(){
	my $line;
	my $vm = shift;
	my $island = shift;
	my $userIP = shift;
	#socketpair(CHILD_1, PARENT_1, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or  die "socketpair: $!";

#CHILD_1->autoflush(1);
#PARENT_1->autoflush(1);
	my $pid = fork();
	if($pid eq 0){
		close(CHILD_1);
		$opid = open(IN,"$base_dir/exp/vnc.exp $vm $island $userIP|");
		$SIG{HUP} = sub{kill(SIGHUP,$opid)};
		#while(<IN>){
		#}
		readline(IN);
		close(IN);
		exit 0;
	#}else{
	#	close(PARENT_1);
	#	$line = readline(CHILD_1);
	#	chomp($line);
	#	close(CHILD_1);
	}
	#my @result = ($pid,$line);

return 0;
}

sub forker2(){
	my $port = shift;
	my $log = shift;
#socketpair(CHILD_2, PARENT_2, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or  die "socketpair: $!";

#CHILD_2->autoflush(1);
#PARENT_2->autoflush(1);
	my $pid = fork();
	if($pid eq 0){
#		close(CHILD_2);
#		$line = readline(PARENT_2);
		$opid2 = open(IN,"$base_dir/exp/rfbproxy.exp $port $log|");
		$SIG{HUP} = sub{kill(SIGHUP,$opid2)};
		#while(<IN>){
		#}
		readline(IN);
		#("expect -f $base_dir/exp/rfbproxy.exp $port") or die "FAILED!!";
		close(IN);
		exit 0;
	}else{
#		close(PARENT_2);
	}

return $pid;
}

sub forker3(){
	my $port = 17775;
	
	my $pid = fork();
	if($pid eq 0){
		$opid3 = open(IN,"$base_dir/exp/noVNC.exp|");
		$SIG{HUP} = sub{kill(SIGHUP,$opid3)};
		while(<IN>){
			print DEBUG $_;
		}
		close(IN);
		exit 0;
	}else{
	}

return $pid;
}
close(DEBUG);
