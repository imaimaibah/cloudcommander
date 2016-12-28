#!/usr/bin/perl -I/usr/local/2nd_tools/lib

open(DEBUG,">/tmp/debug.log");

use Time::Local;
use env;
use auth;
use JSON;
use func qw(web_cgi);
my $base_dir = $env::base_dir;
my $user = $ENV{'AUTHENTICATE_UID'};
#### DELETE BELOW LINES ####
$user = "shin.imai";
############################
my $auth = new auth($user);
my $cgi = new web_cgi;
my $obj =  new JSON();
my $data = ();
$cgi->hash($ENV{'QUERY_STRING'});

print "Content-type: application/json\n\n";
if(!$auth->_auth()){
	$data->{'result'} = "Auth failed";
	print $obj->encode($data);
	exit;
}

### DIR ###
my @date;
my $start_date = "20130510";
my $end_date = "";
if(($start_date ne "" and $end_date eq "") or $start_date eq $end_date){
	@date = glob("/data/trend/$start_date/*");
}


### MAIN ###
$data->{'lserver'} = {};
eco_lserver($data->{'lserver'});
print $obj->encode($data);

### Functions ###
sub eco_lserver(){
my $data = shift;
my $tmp = ();
my $i=0;
$data->{'xText'} = "Lservers Status(Economy Equivalent)";
$data->{'yText'} = "Number of VMs";
foreach my $date(@date){
	if(!-e "$date/lserver.log"){
		next;
	}
	open(IN,"$date/lst.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[A-Z]{3}-[A-Z]{2}-[0-9]{4}-[0-9]{4}/){
			my @tmp = $_ =~ /[^\s|]+/g;
			$tmp->{'type'}->{$tmp[1]} = $tmp[2];
		}
	}
	close(IN);
	$tmp->{'type'}->{'firewall'} = 1;
	my $category = $date;
	$category =~ s!/data/trend/(....)(..)(..)/(..)!$1/$2/$3 $4 hour!;
	push(@{$data->{'category'}},$category);
	open(IN,"$date/lserver.log") or die "FAILED";
	while(<IN>){
		chomp;
		s/\r//g;
		if(/[0-9A-Z]{8}-[0-9A-Z]{9}/){
			my @tmp = $_ =~ /[^\s|\t]+/g;
			if($tmp[3] eq 'UNEXPECTED_STOP'){
				$tmp[3] = 'STOPPED';
			}
			$tmp->{$tmp[3]}->[$i] += $tmp->{'type'}->{$tmp[6]};
		}
	}
	close(IN);
	$i++;
}

$i=0;
delete($tmp->{'type'});
while(my($key,$val)=each(%$tmp)){
	$data->{'series'}->[$i]->{'name'} = $key;
	foreach my $val1(@$val){
		push(@{$data->{'series'}->[$i]->{'data'}},$val1);
	}
	$i++;
}

$data->{'unit'}="";

}
