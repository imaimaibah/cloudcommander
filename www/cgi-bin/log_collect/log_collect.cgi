#!/usr/bin/perl -I/usr/local/2nd_tools/lib

use env;
use JSON;
use auth;
use func qw(web_cgi);
use strict;
use POSIX ();

my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
my $data = ();
#open(DEBUG,">/tmp/debug.log");
my $cgi = new web_cgi;

my $auth = new auth($user);

my $Get = $ENV{'QUERY_STRING'};
$cgi->hash($Get);

print "Content-type: application/json\n\n";

my $kind = $cgi->{'kind'};
my $island = $cgi->{'island'};
my $vsysId = $cgi->{'vsysId'};

=comment

if(!$auth->_auth()){
  print "Auth failed";
  exit;
}

=cut

my $pid = fork();
if ($pid){
	print "Content-type: text/plain\n\n";
	print "Executed!";
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

if ($kind == 11){
	system("$base_dir/exp/log_collect/ror_snap_full.exp $island");
#	open(IN, "$base_dir/exp/log_collect/ror_snap_full.exp $island |");
} elsif ($kind == 12){
	system("$base_dir/exp/log_collect/ror_snap_light.exp $island");
#	open(IN, "$base_dir/exp/log_collect/ror_snap_light.exp $island |");
} elsif ($kind == 13){
	system("$base_dir/exp/log_collect/ror_ope_log.exp $island");
#	open(IN, "$base_dir/exp/log_collect/ror_ope_log.exp $island |");
} elsif ($kind == 14){
	system("$base_dir/exp/log_collect/cnm_manager_snap.exp $island");
#	open(IN, "$base_dir/exp/log_collect/cnm_manager_snap.exp $island |");
} elsif ($kind == 15){
	system("$base_dir/exp/log_collect/cnm_manager_snap_prov.exp $island");
#	open(IN, "$base_dir/exp/log_collect/cnm_manager_snap_prov.exp $island |");
} elsif ($kind == 16){
  system("$base_dir/exp/log_collect/csm_manager_snap.exp $island");
# open(IN, "$base_dir/exp/log_collect/csm_manager_snap.exp $island |");
} elsif ($kind == 21){
	system("$base_dir/exp/log_collect/vsys-db_info.exp $vsysId");
#	open(IN, "$base_dir/exp/log_collect/vsys-db_info.exp $vsysId |");
} elsif ($kind == 22){
	system("$base_dir/exp/log_collect/vsys-db_trace-log.exp $vsysId");
#	open(IN, "$base_dir/exp/log_collect/vsys-db_trace-log.exp $vsysId |");
}	elsif ($kind == 31){
	system("$base_dir/exp/log_collect/vsys-ap_trace-log.exp $vsysId");
#	open(IN, "$base_dir/exp/log_collect/vsys-ap_trace-log.exp $vsysId |");
} elsif ($kind == 32){
	system("$base_dir/exp/log_collect/vsys-ap_img-plugin.exp");	
#	open(IN, "$base_dir/exp/log_collect/vsys-ap_img-plugin.exp |");
} elsif ($kind == 41){
	system("$base_dir/exp/log_collect/charge_log.exp");
#	open(IN, "$base_dir/exp/log_collect/charge_log.exp |");
} elsif ($kind == 51){
	system("$base_dir/exp/log_collect/swcm_cb-cmgr-zentai.exp");
#	open(IN, "$base_dir/exp/log_collect/swcm_cb-cmgr-zentai.exp |");
} elsif ($kind == 52){
	system("$base_dir/exp/log_collect/swcm_cb-relay.exp");
#	open(IN, "$base_dir/exp/log_collect/swcm_cb-relay.exp |");
} elsif ($kind == 53){
	system("$base_dir/exp/log_collect/swcm_islandx-sl.exp $island");
#	open(IN, "$base_dir/exp/log_collect/swcm_islandx-sl.exp $island |");
} elsif ($kind == 61){	
	system("$base_dir/exp/log_collect/xen_snap.exp $vsysId");
#	open(IN, "$base_dir/exp/log_collect/xen_snap.exp $vsysId |");
} elsif ($kind == 62){
	system("$base_dir/exp/log_collect/csm_agent_snap.exp $vsysId");
#	open(IN, "$base_dir/exp/log_collect/csm_agent_snap.exp $vsysId |");
} elsif ($kind == 63){
	system("$base_dir/exp/log_collect/kvm_snap.exp $vsysId");
#	open(IN, "$base_dir/exp/log_collect/kvm_snap.exp $vsysId |");
} elsif ($kind == 71){
	system("$base_dir/exp/log_collect/pcl-snap.exp $vsysId");
#	open(IN, "$base_dir/exp/log_collect/pcl-snap.exp $vsysId |");
} else {
  print "Failed";
}
#	while(<IN>){
#	chomp;
#		s/\r//g;
#		print "$_\n";
#  }
#	close(IN);
exit;
